import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_credit_card_mockup.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

import '../../../domain/entities/mobile_bank.dart';
import '../cubit/mobile_bank_cubit.dart';

class MobileBankActive extends StatelessWidget {
  const MobileBankActive({super.key, required this.state});
  final MobileBankState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AppCreditCardMockup(
            state: AppCreditCardMockupState.active,
            isCompact: true,
            userName: state.catalog!.username,
          ),
        ),
        const SizedBox(height: 20),
        AppServiceGridCard(
          title: S.current.modernOperations,
          itemSpacing: 6,
          items: [
            AppServiceGridItem(
              id: 'modern-recovery',
              label: S.current.passwordForgot,
              icon: AvpImage(
                image: '${AppConstants.baseImage}modern_service_forgot.svg',
              ),
              onTap: () {
                context.read<MobileBankCubit>().requestDestination(
                  MobileBankDestination.passwordRecovery,
                );
              },
            ),
            AppServiceGridItem(
              id: 'modern-password-guide',
              label: S.current.passwordChange,
              icon: AvpImage(
                image: '${AppConstants.baseImage}modern_service.svg',
              ),
              onTap: () {
                context.read<MobileBankCubit>().requestDestination(
                  MobileBankDestination.passwordGuide,
                );
              },
            ),
            AppServiceGridItem(
              id: 'modern-limits',
              label: S.current.modernLimitsTitle,
              icon: AvpImage(
                image: '${AppConstants.baseImage}modern_service.svg',
              ),
              onTap: () {
                context.read<MobileBankCubit>().requestDestination(
                  MobileBankDestination.transferLimits,
                );
              },
            ),
            AppServiceGridItem(
              id: 'modern-deactivation',
              label: S.current.modernDeactivate,
              icon: AvpImage(
                image: '${AppConstants.baseImage}modern_service.svg',
              ),
              onTap: () {
                context.read<MobileBankCubit>().requestDestination(
                  MobileBankDestination.deactivation,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
