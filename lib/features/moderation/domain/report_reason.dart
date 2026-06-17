/// The eight canonical report reasons accepted by
/// `POST /v1/moderation/reports`. The wire [code] matches the backend
/// contract exactly; [label] is the human-readable string shown in the
/// report sheet.
enum ReportReason {
  harassment('harassment', 'Harassment or bullying'),
  hateSpeech('hate_speech', 'Hate speech'),
  sexualContent('sexual_content', 'Sexual or explicit content'),
  violence('violence', 'Violence or threats'),
  spam('spam', 'Spam'),
  scamFraud('scam_fraud', 'Scam or fraud'),
  illegal('illegal', 'Illegal goods or activity'),
  other('other', 'Something else');

  const ReportReason(this.code, this.label);

  /// Wire value sent to the API.
  final String code;

  /// Human-readable label shown in the picker.
  final String label;
}

/// The target types accepted by `POST /v1/moderation/reports`. Kept as
/// constants so call sites never pass a typo'd string.
abstract final class ReportTargetType {
  static const user = 'user';
  static const chatMessage = 'chat_message';
  static const catalogItem = 'catalog_item';
  static const rating = 'rating';
  static const recipe = 'recipe';
  static const exportListing = 'export_listing';
}
