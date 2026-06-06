import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../media/media_compressor.dart';
import 'api_client.dart';

/// The R2 folders the storage presign endpoint whitelists.
abstract final class UploadFolder {
  static const avatars = 'avatars';
  static const catalogItems = 'catalog/items';
  static const exportListings = 'export-listings';
  static const chatAttachments = 'chat/attachments';
  static String kyc(String role) => 'kyc/$role';
}

/// Result of a successful upload — the stored object key (persist this)
/// and the public URL (use this to display the image).
typedef UploadResult = ({String key, String publicUrl});

/// Picks an image and uploads it to Cloudflare R2 through a presigned
/// PUT: `POST /v1/storage/presign` → `PUT` the bytes → return the key.
class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  final _api = ApiClient.instance;
  final _raw = Dio();
  final _picker = ImagePicker();

  /// Picks an image from [source] and uploads it under [folder]. Returns
  /// null if the user cancels the picker.
  Future<UploadResult?> pickAndUpload({
    required String folder,
    ImageSource source = ImageSource.gallery,
  }) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return null;
    final rawBytes = await file.readAsBytes();

    // WhatsApp/Telegram-style compression: downscale + re-encode to JPEG
    // before the bytes ever leave the device. Falls back to the original
    // bytes (and content type) if compression is skipped or fails.
    final compressed = await MediaCompressor.compressImageBytes(
      rawBytes,
      originalContentType: _contentType(file),
    );
    final bytes = compressed.bytes;
    final contentType = compressed.contentType;

    final res = await _api.post('/storage/presign', body: {
      'folder': folder,
      'contentType': contentType,
    });
    final m = (res as Map).cast<String, dynamic>();
    final uploadUrl = (m['uploadUrl'] ?? '').toString();

    // The PUT goes straight to R2 — no API base URL, no auth header — so
    // it uses a bare Dio client. The content type must match the one the
    // presign was signed with.
    await _raw.put<void>(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: {
          Headers.contentTypeHeader: contentType,
          Headers.contentLengthHeader: bytes.length,
        },
      ),
    );
    return (
      key: (m['key'] ?? '').toString(),
      publicUrl: (m['publicUrl'] ?? '').toString(),
    );
  }

  String _contentType(XFile file) {
    final mime = file.mimeType;
    if (mime != null && mime.isNotEmpty) return mime;
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
