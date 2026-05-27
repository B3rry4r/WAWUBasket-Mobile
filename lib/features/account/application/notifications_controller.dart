import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/websocket_service.dart';
import '../data/account_extras_api.dart';

/// Single source of truth for the unread-notifications badge on the
/// home app bar. The notifications screen calls [markAllRead] when it
/// opens; any place rendering the badge listens to [unreadCount] (or
/// the convenience [hasUnread]) so the red dot disappears in real time.
///
/// The unread count is derived from the same `/notifications` endpoint
/// that drives the list — we count entries where `read != true`. When
/// the API later adds a dedicated `/notifications/unread-count` route,
/// swap [_loadFromFullList] for that single integer call.
///
/// Real-time: the controller also listens to `notification.new` frames
/// from [WebSocketService] and increments the badge immediately without
/// waiting for the next poll.
class NotificationsController {
  NotificationsController._();
  static final NotificationsController instance = NotificationsController._();

  StreamSubscription<WsFrame>? _wsSub;

  /// Call once at app boot (after WebSocketService.init) to wire up
  /// real-time badge increments via WebSocket.
  void listenToWebSocket() {
    _wsSub?.cancel();
    _wsSub = WebSocketService.instance.frames
        .where((f) => f.type == 'notification.new')
        .listen((_) {
      unreadCount.value += 1;
      _hasUnread.value = true;
    });
  }

  /// 0 when there are no unread notifications. The home app bar treats
  /// any value > 0 as "show the red dot".
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  /// Convenience for widgets that only need the boolean.
  ValueNotifier<bool> get hasUnread {
    if (_hasUnread.value != (unreadCount.value > 0)) {
      _hasUnread.value = unreadCount.value > 0;
    }
    return _hasUnread;
  }
  final ValueNotifier<bool> _hasUnread = ValueNotifier<bool>(false);

  bool _loading = false;

  /// Refreshes the unread count from the API. Safe to call from any
  /// screen `initState`; concurrent refreshes are coalesced.
  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      final res = await AccountExtrasApi.instance.notifications();
      final raw = (res['items'] as List?) ?? const [];
      var count = 0;
      for (final entry in raw) {
        if (entry is Map && entry['read'] != true) count++;
      }
      unreadCount.value = count;
      _hasUnread.value = count > 0;
    } catch (_) {
      // Don't surface badge errors — silently fall back to whatever the
      // last known count was. The notifications screen itself will show
      // a hard error if the same call fails for the list.
    } finally {
      _loading = false;
    }
  }

  /// Clears the badge optimistically (the screen calls this when the
  /// user marks all as read).
  void markAllRead() {
    unreadCount.value = 0;
    _hasUnread.value = false;
  }

  /// Decrement when a single notification is opened.
  void decrement() {
    final next = unreadCount.value - 1;
    unreadCount.value = next < 0 ? 0 : next;
    _hasUnread.value = unreadCount.value > 0;
  }
}
