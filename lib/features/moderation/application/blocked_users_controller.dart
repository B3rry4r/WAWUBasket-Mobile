import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/moderation_api.dart';

/// Holds the set of user ids the current user has blocked.
///
/// Hydrated from `GET /v1/moderation/blocks` on launch / login. The set is
/// the single source of truth the UI reads from to hide blocked users'
/// content instantly — [block]/[unblock] update the set BEFORE awaiting the
/// network round-trip (optimistic), so a freshly-blocked user's content
/// disappears immediately and only reappears if the API call fails.
class BlockedUsersController extends StateNotifier<Set<String>> {
  BlockedUsersController() : super(const <String>{});

  final _api = ModerationApi.instance;

  /// True once a successful hydrate has completed at least once.
  bool _hydrated = false;
  bool get hydrated => _hydrated;

  /// Convenience predicate the client-side filters call.
  bool isBlocked(String? userId) =>
      userId != null && userId.isNotEmpty && state.contains(userId);

  /// Pulls the blocked-user list from the server. Safe to call repeatedly
  /// (e.g. on launch and again on login). Failures leave the current set in
  /// place — the UI degrades to "nothing hidden" rather than crashing.
  Future<void> hydrate() async {
    try {
      final ids = await _api.getBlockedUsers();
      state = ids.toSet();
      _hydrated = true;
    } on ApiException {
      // Non-fatal — keep whatever we already had.
    } catch (_) {
      // Non-fatal.
    }
  }

  /// Clears the local set (used on logout so the next user starts clean).
  void clear() {
    state = const <String>{};
    _hydrated = false;
  }

  /// Blocks [userId]. Updates the set optimistically so their content is
  /// hidden instantly, then calls the API. On failure the optimistic add is
  /// rolled back and the error rethrown for the caller to surface.
  Future<void> block(String userId) async {
    if (userId.isEmpty || state.contains(userId)) return;
    state = {...state, userId};
    try {
      await _api.blockUser(userId);
    } catch (e) {
      state = {...state}..remove(userId);
      rethrow;
    }
  }

  /// Lifts the block on [userId], updating the set optimistically.
  Future<void> unblock(String userId) async {
    if (!state.contains(userId)) return;
    state = {...state}..remove(userId);
    try {
      await _api.unblockUser(userId);
    } catch (e) {
      state = {...state, userId};
      rethrow;
    }
  }
}

/// App-wide blocked-users state. Read it with `ref.watch` to rebuild a list
/// whenever the block set changes, or `ref.read(...notifier)` to mutate.
final blockedUsersProvider =
    StateNotifierProvider<BlockedUsersController, Set<String>>(
  (ref) => BlockedUsersController(),
);
