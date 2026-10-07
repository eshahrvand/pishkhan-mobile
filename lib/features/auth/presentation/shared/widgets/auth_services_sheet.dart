import 'dart:ui';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_services_grid.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

Future<void> showAuthServicesSheet(
  BuildContext context, {
  ValueChanged<String>? onServiceRequested,
}) async {
  final cubit = context.read<AuthCubit>();
  final colors = context.colors;
  final viewport = MediaQuery.of(context);
  FocusManager.instance.primaryFocus?.unfocus();
  await showModalBottomSheet<void>(
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
            onClose: () => Navigator.of(sheetContext).pop(),
            onServiceRequested: (id) {
              Navigator.of(sheetContext).pop();
              if (id == 'identity.changePhone') {
                cubit.openChangePhone();
              } else {
                onServiceRequested?.call(id);
              }
            },
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
    final l10n = context.l10n;
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
      key: const Key('auth_services_sheet'),
      color: context.colors.surfaceSubtle,
      borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AppBottomSheetHeader(
            title: l10n.servicesList,
            showRightIcon: false,
            leftIcon: SvgPicture.asset(AuthAssets.sheetClose),
            onLeftAction: onClose,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthServicesSectionTitle(
                    title: l10n.guestServices,
                    dividerAsset: AuthAssets.sectionDivider1,
                  ),
                  const SizedBox(height: 16),
                  AuthServicesRow(
                    items: [
                      item(
                        'deposits.assetReport',
                        l10n.assetReport,
                        AuthAssets.assetReport,
                      ),
                      item(
                        'identity.changePhone',
                        l10n.changeMobileService,
                        AuthAssets.changeMobile,
                      ),
                      item(
                        'requests.status',
                        l10n.requestStatus,
                        AuthAssets.requestStatus,
                        mutedLabel: true,
                      ),
                      item(
                        'identity.inheritance',
                        l10n.inheritance,
                        AuthAssets.inheritance,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AuthServicesSectionTitle(
                    title: l10n.relatedLinks,
                    dividerAsset: AuthAssets.sectionDivider2,
                  ),
                  const SizedBox(height: 16),
                  AuthServicesRow(
                    items: [
                      item(
                        'links.mobileBank',
                        l10n.mobileBank,
                        AuthAssets.mobileBank,
                      ),
                      item(
                        'links.internetBank',
                        l10n.internetBank,
                        AuthAssets.internetBank,
                      ),
                      item(
                        'links.callCenter',
                        l10n.memberContactCenter,
                        AuthAssets.callCenter,
                      ),
                      item(
                        'links.resalat',
                        l10n.resalatApp,
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
                        l10n.securityTips,
                        AuthAssets.security,
                      ),
                      item(
                        'links.updateGuide',
                        l10n.updateGuide,
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
