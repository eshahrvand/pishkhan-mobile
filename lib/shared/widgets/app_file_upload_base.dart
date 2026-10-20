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
    this.emptyPrompt,
    this.emptyAction,
    this.emptySuffix,
    this.fileRequirements,
  }) : assert(progress >= 0 && progress <= 1);

  final AppFileUploadState state;
  final String fileName;
  final String fileSize;
  final double progress;
  final VoidCallback? onSelect;
  final VoidCallback? onDelete;
  final String? emptyPrompt;
  final String? emptyAction;
  final String? emptySuffix;
  final String? fileRequirements;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: context.colors.surface,
        borderRadius: AppRadius.borderSm,
        child: Container(
          width: 343,
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.borderSubtle),
            borderRadius: AppRadius.borderSm,
          ),
          child: state == AppFileUploadState.empty
              ? InkWell(
                  onTap: onSelect,
                  borderRadius: AppRadius.borderSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: AppFileUploadBaseEmptyContent(
                      prompt: emptyPrompt,
                      action: emptyAction,
                      suffix: emptySuffix,
                      requirements: fileRequirements,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppFileUploadBaseFileContent(
                    fileName: fileName,
                    fileSize: fileSize,
                    onDelete: onDelete,
                    progress: progress,
                    state: state,
                  ),
                ),
        ),
      ),
    );
  }
}
