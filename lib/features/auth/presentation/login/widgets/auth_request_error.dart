import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/auth_cubit.dart';

class AuthRequestError extends StatelessWidget {
  const AuthRequestError({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.failure != current.failure,
      builder: (context, state) {
        if (state.failure == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
            liveRegion: true,
            child: Text(
              switch (state.failure!.code) {
                'auth.otp_rejected' => S.current.authOtpRejected,
                'auth.change_phone_unavailable' =>
                  S.current.authChangePhoneUnavailable,
                final code when code.startsWith('network.') =>
                  S.current.authNetworkError,
                _ => S.current.authRequestFailed,
              },
              style: Theme.of(context).textTheme.bodySmall!
                  .copyWith(color: context.colors.error),
            ),
          ),
        );
      },
    );
  }
}
