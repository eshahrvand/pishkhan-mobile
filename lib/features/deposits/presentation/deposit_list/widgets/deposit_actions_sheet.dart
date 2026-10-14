import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/listed_deposit.dart';
import 'deposit_sheet.dart';
import 'deposit_ui.dart';

enum DepositListAction {
  accountDetails,
  linkedCards,
  statement,
  certificate,
  sms,
  representative,
  block,
  linkedLoans,
}

class DepositListActionRequest {
  const DepositListActionRequest({required this.action, required this.deposit});
  final DepositListAction action;
  final ListedDeposit deposit;
}

Future<DepositListAction?> showDepositActionsSheet(BuildContext context) =>
    showDepositSheet<DepositListAction>(context, const DepositActionsSheet());

class DepositActionsSheet extends StatelessWidget {
  const DepositActionsSheet({super.key});
  @override
  Widget build(BuildContext context) {
    final labels = [
      S.current.depositListAccountDetails,
      S.current.depositListLinkedCards,
      S.current.depositListStatement,
      S.current.financialCertificate,
      S.current.depositListSms,
      S.current.depositsRepresentative,
      S.current.depositListBlock,
      S.current.depositsLinkedLoans,
    ];
    const assets = [
      AppAssets.cardFeaturesInfo,
      AppAssets.depositFeatureCards,
      AppAssets.depositFeatureStatement,
      AppAssets.depositFeatureCertificate,
      AppAssets.depositFeatureSms,
      AppAssets.depositFeatureRepresentative,
      AppAssets.depositFeatureBlock,
      AppAssets.depositFeatureLoans,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBottomSheetHeader(type: AppBottomSheetHeaderType.handleOnly),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const DepositDivider(),
                Semantics(
                  button: true,
                  label: labels[i],
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.pop(DepositListAction.values[i]),
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          // Chat is a cropped glyph placed at its authored 4.17% offset.
                          i == 4
                              ? SizedBox.square(
                                  dimension: 24,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 1,
                                        top: 1,
                                      ),
                                      child: depositIcon(
                                        assets[i],
                                        size: 21.494,
                                      ),
                                    ),
                                  ),
                                )
                              : depositIcon(assets[i]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              labels[i],
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                    height: 18 / 14,
                                    letterSpacing: 0,
                                    color: context.colors.textPrimary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
