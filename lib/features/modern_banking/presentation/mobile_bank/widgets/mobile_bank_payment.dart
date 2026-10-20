import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import '../cubit/mobile_bank_cubit.dart';

class MobileBankPayment extends StatelessWidget {
  const MobileBankPayment({super.key, required this.state});
  final MobileBankState state;
  @override
  Widget build(BuildContext context) {
    return AppInvoice(
      totalAmount: CurrencyFormatter.format(state.totalRial),
      walletBalance: CurrencyFormatter.format(state.catalog!.walletBalanceRial),
      title: S.current.issuancePayable,
      walletLabel: S.current.issuanceWallet,
      walletSufficientLabel: S.current.issuanceWalletSufficient,
      walletInsufficientLabel: S.current.issuanceWalletInsufficient,
      backgroundColor: context.colors.surface,
      labelColor: context.colors.textTertiary,
      zeroHeightDividers: true,
      lines: [
        AppInvoiceLine(
          id: 'registry',
          label: S.current.modernRegistryFee,
          amount: CurrencyFormatter.format(state.catalog!.registryFeeRial),
          icon: SizedBox.square(
            dimension: 20,
            child: AvpImage(image: AppAssets.modernRegistryFee),
          ),
        ),
        AppInvoiceLine(
          id: 'identity',
          label: S.current.issuanceIdentityFee,
          amount: CurrencyFormatter.format(state.catalog!.identityFeeRial),
          icon: AppInvoiceIcons.identityVideo(),
        ),
        AppInvoiceLine(
          id: 'password',
          label: S.current.modernPasswordFee,
          amount: CurrencyFormatter.format(state.catalog!.passwordFeeRial),
          icon: SizedBox.square(
            dimension: 20,
            child: AvpImage(image: AppAssets.modernPasswordFee),
          ),
        ),
      ],
      isExpanded: state.isInvoiceExpanded,
      isWalletBalanceSufficient: state.isWalletSufficient,
      onExpandedChanged: (value) {
        context.read<MobileBankCubit>().toggleInvoice(value);
      },
    );
  }
}
