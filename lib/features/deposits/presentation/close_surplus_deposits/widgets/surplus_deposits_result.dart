import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../shared/certificate_fields.dart';

class SurplusDepositsResult extends StatelessWidget {
  const SurplusDepositsResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.brand100,
                border: Border.all(color: AppPalette.brand50, width: 8),
              ),
              child: const Center(
                child: AvpImage(image: AppAssets.surplusDepositsEmpty),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.current.surplusDepositsEmptyTitle,
              textAlign: TextAlign.center,
              style: certificateValueStyle(context)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              S.current.surplusDepositsEmptyBody,
              textAlign: TextAlign.center,
              style: certificateValueStyle(context),
            ),
          ],
        ),
      ),
    );
  }
}
