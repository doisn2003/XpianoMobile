import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:logger/logger.dart';
import '../../features/feed/domain/repositories/post_repository.dart';

/// Service để upload media (ảnh/video) lên Supabase Storage
/// qua PreSigned URL — không đi qua Express backend.
///
/// Flow:
/// 1. Nén media (ảnh/video) trước khi upload
/// 2. Xin signedUrl từ Express (POST /api/upload/sign)
/// 3. Upload file trực tiếp lên Supabase Storage (PUT signedUrl) bằng file stream
/// 4. Xóa file nén tạm
/// 5. Trả publicUrl để gắn vào bài viết
class MediaUploadService {
  final PostRepository _postRepository;
  static final Logger _logger = Logger();

  /// Timeout cho upload: 5 phút
  static const _uploadTimeout = Duration(minutes: 5);

  /// Số lần retry tối đa khi lỗi mạng
  static const _maxRetries = 2;

  MediaUploadService({required PostRepository postRepository})
      : _postRepository = postRepository;

  // ─── Public API ──────────────────────────────────────────────

  /// Upload một file và trả về publicUrl.
  /// [onProgress] callback với giá trị 0.0 → 1.0
  /// [onStatusChange] callback để cập nhật status message
  Future<String> uploadFile({
    required File file,
    required String uploadType, // 'post_image' hoặc 'post_video'
    void Function(double progress)? onProgress,
    void Function(String status)? onStatusChange,
  }) async {
    File? compressedFile;

    try {
      // Bước 1: Nén file nếu cần
      if (uploadType == 'post_video' || uploadType == 'course_video' || uploadType == 'piano_video') {
        onStatusChange?.call('Đang nén video...');
        compressedFile = await _compressVideo(file);
      } else if (uploadType == 'post_image' || uploadType == 'course_image' || uploadType == 'piano_image') {
        onStatusChange?.call('Đang nén ảnh...');
        compressedFile = await _compressImage(file);
      }

      final fileToUpload = compressedFile ?? file;
      final fileName = fileToUpload.path.split(Platform.pathSeparator).last;
      final fileSize = await fileToUpload.length();
      final contentType = _getContentType(fileName);

      _logger.d('[Upload] File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB'
          '${compressedFile != null ? " (compressed)" : ""}');

      // Bước 2: Xin PreSigned URL
      onStatusChange?.call('Đang chuẩn bị upload...');
      final result = await _postRepository.getSignedUploadUrl(
        uploadType: uploadType,
        fileName: fileName,
        fileSize: fileSize,
        contentType: contentType,
      );

      return await result.fold(
        (failure) => throw Exception('Không thể tạo upload URL: ${failure.message}'),
        (urlData) async {
          final signedUrl = urlData['signedUrl']!;
          final publicUrl = urlData['publicUrl']!;

          // Bước 3: Upload trực tiếp lên Supabase Storage với retry
          onStatusChange?.call('Đang tải lên...');
          await _uploadWithRetry(
            signedUrl: signedUrl,
            file: fileToUpload,
            fileSize: fileSize,
            contentType: contentType,
            onProgress: onProgress,
          );

          // Bước 4: Trả publicUrl
          return publicUrl;
        },
      );
    } finally {
      // Bước 5: Cleanup — xóa file nén tạm (luôn chạy dù thành công hay thất bại)
      await _cleanupTempFile(compressedFile);
    }
  }

