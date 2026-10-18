import 'card_feature_divider.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../card_feature_action.dart';
import 'card_features_ui.dart';

class CardActionsSheet extends StatelessWidget {
  const CardActionsSheet({super.key});
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
              for (final action in const [
                CardFeatureAction.details,
                CardFeatureAction.reissue,
                CardFeatureAction.changeDeposit,
                CardFeatureAction.block,
              ]) ...[
                if (action != CardFeatureAction.details)
                  const CardFeatureDivider(),
                InkWell(
                  onTap: () => Navigator.of(context).pop(action),
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        cardFeatureIcon(actionAsset(action), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            actionLabel(action),
                            style: AppTypography.labelLarge.copyWith(
                              height: 18 / 14,
                              letterSpacing: 0,
                              color: AppDashboardColors.sectionText,
                            ),
                          ),
                        ),
                      ],
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
