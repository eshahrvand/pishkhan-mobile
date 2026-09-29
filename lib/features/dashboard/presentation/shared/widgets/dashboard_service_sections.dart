import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_assets.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

class DashboardServiceSections extends StatelessWidget {
  const DashboardServiceSections({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        AppServiceGridCard(
          title: l10n.depositServices,
          headerAction: AppServiceGridIcons.angleLeft(),
          items: [
            _item(
              'deposit-statement',
              l10n.balanceAverageStatement,
              DashboardAssets.depositStatement,
            ),
            _item(
              'deposit-certificate',
              l10n.financialCertificate,
              DashboardAssets.depositCertificate,
            ),
            _item(
              'deposit-representative',
              l10n.introduceRepresentative,
              DashboardAssets.depositRepresentative,
            ),
            _item('deposit-sms', l10n.smsSettings, DashboardAssets.depositSms),
          ],
        ),
        const SizedBox(height: 16),
        AppServiceGridCard(
          title: l10n.cardServices,
          headerAction: AppServiceGridIcons.angleLeft(),
          items: [
            _item(
              'card-issue',
              l10n.issueResalatCard,
              DashboardAssets.cardIssue,
            ),
            _item(
              'card-password',
              l10n.cardPasswordIssue,
              DashboardAssets.cardPassword,
            ),
            _item(
              'card-deposit',
              l10n.changeCardDeposit,
              DashboardAssets.cardLinkedDeposit,
            ),
            _item('card-block', l10n.blockCard, DashboardAssets.cardBlock),
          ],
        ),
        const SizedBox(height: 16),
        AppServiceGridCard(
          title: l10n.loanServices,
          headerAction: AppServiceGridIcons.angleLeft(),
          items: [
            _item(
              'loan-estimate',
              l10n.loanEstimate,
              DashboardAssets.loanCalculator,
            ),
            _item(
              'loan-introduce',
              l10n.introduceLoan,
              DashboardAssets.loanTransfer,
            ),
            _item(
              'loan-consolidate',
              l10n.consolidateDepositCredit,
              DashboardAssets.loanConsolidation,
            ),
            _item(
              'loan-deposit',
              l10n.changeInstallmentDeposit,
              DashboardAssets.loanLinkedDeposit,
            ),
          ],
        ),
      ],
    );
  }

  AppServiceGridItem _item(String id, String label, String asset) =>
      AppServiceGridItem(id: id, label: label, icon: SvgPicture.asset(asset));
}

class DashboardSelectedServices extends StatelessWidget {
  const DashboardSelectedServices({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppServiceGridCard(
      title: l10n.selectedServices,
      type: AppServiceGridCardType.quick,
      headerAction: SvgPicture.asset(
        'assets/images/service_grid/setting.svg',
        width: 20,
        height: 20,
      ),
      items: [
        _item(
          'selected-mobile',
          l10n.mobileBankSettings,
          DashboardAssets.selectedMobile,
        ),
        _item(
          'selected-internet',
          l10n.internetBankSettings,
          DashboardAssets.selectedInternet,
        ),
        _item(
          'selected-cheque',
          l10n.issueChequeBook,
          DashboardAssets.selectedCheque,
        ),
        _item(
          'selected-proxy',
          l10n.proxyDeposit,
          DashboardAssets.selectedProxy,
        ),
      ],
    );
  }

  AppServiceGridItem _item(String id, String label, String asset) =>
      AppServiceGridItem(
        id: id,
        label: label,
        iconSize: const Size(70, 70.5),
        icon: SvgPicture.asset(asset),
      );
}
