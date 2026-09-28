import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppFileUploadState { empty, uploading, uploaded }

/// Figma file-upload field in empty, uploading, and uploaded states.
class AppFileUploadBase extends StatelessWidget {
  const AppFileUploadBase({
    super.key,
    this.state = AppFileUploadState.empty,
    this.fileName = 'حقوق و مزایای اسفند ماه ۱۴۰۴ تیم مارکتینگ.XLS',
    this.fileSize = '16 MB',
    this.progress = .4,
    this.onSelect,
    this.onDelete,
  }) : assert(progress >= 0 && progress <= 1);

  final AppFileUploadState state;
  final String fileName;
  final String fileSize;
  final double progress;
  final VoidCallback? onSelect;
  final VoidCallback? onDelete;

  static const _assetPath = 'assets/images/file_upload/';

  @override
  Widget build(BuildContext context) {
    final empty = state == AppFileUploadState.empty;
    final content = Container(
      key: const Key('app_file_upload_base'),
      width: 343,
      padding: empty
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
          : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.white,
        border: Border.all(color: AppPalette.gray200),
        borderRadius: AppRadius.borderSm,
      ),
      child: empty ? _emptyContent() : _fileContent(),
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: empty && onSelect != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSelect,
                borderRadius: AppRadius.borderSm,
                child: content,
              ),
            )
          : content,
    );
  }

  Widget _emptyContent() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppPalette.gray100,
          border: Border.all(color: AppPalette.gray50, width: 6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            '${_assetPath}upload_cloud.svg',
            width: 20,
            height: 20,
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        height: 20,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('برای', style: _bodyStyle),
              const SizedBox(width: 4),
              Text('بارگذاری فایل اینجا', style: _actionStyle),
              const SizedBox(width: 4),
              Text('را کلیک کنید.', style: _bodyStyle),
            ],
          ),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        width: double.infinity,
        height: 18,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'فرمت فایل: XLS  |  حداکثر حجم: ۱۰۰ KB',
            textAlign: TextAlign.center,
            style: _supportingStyle,
          ),
        ),
      ),
    ],
  );

  Widget _fileContent() => Row(
    textDirection: TextDirection.ltr,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 28,
        height: 28,
        child: OverflowBox(
          minWidth: 32,
          maxWidth: 32,
          minHeight: 32,
          maxHeight: 32,
          child: Container(
            decoration: BoxDecoration(
              color: AppPalette.brand100,
              border: Border.all(color: AppPalette.brand50, width: 4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                '${_assetPath}file.svg',
                width: 16,
                height: 16,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              textDirection: TextDirection.ltr,
              style: _fileNameStyle,
            ),
            Text(fileSize, textDirection: TextDirection.ltr, style: _bodyStyle),
            const SizedBox(height: 4),
            Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: AppProgressIndicator(
                    value: state == AppFileUploadState.uploaded ? 1 : progress,
                    width: 191,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  state == AppFileUploadState.uploaded
                      ? '100%'
                      : '${(progress * 100).round()}%',
                  style: _fileNameStyle,
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(width: 4),
      InkWell(
        key: const Key('app_file_upload_delete'),
        onTap: onDelete,
        child: SvgPicture.asset(
          '${_assetPath}trash.svg',
          width: 20,
          height: 20,
        ),
      ),
    ],
  );

  TextStyle get _bodyStyle => AppTypography.bodyMedium.copyWith(
    color: AppPalette.gray600,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0,
  );

  TextStyle get _actionStyle => _bodyStyle.copyWith(
    color: AppPalette.brand700,
    fontWeight: FontWeight.w600,
  );

  TextStyle get _supportingStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray600,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle get _fileNameStyle => _bodyStyle.copyWith(
    color: AppPalette.gray700,
    fontWeight: FontWeight.w500,
  );
}
