import 'package:pishkhan_mobile/core/config/constant.dart';

import 'dart:ui';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_services_grid.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

Future<String?> showAuthServicesSheet(BuildContext context) async {
  final colors = context.colors;
  final viewport = MediaQuery.of(context);
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: colors.textSecondary.withValues(alpha: .8),
    builder: (sheetContext) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: (viewport.size.height - viewport.viewPadding.vertical).clamp(
            0.0,
            528.0,
          ),
          child: AuthServicesSheet(
            onClose: () => sheetContext.pop(),
            onServiceRequested: (id) => sheetContext.pop(id),
          ),
        ),
      ),
    ),
  );
}

class AuthServicesSheet extends StatelessWidget {
  const AuthServicesSheet({
    required this.onClose,
    this.onServiceRequested,
    super.key,
  });
  final VoidCallback onClose;
  final ValueChanged<String>? onServiceRequested;

  @override
  Widget build(BuildContext context) {
    AuthServiceItemData item(
      String id,
      String label,
      String asset, {
      bool mutedLabel = false,
    }) => AuthServiceItemData(
      label,
      asset,
      mutedLabel: mutedLabel,
      onTap: () => onServiceRequested?.call(id),
    );
    return Material(
      color: context.colors.surfaceSubtle,
      borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AppBottomSheetHeader(
            title: S.current.servicesList,
            showRightIcon: false,
            leftIcon: AvpImage(
              image: '${AppConstants.baseImage}auth_sheet_close.svg',
            ),
            onLeftAction: onClose,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          S.current.guestServices,
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(
                                color: AppLoginColors.sectionLabel,
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AvpImage(
                          image:
                              '${AppConstants.baseImage}auth_section_divider_1.svg',
                          height: 1,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AuthServicesRow(
                    items: [
                      item(
                        'deposits.assetReport',
                        S.current.assetReport,
                        '${AppConstants.baseImage}auth_asset_report.svg',
                      ),
                      item(
                        'identity.changePhone',
                        S.current.changeMobileService,
                        '${AppConstants.baseImage}auth_change_mobile.svg',
                      ),
                      item(
                        'requests.status',
                        S.current.requestStatus,
                        '${AppConstants.baseImage}auth_request_status.svg',
                        mutedLabel: true,
                      ),
                      item(
                        'identity.inheritance',
                        S.current.inheritance,
                        '${AppConstants.baseImage}auth_inheritance.svg',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          S.current.relatedLinks,
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(
                                color: AppLoginColors.sectionLabel,
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AvpImage(
                          image:
                              '${AppConstants.baseImage}auth_section_divider_2.svg',
                          height: 1,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AuthServicesRow(
                    items: [
                      item(
                        'links.mobileBank',
                        S.current.mobileBank,
                        '${AppConstants.baseImage}auth_mobile_bank.svg',
                      ),
                      item(
                        'links.internetBank',
                        S.current.internetBank,
                        '${AppConstants.baseImage}auth_internet_bank.svg',
                      ),
                      item(
                        'links.callCenter',
                        S.current.memberContactCenter,
                        '${AppConstants.baseImage}auth_call_center.svg',
                      ),
                      item(
                        'links.resalat',
                        S.current.resalatApp,
                        '${AppConstants.baseImage}auth_resalat_service.svg',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AuthServicesRow(
                    fillEmptySlots: true,
                    items: [
                      item(
                        'links.security',
                        S.current.securityTips,
                        '${AppConstants.baseImage}auth_security.svg',
                      ),
                      item(
                        'links.updateGuide',
                        S.current.updateGuide,
                        '${AppConstants.baseImage}auth_update_guide.svg',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
