import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'virtual_card_styles.dart';
import 'virtual_card_icon.dart';

class VirtualCardNotice extends StatelessWidget {
  const VirtualCardNotice({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.blueGray100,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VirtualCardIcon(
            path: '${AppConstants.baseImage}password_camera_info.svg',
          ),
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