  /// Upload nhiều file cùng lúc (song song cho bài viết nhiều ảnh)
  Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String uploadType,
    void Function(int index, double progress)? onProgress,
    void Function(String status)? onStatusChange,
  }) async {
    // Upload song song tất cả file
    final futures = <Future<String>>[];

    for (int i = 0; i < files.length; i++) {
      futures.add(
        uploadFile(
          file: files[i],
          uploadType: uploadType,
          onProgress: (p) => onProgress?.call(i, p),
          onStatusChange: (status) => onStatusChange?.call('Ảnh ${i + 1}/${files.length}: $status'),
        ),
      );
    }

    return Future.wait(futures);
  }

  // ─── Private: Compression ────────────────────────────────────

  /// Nén ảnh: resize xuống max 1280px, quality 80%
  Future<File?> _compressImage(File file) async {
    try {
      final fileSize = await file.length();
      // Không nén nếu file đã nhỏ hơn 500KB
      if (fileSize < 500 * 1024) {
        _logger.d('[Compress] Image already small (${(fileSize / 1024).toStringAsFixed(0)} KB), skipping');
        return null;
      }

      final targetPath = '${file.parent.path}${Platform.pathSeparator}compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 80,
        minWidth: 1280,
        minHeight: 1280,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        final compressedSize = await compressedFile.length();
        _logger.i('[Compress] Image: ${(fileSize / 1024).toStringAsFixed(0)} KB → '
            '${(compressedSize / 1024).toStringAsFixed(0)} KB '
            '(${(100 - compressedSize * 100 / fileSize).toStringAsFixed(0)}% giảm)');
        return compressedFile;
      }
    } catch (e) {
      _logger.w('[Compress] Image compression failed, uploading original: $e');
    }
    return null;
  }

  /// Nén video: re-encode ở MediumQuality
  Future<File?> _compressVideo(File file) async {
    try {
      final fileSize = await file.length();
      _logger.d('[Compress] Video original: ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB');

      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false, // Giữ file gốc
        includeAudio: true,
      );

      if (info != null && info.file != null) {
        final compressedSize = await info.file!.length();
        _logger.i('[Compress] Video: ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB → '
            '${(compressedSize / 1024 / 1024).toStringAsFixed(1)} MB '
            '(${(100 - compressedSize * 100 / fileSize).toStringAsFixed(0)}% giảm)');
        return info.file!;
      }
    } catch (e) {
      _logger.w('[Compress] Video compression failed, uploading original: $e');
    }
    return null;
  }

  // ─── Private: Upload with Retry ──────────────────────────────

  /// Upload file lên Supabase Storage với retry logic
  Future<void> _uploadWithRetry({
    required String signedUrl,
    required File file,
    required int fileSize,
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    final dio = Dio(BaseOptions(
      sendTimeout: _uploadTimeout,
      receiveTimeout: _uploadTimeout,
    ));

    Exception? lastError;

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          _logger.w('[Upload] Retry attempt $attempt/$_maxRetries...');
          await Future.delayed(Duration(seconds: attempt * 2)); // Exponential backoff
        }

        await dio.put(
          signedUrl,
          data: file.openRead(), // ✅ Stream file trực tiếp — KHÔNG load toàn bộ vào RAM
          options: Options(
            headers: {
              'Content-Type': contentType,
              'Content-Length': fileSize,
            },
          ),
          onSendProgress: (sent, total) {
            if (onProgress != null && total > 0) {
              onProgress(sent / total);
            }
          },
        );

        return; // Upload thành công
      } on DioException catch (e) {
        lastError = e;
        // Chỉ retry khi lỗi mạng (timeout, connection error)
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          if (attempt < _maxRetries) continue;
        }
        rethrow; // Lỗi khác (4xx, 5xx) thì không retry
      }
    }

    throw lastError ?? Exception('Upload failed after $_maxRetries retries');
  }

  // ─── Private: Cleanup ────────────────────────────────────────

  /// Xóa file nén tạm (nếu có)
  Future<void> _cleanupTempFile(File? tempFile) async {
    if (tempFile == null) return;
    try {
      if (await tempFile.exists()) {
        await tempFile.delete();
        _logger.d('[Cleanup] Deleted temp file: ${tempFile.path}');
      }
    } catch (e) {
      _logger.w('[Cleanup] Failed to delete temp file: $e');
    }
  }

  // ─── Private: Helpers ────────────────────────────────────────

  String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }
}
