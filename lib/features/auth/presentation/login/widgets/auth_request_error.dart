import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/auth_cubit.dart';

/// Keeps the existing unconnected change-phone feedback outside Login API effects.
class AuthRequestError extends StatelessWidget {
  const AuthRequestError({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.failure != current.failure,
      builder: (context, state) {
        if (state.failure?.code != 'auth.change_phone_unavailable') {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
            liveRegion: true,
            child: Text(
              S.current.authChangePhoneUnavailable,
              style: Theme.of(context).textTheme.bodySmall!
                  .copyWith(color: context.colors.error),
            ),
          ),
        );
      },
    );
  }
}
