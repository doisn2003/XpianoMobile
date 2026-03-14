import '../network/supabase_client.dart';

class ImageUtils {
  static const _defaultBucket = 'courses';
  static const _avatarBucket = 'avatars';

  /// Resolves a potentially relative Supabase storage path to a full public URL.
  /// If [url] is already a full HTTP(S) URL, returns it as-is.
  /// If it's a relative path, constructs the public URL from the given [bucket].
  static String resolveUrl(String? url, {String bucket = _defaultBucket}) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return AppSupabaseClient.client.storage.from(bucket).getPublicUrl(url);
  }

  /// Resolves a course thumbnail URL (bucket: courses).
  static String resolveCourseThumbnail(String? url) =>
      resolveUrl(url, bucket: _defaultBucket);

  /// Resolves a course video URL (bucket: courses).
  static String resolveCourseVideo(String? url) =>
      resolveUrl(url, bucket: _defaultBucket);

  /// Resolves an avatar URL (bucket: avatars).
  static String resolveAvatar(String? url) =>
      resolveUrl(url, bucket: _avatarBucket);

  /// Appends Supabase Image Transform query params for server-side resizing.
  /// Falls back gracefully if the project isn't on Pro plan (image just loads
  /// at original size since the render endpoint returns the original).
  static String getOptimizedUrl(
    String? url, {
    int? width,
    int? height,
    String bucket = _defaultBucket,
  }) {
    final resolved = resolveUrl(url, bucket: bucket);
    if (resolved.isEmpty) return '';

    if (width == null && height == null) return resolved;

    // Supabase transform URLs use /render/image/public/ instead of /object/public/
    if (resolved.contains('/object/public/')) {
      final transformed =
          resolved.replaceFirst('/object/public/', '/render/image/public/');
      final params = <String>[];
      if (width != null) params.add('width=$width');
      if (height != null) params.add('height=$height');
      params.add('resize=contain');
      final separator = transformed.contains('?') ? '&' : '?';
      return '$transformed$separator${params.join('&')}';
    }

    return resolved;
  }

  /// Optimized course thumbnail for card grids (~400px wide).
  static String optimizedCourseThumbnail(String? url) =>
      getOptimizedUrl(url, width: 400, bucket: _defaultBucket);

  /// Optimized cover/hero image (~800px wide).
  static String optimizedCourseHero(String? url) =>
      getOptimizedUrl(url, width: 800, bucket: _defaultBucket);

  /// Optimized avatar (~100px).
  static String optimizedAvatar(String? url) =>
      getOptimizedUrl(url, width: 100, bucket: _avatarBucket);
}
