import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class AppLoanCardCopyButton extends StatelessWidget {
  const AppLoanCardCopyButton({super.key, required this.onCopyLoanNumber});
  final VoidCallback? onCopyLoanNumber;

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox.square(
      dimension: 16,
      child: AvpImage(image: AppAssets.loanCardCopy, fit: BoxFit.contain),
    );
    return onCopyLoanNumber == null
        ? KeyedSubtree(key: const Key('app_loan_card_copy'), child: icon)
        : InkWell(
            key: const Key('app_loan_card_copy'),
            onTap: onCopyLoanNumber,
            child: icon,
          );
  }
}
