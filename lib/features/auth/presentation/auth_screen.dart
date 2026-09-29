import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_header.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_identity_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_otp_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/shared/widgets/auth_services_sheet.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, this.onAuthenticated});

  final VoidCallback? onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        return Scaffold(
          backgroundColor: context.colors.surface,
          body: SafeArea(
            child: Column(
              children: [
                AuthHeader(
                  state: state,
                  onBack: cubit.backToChangePhoneForm,
                  onClose: cubit.closeChangePhone,
                  onMenu: () => showAuthServicesSheet(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 343),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: state.isOtp
                              ? AuthOtpForm(
                                  key: ValueKey(state.step),
                                  state: state,
                                  onAuthenticated: onAuthenticated,
                                )
                              : AuthIdentityForm(
                                  key: ValueKey(state.step),
                                  state: state,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
