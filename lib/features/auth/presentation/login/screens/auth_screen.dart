import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_identity_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_otp_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_services_sheet.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({
    super.key,
    this.onAuthenticated,
    this.onGuestServiceRequested,
  });

  final VoidCallback? onAuthenticated;
  final ValueChanged<String>? onGuestServiceRequested;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Theme(
      data: Theme.of(context).copyWith(
        extensions: [
          ...Theme.of(context).extensions.values
              .where((value) => value is! AppColorScheme),
          colors.copyWith(surfaceDisabled: colors.borderSubtle),
        ],
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: colors.surface,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: colors.surface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppLoginColors.canvas,
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    AuthAssets.background,
                    fit: BoxFit.fitWidth,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.paddingOf(context).top,
                child: ColoredBox(color: colors.surface),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.paddingOf(context).bottom,
                child: ColoredBox(color: colors.surface),
              ),
              SafeArea(
                child: BlocBuilder<AuthCubit, AuthState>(
                  buildWhen: (previous, current) =>
                      previous.step != current.step,
                  builder: (context, state) {
                    final cubit = context.read<AuthCubit>();
                    return PopScope(
                      canPop: state.step == AuthStep.login,
                      onPopInvokedWithResult: (didPop, result) {
                        if (!didPop) cubit.back();
                      },
                      child: Column(
                        children: [
                          AuthHeader(
                            onMenu: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              showAuthServicesSheet(
                                context,
                                onServiceRequested: onGuestServiceRequested,
                              );
                            },
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                16,
                                16,
                                16,
                                24,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 343,
                                  ),
                                  child:
                                      state.step == AuthStep.loginOtp ||
                                          state.step == AuthStep.changePhoneOtp
                                      ? AuthOtpForm(
                                          // Reset controllers when switching between login and change-phone OTP.
                                          key: ValueKey(state.step),
                                          onAuthenticated: onAuthenticated,
                                        )
                                      : AuthIdentityForm(
                                          // Reset controllers when switching between identity forms.
                                          key: ValueKey(state.step),
                                          changePhone:
                                              state.step ==
                                              AuthStep.changePhone,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.onMenu, super.key});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          PositionedDirectional(
            start: 4,
            top: 4,
            child: AppButton(
              onPressed: onMenu,
              icon: SvgPicture.asset(AuthAssets.menu, width: 24, height: 24),
              variant: AppButtonVariant.text,
              size: AppButtonSize.xl,
              semanticLabel: S.current.servicesMenuLabel,
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
}
