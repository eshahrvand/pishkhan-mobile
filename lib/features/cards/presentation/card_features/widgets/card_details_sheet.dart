import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/listed_card.dart';
import 'card_features_ui.dart';
import 'card_feature_divider.dart';
import 'card_details_row.dart';

class CardDetailsSheet extends StatelessWidget {
  const CardDetailsSheet({super.key, required this.card});
  final ListedCard card;
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
              CardDetailsRow(
                label: S.current.cardFeatureNumber,
                value: card.number,
                textDirection: TextDirection.ltr,
              ),
              const CardFeatureDivider(),
              CardDetailsRow(
                label: S.current.cardFeatureIban,
                value: card.iban,
                textDirection: TextDirection.ltr,
              ),
              const CardFeatureDivider(),
              CardDetailsRow(
                label: S.current.cardFeatureDeposit,
                value: card.linkedDeposit,
                textDirection: TextDirection.ltr,
              ),
              const CardFeatureDivider(),
              CardDetailsRow(
                label: S.current.cardFeatureDepositType,
                value: card.depositTypeKey == 'qarz'
                    ? S.current.cardFeatureQarz
                    : card.depositTypeKey,
              ),
              const CardFeatureDivider(),
              CardDetailsRow(
                label: S.current.cardFeatureExpiry,
                value: card.expiry,
              ),
              const CardFeatureDivider(),
              CardDetailsRow(
                label: S.current.cardFeatureStatus,
                value: statusLabel(card.status),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: AppButton(
            onPressed: () => Navigator.of(context).pop(),
            label: S.current.backLabel,
            size: AppButtonSize.lg,
          ),
        ),
      ],
    );
  }
}
