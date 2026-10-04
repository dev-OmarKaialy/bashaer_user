import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/dependencies.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/datasources/quiz_media_cache.dart';

/// Quiz media (traffic signs, etc.) with loading/error placeholders.
///
/// Prefers a file cached during bank sync so exams work offline; falls back to
/// the network URL when the local copy is missing.
class QuizNetworkImage extends StatelessWidget {
  const QuizNetworkImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.semanticLabel,
  });

  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusM.r);
    final local = getIt<QuizMediaCache>().fileFor(url);

    final Widget image;
    if (local != null) {
      image = Image.file(
        local,
        key: ValueKey<String>('file:$url'),
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _networkImage(),
      );
    } else {
      image = _networkImage();
    }

    final clipped = DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.mutedSurface,
        borderRadius: radius,
        border: Border.all(color: AppTheme.divider),
      ),
      child: ClipRRect(borderRadius: radius, child: image),
    );

    if (semanticLabel == null) return clipped;
    return Semantics(label: semanticLabel, image: true, child: clipped);
  }

  Widget _networkImage() {
    return Image.network(
      url,
      key: ValueKey<String>('net:$url'),
      height: height,
      width: width ?? double.infinity,
      fit: fit,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _Placeholder(
          height: height,
          child: SizedBox(
            width: 28.r,
            height: 28.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.nitroBlue,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _Placeholder(
        height: height,
        child: Icon(Icons.broken_image_outlined, size: 36.r, color: AppTheme.inkFaint),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.child, this.height});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 160.h,
      width: double.infinity,
      child: ColoredBox(
        color: AppTheme.mutedSurface,
        child: Center(child: child),
      ),
    );
  }
}
