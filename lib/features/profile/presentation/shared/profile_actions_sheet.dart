import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

Future<T?> showProfileActionsSheet<T>(
  BuildContext context, {
  required String editLabel,
  required String deleteLabel,
  required T editAction,
  required T deleteAction,
}) {
  return showAppServiceSheet<T>(
    context,
    ProfileActionsSheet(
      editLabel: editLabel,
      deleteLabel: deleteLabel,
      editAction: editAction,
      deleteAction: deleteAction,
    ),
  );
}

class ProfileActionsSheet<T> extends StatelessWidget {
  const ProfileActionsSheet({
    super.key,
    required this.editLabel,
    required this.deleteLabel,
    required this.editAction,
    required this.deleteAction,
  });
  final String editLabel;
  final String deleteLabel;
  final T editAction;
  final T deleteAction;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBottomSheetHeader(
          type: AppBottomSheetHeaderType.handleOnly,
          showLeftAction: false,
          showRightIcon: false,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(editAction);
                },
                child: SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            1.5,
                            2.25,
                            1.8746,
                            1.5453,
                          ),
                          child: AvpImage(
                            image: '${AppConstants.baseImage}profile_edit.svg',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        editLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 22 / 14,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Preserve the source stroke without adding layout height.
              SizedBox(
                height: 0,
                child: OverflowBox(
                  minHeight: .5,
                  maxHeight: .5,
                  child: AvpImage(
                    image:
                        '${AppConstants.baseImage}profile_actions_divider.svg',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(deleteAction);
                },
                child: SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      AvpImage(
                        image: '${AppConstants.baseImage}profile_trash.svg',
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        deleteLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 22 / 14,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
