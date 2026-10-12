import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.onMenu, super.key});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Stack(
      children: [
        PositionedDirectional(
          start: 4,
          top: 4,
          child: AppButton(
            key: const Key('auth_menu_button'),
            onPressed: onMenu,
            icon: SvgPicture.asset(AuthAssets.menu, width: 24, height: 24),
            variant: AppButtonVariant.text,
            size: AppButtonSize.xl,
            semanticLabel: context.l10n.servicesMenuLabel,
          ),
        ),
        PositionedDirectional(
          end: 16,
          top: 16,
          child: SizedBox(
            width: 22,
            height: 24,
            child: SvgPicture.asset(
              AuthAssets.resalatLogo,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SvgPicture.asset(
            AuthAssets.headerDivider,
            height: .8,
            fit: BoxFit.fill,
          ),
        ),
      ],
    ),
  );
}
