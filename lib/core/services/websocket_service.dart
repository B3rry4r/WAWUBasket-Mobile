import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../network/api_config.dart';
import '../network/token_store.dart';

/// A single push from the API's `/ws` Socket.IO namespace.
///
/// The server emits one event name (`message`) and packs the variant into
/// `type`. Consumers filter by type and cast `payload` against the contract
/// for that type:
///
///   - `chat.message` → `{ orderId, message: { id, senderId, senderRole,
///     body, attachUrl?, createdAt } }`
///   - `chat.read` → `{ orderId, userId, lastReadMessageId }`
///   - `delivery.location.updated`, `order.status.updated`, etc. — wired
///     by their respective features.
class WsFrame {
  const WsFrame({required this.type, required this.ts, required this.payload});

  final String type;
  final int ts;
  final Map<String, dynamic> payload;

  factory WsFrame.fromJson(Object? raw) {
    final m = (raw as Map).cast<String, dynamic>();
    return WsFrame(
      type: (m['type'] ?? '').toString(),
      ts: (m['ts'] is int) ? m['ts'] as int : 0,
      payload: (m['payload'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    );
  }
}

/// Real-time channel to the WAWUBasket API.
///
/// Lifecycle:
///   * `init()` is called once at app boot — it subscribes to
///     [TokenStore.tokenNotifier] so the service connects automatically on
///     login and tears down on logout. No auth-screen wiring required.
///   * `subscribe()` joins additional channels on the fly (e.g. when the
///     chat detail screen opens a specific `chat:<chatId>` channel).
///   * On disconnect, an exponential-backoff reconnect loop runs until
///     the token is cleared or a new connection succeeds.
///   * An app-lifecycle observer forces a connection check on resume so
///     a backgrounded socket comes back online when the user returns.
///
/// Consumers listen to [frames] (or the typed [chatFrames] convenience)
/// from their screens and dispose of their subscriptions on screen exit.
class WebSocketService with WidgetsBindingObserver {
  WebSocketService._();
  static final WebSocketService instance = WebSocketService._();

  io.Socket? _socket;
  final StreamController<WsFrame> _frames =
      StreamController<WsFrame>.broadcast();

  /// Channels we always re-subscribe to on (re)connect. The `user:<id>`
  /// channel is added once the access token resolves a user id.
  final Set<String> _channels = <String>{};

  /// Channels callers asked us to keep joined across reconnects.
  final Set<String> _stickyChannels = <String>{};

  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _lifecycleAttached = false;
  bool _initialised = false;

  /// Whether the socket is currently connected and authenticated.
  bool get isConnected => _socket?.connected ?? false;

  /// Every frame coming off the namespace. Screens filter by `type`.
  Stream<WsFrame> get frames => _frames.stream;

  /// Chat-only frames: `chat.message` and `chat.read`.
  Stream<WsFrame> get chatFrames => frames.where(
        (f) => f.type == 'chat.message' || f.type == 'chat.read',
      );

  // ── lifecycle ────────────────────────────────────────────────────────

  /// Wire up auto-connect/disconnect against [TokenStore]. Idempotent.
  void init() {
    if (_initialised) return;
    _initialised = true;
    if (!_lifecycleAttached) {
      WidgetsBinding.instance.addObserver(this);
      _lifecycleAttached = true;
    }
    TokenStore.instance.tokenNotifier.addListener(_onTokenChanged);
    // First-boot sync: connect immediately if we already have a session.
    if (TokenStore.instance.hasSession) {
      connect();
    }
  }

  void _onTokenChanged() {
    final tok = TokenStore.instance.accessToken;
    if (tok == null || tok.isEmpty) {
      disconnect();
    } else {
      connect();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      foregrounded();
    }
  }

  /// Called when the app comes back to the foreground — kicks an idle or
  /// silently-dropped socket back into a reconnect attempt.
  void foregrounded() {
    if (!TokenStore.instance.hasSession) return;
    final s = _socket;
    if (s == null || !s.connected) {
      _reconnectAttempt = 0;
      connect();
    }
  }

  // ── connect / disconnect ─────────────────────────────────────────────

  /// Opens (or re-opens) the socket using the current access token.
  ///
  /// Safe to call repeatedly — if a socket is already connected with the
  /// same token it's a no-op; otherwise the previous one is torn down
  /// first.
  void connect() {
    final token = TokenStore.instance.accessToken;
    if (token == null || token.isEmpty) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // Reuse the existing socket only if it's healthy. Otherwise tear it
    // down so the new auth payload is honoured.
    final existing = _socket;
    if (existing != null) {
      if (existing.connected) return;
      try {
        existing.dispose();
      } catch (_) {/* fine */}
    }

    _refreshUserChannel(token);

    final url = _resolveWsUrl();
    final socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          // We handle reconnect manually so the JWT can be refreshed
          // between attempts via [TokenStore].
          .disableAutoConnect()
          .disableReconnection()
          .setAuth({'token': token}).build(),
    );

    socket.onConnect((_) {
      _reconnectAttempt = 0;
      if (_channels.isNotEmpty) {
        socket.emit('subscribe', {'channels': _channels.toList()});
      }
    });

    socket.on('message', (data) {
      try {
        _frames.add(WsFrame.fromJson(data));
      } catch (e, st) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('WS frame parse error: $e\n$st');
        }
      }
    });

