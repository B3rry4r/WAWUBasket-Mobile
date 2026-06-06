import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// WhatsApp/Telegram/Instagram-style media compression applied right before
/// an upload leaves the device, so we never ship raw camera originals over
/// the wire.
///
/// Images are downscaled to a ~1600px longest edge at quality ~80 and
/// re-encoded as JPEG (aspect ratio preserved). Tiny payloads are left
/// untouched, and any failure falls back transparently to the original
/// bytes — compression must never block an upload.
abstract final class MediaCompressor {
  /// Longest-edge cap, in pixels. Matches the WhatsApp-class "high quality"
  /// target — large enough to stay crisp, small enough to slash upload size.
  static const int _maxEdge = 1600;

  /// JPEG quality (0–100). ~80 is the perceptual sweet spot.
  static const int _quality = 80;

  /// Anything already under this size is almost certainly a thumbnail or
  /// an already-optimised asset; re-encoding it can only make it worse, so
  /// we skip it.
  static const int _skipBelowBytes = 60 * 1024; // 60 KB

  /// The MIME type emitted for every successfully compressed image.
  static const String compressedContentType = 'image/jpeg';

  /// Compresses [bytes] for upload.
  ///
  /// Returns the (possibly recompressed) bytes plus the MIME type those
  /// bytes should be uploaded with. When compression is skipped or fails,
  /// the original [bytes] and [originalContentType] are returned unchanged.
  ///
  /// [originalContentType] is the content type detected for the source file
  /// (e.g. `image/png`). It is returned unchanged when compression is
  /// skipped or fails so the caller's presign/PUT stays consistent.
  ///
  /// Returns `image/jpeg` as the content type whenever the bytes were
  /// actually recompressed.
  static Future<({Uint8List bytes, String contentType})> compressImageBytes(
    Uint8List bytes, {
    required String originalContentType,
  }) async {
    // Already small enough — uploading it raw is cheaper than re-encoding.
    if (bytes.lengthInBytes <= _skipBelowBytes) {
      return (bytes: bytes, contentType: originalContentType);
    }

    try {
      final out = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: _maxEdge,
        minHeight: _maxEdge,
        quality: _quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      // Guard against the plugin returning empty / larger output (it can,
      // for already-optimised JPEGs). In that case keep the original.
      if (out.isEmpty || out.lengthInBytes >= bytes.lengthInBytes) {
        return (bytes: bytes, contentType: originalContentType);
      }
      return (bytes: out, contentType: compressedContentType);
    } catch (e, st) {
      // Never let compression block an upload — fall back to the original.
      if (kDebugMode) {
        debugPrint('MediaCompressor: image compression failed, '
            'using original bytes. $e\n$st');
      }
      return (bytes: bytes, contentType: originalContentType);
    }
  }
}
