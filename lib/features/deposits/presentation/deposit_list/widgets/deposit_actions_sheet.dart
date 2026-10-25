import 'package:pishkhan_mobile/core/config/constant.dart';

import '../deposit_list_action.dart';
export '../deposit_list_action.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import 'deposit_sheet.dart';
import 'deposit_ui.dart';

Future<DepositListAction?> showDepositActionsSheet(BuildContext context) =>
    showDepositSheet<DepositListAction>(context, const DepositActionsSheet());

class DepositActionsSheet extends StatelessWidget {
  const DepositActionsSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBottomSheetHeader(type: AppBottomSheetHeaderType.handleOnly),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final action in DepositListAction.values) ...[
                if (action != DepositListAction.accountDetails)
                  const DepositDivider(),
                Semantics(
                  button: true,
                  label: getDepositActionLabel(action),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.pop(action),
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          // Chat is a cropped glyph placed at its authored 4.17% offset.
                          action == DepositListAction.sms
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
                                        getDepositActionAsset(action),
                                        size: 21.494,
                                      ),
                                    ),
                                  ),
                                )
                              : depositIcon(getDepositActionAsset(action)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              getDepositActionLabel(action),
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

String getDepositActionLabel(DepositListAction action) => switch (action) {
  DepositListAction.accountDetails => S.current.depositListAccountDetails,
  DepositListAction.linkedCards => S.current.depositListLinkedCards,
  DepositListAction.statement => S.current.depositListStatement,
  DepositListAction.certificate => S.current.financialCertificate,
  DepositListAction.sms => S.current.depositListSms,
  DepositListAction.agent => S.current.depositsAgent,
  DepositListAction.block => S.current.depositListBlock,
  DepositListAction.linkedLoans => S.current.depositsLinkedLoans,
};

String getDepositActionAsset(DepositListAction action) => switch (action) {
  DepositListAction.accountDetails =>
    '${AppConstants.baseImage}card_features_info.svg',
  DepositListAction.linkedCards =>
    '${AppConstants.baseImage}deposit_list_cards.svg',
  DepositListAction.statement =>
    '${AppConstants.baseImage}deposit_list_statement.svg',
  DepositListAction.certificate =>
    '${AppConstants.baseImage}deposit_list_certificate.svg',
  DepositListAction.sms => '${AppConstants.baseImage}deposit_list_sms.svg',
  DepositListAction.agent => '${AppConstants.baseImage}deposit_list_agent.svg',
  DepositListAction.block => '${AppConstants.baseImage}deposit_list_block.svg',
  DepositListAction.linkedLoans =>
    '${AppConstants.baseImage}deposit_list_loans.svg',
};