    socket.onConnectError((_) => _scheduleReconnect());
    socket.onError((_) => _scheduleReconnect());
    socket.onDisconnect((_) => _scheduleReconnect());

    _socket = socket;
    socket.connect();
  }

  /// Drop the socket and clear our channel set. Called on logout.
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempt = 0;
    final s = _socket;
    _socket = null;
    if (s != null) {
      try {
        s.dispose();
      } catch (_) {/* fine */}
    }
    _channels.clear();
    _stickyChannels.clear();
  }

  void _scheduleReconnect() {
    if (!TokenStore.instance.hasSession) return;
    if (_reconnectTimer != null) return;
    final attempt = ++_reconnectAttempt;
    // 1s, 2s, 4s, 8s, 16s, capped at 30s with up to 1s of jitter.
    final base = math.min(30, 1 << math.min(attempt, 5));
    final jitter = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
    final delay = Duration(milliseconds: ((base + jitter) * 1000).round());
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      connect();
    });
  }

  // ── channels ─────────────────────────────────────────────────────────

  /// Joins additional Socket.IO rooms (chat threads, order tracking, etc).
  ///
  /// Channels are remembered and re-subscribed on every reconnect.
  void subscribe(List<String> channels) {
    if (channels.isEmpty) return;
    _channels.addAll(channels);
    _stickyChannels.addAll(channels);
    final s = _socket;
    if (s != null && s.connected) {
      s.emit('subscribe', {'channels': channels});
    }
  }

  /// Leaves the given rooms — call from a screen's `dispose` once you no
  /// longer need updates for it.
  void unsubscribe(List<String> channels) {
    if (channels.isEmpty) return;
    _channels.removeAll(channels);
    _stickyChannels.removeAll(channels);
    final s = _socket;
    if (s != null && s.connected) {
      s.emit('unsubscribe', {'channels': channels});
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────

  void _refreshUserChannel(String token) {
    // Strip any previous `user:` channel so we don't keep stale ones from
    // a switched account.
    _channels.removeWhere((c) => c.startsWith('user:'));
    final userId = _userIdFromJwt(token);
    if (userId != null && userId.isNotEmpty) {
      _channels.add('user:$userId');
    }
    _channels.addAll(_stickyChannels);
  }

  /// Decodes the `sub` claim from the unsigned JWT payload. We don't
  /// validate the signature here — the server enforces it on connect.
  String? _userIdFromJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return null;
      var payload = parts[1];
      // base64url decode with padding fix.
      payload = payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');
      final bytes = base64Url.decode(payload);
      final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return map['sub']?.toString();
    } catch (_) {
      return null;
    }
  }

  String _resolveWsUrl() {
    // socket_io_client accepts http(s) and rewrites to ws(s) internally.
    // The API gateway lives at `/ws` on the same origin as the REST API.
    return '$apiOrigin/ws';
  }
}
