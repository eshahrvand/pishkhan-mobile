import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    required this.state,
    required this.onBack,
    required this.onClose,
    required this.onMenu,
    super.key,
  });

  final AuthState state;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: AppShadows.sm,
      ),
      child: state.isChangePhone
          ? Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  l10n.changeMobileTitle,
                  style: AppTypography.titleMedium.copyWith(
                    color: context.colors.textPrimary,
                    fontSize: 16,
                    height: 24 / 16,
                    letterSpacing: 0,
                  ),
                ),
                if (state.step == AuthStep.changePhoneOtp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _HeaderIconButton(
                      key: const Key('auth_back_button'),
                      asset: '$authAssetPath/back.svg',
                      label: l10n.backLabel,
                      onPressed: onBack,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _HeaderIconButton(
                    key: const Key('auth_close_button'),
                    asset: '$authAssetPath/close.svg',
                    label: l10n.closeLabel,
                    onPressed: onClose,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const _BrandLogo(),
                const Spacer(),
                _HeaderIconButton(
                  key: const Key('auth_menu_button'),
                  asset: '$authAssetPath/menu.svg',
                  label: l10n.servicesMenuLabel,
                  onPressed: onMenu,
                ),
              ],
            ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.surfaceSubtle,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            '$authAssetPath/resalat_logo.svg',
            width: 32,
            height: 32,
          ),
        ),
        const SizedBox(width: 10),
        SvgPicture.asset(
          '$authAssetPath/resalat_wordmark.svg',
          width: 152,
          height: 17,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.asset,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String asset;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(asset),
      variant: AppButtonVariant.text,
      size: AppButtonSize.md,
      semanticLabel: label,
    );
  }
}
