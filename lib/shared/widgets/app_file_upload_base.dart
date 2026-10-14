import 'app_file_upload_base_empty_content.dart';
import 'app_file_upload_base_file_content.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

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
      child: empty
          ? AppFileUploadBaseEmptyContent()
          : AppFileUploadBaseFileContent(
              fileName: fileName,
              fileSize: fileSize,
              onDelete: onDelete,
              progress: progress,
              state: state,
            ),
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
