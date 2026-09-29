import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class AuthPhoneOwnershipNotice extends StatelessWidget {
  const AuthPhoneOwnershipNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        children: [
          SvgPicture.asset(AuthAssets.infoCircle, width: 20, height: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.phoneOwnershipNotice,
              style: AppTypography.labelMedium.copyWith(
                color: context.colors.textSecondary,
                height: 18 / 12,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
