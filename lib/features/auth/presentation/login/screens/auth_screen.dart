import 'package:pishkhan_mobile/core/config/constant.dart';

import '../widgets/auth_header.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_identity_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_otp_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/widgets/auth_services_sheet.dart';

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
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case AuthServicesRequested():
        context.read<AuthCubit>().consumeAuthInteraction();
        final id = await showAuthServicesSheet(context);
        if (context.mounted) {
          context.read<AuthCubit>().selectGuestService(id);
        }
      case AuthGuestServiceRequested(:final id):
        context.read<AuthCubit>().consumeAuthInteraction();
        onGuestServiceRequested?.call(id);
      case AuthOtpRequested():
        context.read<AuthCubit>().consumeAuthInteraction();
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
      create: (_) => AuthCubit(initialState: initialState)..fetchCaptcha(),
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            (previous.effect != current.effect && current.effect != null) ||
            ((previous.captchaStatus != current.captchaStatus &&
                    current.captchaStatus == RequestStatus.failure) ||
                (previous.otpRequestStatus != current.otpRequestStatus &&
                    current.otpRequestStatus == RequestStatus.failure) ||
                (previous.loginStatus != current.loginStatus &&
                    current.loginStatus == RequestStatus.failure)),
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
                        image: '${AppConstants.baseImage}auth_background.png',
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
                          previous.step != current.step ||
                          previous.captchaStatus != current.captchaStatus ||
                          previous.otpRequestStatus !=
                              current.otpRequestStatus ||
                          previous.loginStatus != current.loginStatus,
                      builder: (context, state) {
                        return PopScope(
                          // Login keeps Back unavailable during bank requests.
                          canPop:
                              state.step == AuthStep.login &&
                              state.captchaStatus != RequestStatus.loading &&
                              state.otpRequestStatus != RequestStatus.loading &&
                              state.loginStatus != RequestStatus.loading,
                          onPopInvokedWithResult: (didPop, result) {
                            if (!didPop &&
                                state.captchaStatus != RequestStatus.loading &&
                                state.otpRequestStatus !=
                                    RequestStatus.loading &&
                                state.loginStatus != RequestStatus.loading) {
                              context.read<AuthCubit>().requestBack();
                            }
                          },
                          child: Column(
                            children: [
                              AuthHeader(
                                onMenu:
                                    state.captchaStatus !=
                                            RequestStatus.loading &&
                                        state.otpRequestStatus !=
                                            RequestStatus.loading &&
                                        state.loginStatus !=
                                            RequestStatus.loading
                                    ? context.read<AuthCubit>().requestServices
                                    : null,
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
