import 'dart:ui';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_services_grid.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
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
            leftIcon: AvpImage(image: AuthAssets.sheetClose),
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
                          image: AuthAssets.sectionDivider1,
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
                        AuthAssets.assetReport,
                      ),
                      item(
                        'identity.changePhone',
                        S.current.changeMobileService,
                        AuthAssets.changeMobile,
                      ),
                      item(
                        'requests.status',
                        S.current.requestStatus,
                        AuthAssets.requestStatus,
                        mutedLabel: true,
                      ),
                      item(
                        'identity.inheritance',
                        S.current.inheritance,
                        AuthAssets.inheritance,
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
                          image: AuthAssets.sectionDivider2,
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
                        AuthAssets.mobileBank,
                      ),
                      item(
                        'links.internetBank',
                        S.current.internetBank,
                        AuthAssets.internetBank,
                      ),
                      item(
                        'links.callCenter',
                        S.current.memberContactCenter,
                        AuthAssets.callCenter,
                      ),
                      item(
                        'links.resalat',
                        S.current.resalatApp,
                        AuthAssets.resalatService,
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
                        AuthAssets.security,
                      ),
                      item(
                        'links.updateGuide',
                        S.current.updateGuide,
                        AuthAssets.updateGuide,
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
