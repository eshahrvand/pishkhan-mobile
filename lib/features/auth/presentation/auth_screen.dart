import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_header.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_identity_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_otp_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_services_sheet.dart';

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
                child: BlocSelector<AuthCubit, AuthState, AuthStep>(
                  selector: (state) => state.step,
                  builder: (context, step) {
                    final cubit = context.read<AuthCubit>();
                    return PopScope(
                      canPop: step == AuthStep.login,
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
                                      step == AuthStep.loginOtp ||
                                          step == AuthStep.changePhoneOtp
                                      ? AuthOtpForm(
                                          key: ValueKey(step),
                                          onAuthenticated: onAuthenticated,
                                        )
                                      : AuthIdentityForm(
                                          key: ValueKey(step),
                                          changePhone:
                                              step == AuthStep.changePhone,
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
