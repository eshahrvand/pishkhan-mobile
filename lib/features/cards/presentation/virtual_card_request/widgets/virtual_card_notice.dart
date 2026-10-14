import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';


import 'virtual_card_styles.dart';
import 'virtual_card_icon.dart';

class VirtualCardNotice extends StatelessWidget {
  const VirtualCardNotice({super.key, this.contentKey, required this.text});
  final Key? contentKey;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      key: contentKey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.blueGray100,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VirtualCardIcon(path: AppAssets.passwordCameraInfo),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: virtualCardLabelStyle(context)
                  .copyWith(color: AppPasswordServiceColors.body),
            ),
          ),
        ],
      ),
    );
  }
}
