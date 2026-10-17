import '../widgets/auth_header.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_identity_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_otp_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_services_sheet.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({
    super.key,
    this.initialState = const AuthState.initial(),
    this.onAuthenticated,
    this.onGuestServiceRequested,
  });

  final AuthState initialState;
  final VoidCallback? onAuthenticated;
  final ValueChanged<String>? onGuestServiceRequested;

  Future<void> _handleEffect(BuildContext context, AuthState state) async {
    switch (state.effect) {
      case AuthServicesRequested():
        final id = await showAuthServicesSheet(context);
        if (context.mounted) {
          context.read<AuthCubit>().selectGuestService(id);
        }
      case AuthGuestServiceRequested(:final id):
        onGuestServiceRequested?.call(id);
      case AuthOtpRequested():
        FocusManager.instance.primaryFocus?.unfocus();
      case AuthCompleted():
        FocusManager.instance.primaryFocus?.unfocus();
        onAuthenticated?.call();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocProvider(
      create: (_) => AuthCubit(initialState: initialState),
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: _handleEffect,
        child: Theme(
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
                      child: AvpImage(
                        image: AuthAssets.background,
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
                        return PopScope(
                          canPop: state.step == AuthStep.login,
                          onPopInvokedWithResult: (didPop, result) {
                            if (!didPop) context.read<AuthCubit>().back();
                          },
                          child: Column(
                            children: [
                              AuthHeader(
                                onMenu: context
                                    .read<AuthCubit>()
                                    .requestServices,
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
                                              state.step ==
                                                  AuthStep.changePhoneOtp
                                          ? AuthOtpForm(
                                              // Reset controllers when switching between login and change-phone OTP.
                                              key: ValueKey(state.step),
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
        ),
      ),
    );
  }
}
