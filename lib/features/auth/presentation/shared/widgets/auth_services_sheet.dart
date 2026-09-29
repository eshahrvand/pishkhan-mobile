import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_services_grid.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

Future<void> showAuthServicesSheet(BuildContext context) async {
  final cubit = context.read<AuthCubit>();
  final l10n = context.l10n;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.textPrimary.withValues(alpha: .55),
    builder: (sheetContext) => FractionallySizedBox(
      heightFactor: .72,
      child: Material(
        color: context.colors.surfaceSubtle,
        borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            AppBottomSheetHeader(
              title: l10n.servicesList,
              showRightIcon: false,
              leftIcon: SvgPicture.asset(AuthAssets.sheetClose),
              onLeftAction: () => Navigator.of(sheetContext).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  AuthServicesSectionTitle(
                    title: l10n.guestServices,
                    dividerAsset: AuthAssets.sectionDivider1,
                  ),
                  const SizedBox(height: 16),
                  AuthServicesRow(
                    items: [
                      AuthServiceItemData(
                        l10n.assetReport,
                        AuthAssets.assetReport,
                      ),
                      AuthServiceItemData(
                        l10n.changeMobileService,
                        AuthAssets.changeMobile,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          cubit.openChangePhone();
                        },
                      ),
                      AuthServiceItemData(
                        l10n.requestStatus,
                        AuthAssets.requestStatus,
                      ),
                      AuthServiceItemData(
                        l10n.inheritance,
                        AuthAssets.inheritance,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  AuthServicesSectionTitle(
                    title: l10n.relatedLinks,
                    dividerAsset: AuthAssets.sectionDivider2,
                  ),
                  const SizedBox(height: 16),
                  AuthServicesRow(
                    items: [
                      AuthServiceItemData(
                        l10n.mobileBank,
                        AuthAssets.mobileBank,
                      ),
                      AuthServiceItemData(
                        l10n.internetBank,
                        AuthAssets.internetBank,
                      ),
                      AuthServiceItemData(
                        l10n.memberContactCenter,
                        AuthAssets.callCenter,
                      ),
                      AuthServiceItemData(
                        l10n.resalatApp,
                        AuthAssets.resalatService,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AuthServicesRow(
                    fillEmptySlots: true,
                    items: [
                      AuthServiceItemData(
                        l10n.securityTips,
                        AuthAssets.security,
                      ),
                      AuthServiceItemData(
                        l10n.updateGuide,
                        AuthAssets.updateGuide,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
