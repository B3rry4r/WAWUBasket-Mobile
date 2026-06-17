import '../../../core/network/api_client.dart';
import '../../../core/network/api_parse.dart';

/// Wraps the `/v1/moderation/*` endpoints that back the App Review
/// Guideline 1.2 (UGC safety) surfaces — content reports and user blocks.
///
/// Follows the same singleton + [ApiClient] pattern as the other
/// `*_api.dart` clients (auth header + base URL are handled by the shared
/// [ApiClient]).
class ModerationApi {
  ModerationApi._();
  static final ModerationApi instance = ModerationApi._();

  final _api = ApiClient.instance;

  // ─── Reports ────────────────────────────────────────────────────────────

  /// Files a content report. [targetType] is one of `user`, `chat_message`,
  /// `catalog_item`, `rating`, `recipe`, `export_listing`; [reason] is one of
  /// the eight canonical reason codes. Returns the created report id.
  Future<String> reportContent({
    required String targetType,
    required String targetId,
    String? reportedUserId,
    required String reason,
    String? description,
  }) async {
    final payload = <String, dynamic>{
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
    };
    if (reportedUserId != null && reportedUserId.isNotEmpty) {
      payload['reportedUserId'] = reportedUserId;
    }
    if (description != null && description.trim().isNotEmpty) {
      payload['description'] = description.trim();
    }
    final res = await _api.post('/moderation/reports', body: payload);
    final m = safeMap(res, context: 'moderation.reportContent');
    return (m['id'] ?? '').toString();
  }

  /// The current user's filed reports, newest first as the server returns.
  Future<List<Map<String, dynamic>>> myReports() async {
    final res = await _api.get('/moderation/reports/mine');
    final list = (res as List?) ?? const [];
    return [
      for (final e in list)
        if (e is Map) e.cast<String, dynamic>(),
    ];
  }

  // ─── Blocks ─────────────────────────────────────────────────────────────

  /// The set of user ids the current user has blocked.
  Future<List<String>> getBlockedUsers() async {
    final res = await _api.get('/moderation/blocks');
    final m = safeMap(res, context: 'moderation.getBlockedUsers');
    final ids = (m['blockedUserIds'] as List?) ?? const [];
    return [for (final id in ids) id.toString()];
  }

  /// Blocks [userId] — their content is hidden from the current user.
  Future<void> blockUser(String userId) =>
      _api.post('/moderation/blocks', body: {'blockedUserId': userId});

  /// Lifts a previous block on [userId].
  Future<void> unblockUser(String userId) =>
      _api.delete('/moderation/blocks/$userId');
}
