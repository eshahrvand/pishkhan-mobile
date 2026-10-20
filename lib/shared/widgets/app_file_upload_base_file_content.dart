import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import 'app_file_upload_base.dart';

class AppFileUploadBaseFileContent extends StatelessWidget {
  const AppFileUploadBaseFileContent({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.onDelete,
    required this.progress,
    required this.state,
  });
  final String fileName;
  final String fileSize;
  final VoidCallback? onDelete;
  final double progress;
  final AppFileUploadState state;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                child: AvpImage(
                  image: AppAssets.fileUploadFile,
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
              Text(
                fileSize,
                textDirection: TextDirection.ltr,
                style: _bodyStyle,
              ),
              const SizedBox(height: 4),
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  Expanded(
                    child: AppProgressIndicator(
                      value: state == AppFileUploadState.uploaded
                          ? 1
                          : progress,
                      width: 191,
                      fillAlignment: Alignment.centerLeft,
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
        Semantics(
          container: true,
          button: true,
          label: S.current.transferDeleteFile,
          child: InkWell(
            onTap: onDelete,
            child: AvpImage(
              image: AppAssets.fileUploadTrash,
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }

  TextStyle get _fileNameStyle => _bodyStyle.copyWith(
    color: AppPalette.gray700,
    fontWeight: FontWeight.w500,
  );
  TextStyle get _bodyStyle => AppTypography.bodyMedium.copyWith(
    color: AppPalette.gray600,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0,
  );
}
