import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../data/repositories/mock_card_services_repository.dart';
import '../../../domain/entities/card_service_data.dart';
import '../../../domain/repositories/card_services_repository.dart';
import '../cubit/change_card_deposit_cubit.dart';
import '../widgets/change_card_deposit_form.dart';
import '../../shared/card_service_widgets.dart';

class ChangeCardDepositScreen extends StatelessWidget {
  const ChangeCardDepositScreen({
    super.key,
    this.repository,
    this.initialCardNumber,
    this.onTermsRequested,
    this.onCompleted,
  });

  final CardServicesRepository? repository;
  final String? initialCardNumber;
  final VoidCallback? onTermsRequested;
  final ValueChanged<CardServiceReceipt>? onCompleted;

  @override
  Widget build(BuildContext context) => BlocProvider<ChangeCardDepositCubit>(
    // A changed adapter/seed starts a new flow; ordinary rebuilds retain it.
    key: ValueKey((repository, initialCardNumber)),
    lazy: false,
    create: (_) => ChangeCardDepositCubit(
      initialState: const ChangeCardDepositState(),
      repository: repository ?? MockCardServicesRepository(),
      initialCardNumber: initialCardNumber,
    )..load(),
    child: _ChangeCardDepositView(
      onTermsRequested: onTermsRequested,
      onCompleted: onCompleted,
    ),
  );
}

class _ChangeCardDepositView extends StatelessWidget {
  const _ChangeCardDepositView({this.onTermsRequested, this.onCompleted});
  final VoidCallback? onTermsRequested;
  final ValueChanged<CardServiceReceipt>? onCompleted;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocConsumer<ChangeCardDepositCubit, ChangeCardDepositState>(
      listenWhen: (old, next) => old.submissionStatus != next.submissionStatus,
      listener: (context, state) {
        if (state.receipt != null) onCompleted?.call(state.receipt!);
      },
      builder: (context, state) {
        final cubit = context.read<ChangeCardDepositCubit>();
        return PopScope(
          canPop: state.submissionStatus != RequestStatus.loading,
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: context.l10n.changeCardDepositTitle,
                    showLeadingActions: false,
                    trailingIcon: cardServiceIcon(
                      AppAssets.cardFeaturesBack,
                      size: 24,
                    ),
                    trailingTooltip: context.l10n.backLabel,
                    onTrailingPressed: () {
                      if (state.submissionStatus != RequestStatus.loading) {
                        NavigationActions.back(context);
                      }
                    },
                  ),
                  Expanded(
                    child:
                        (state.status == RequestStatus.success &&
                            !state.isEmpty &&
                            state.receipt == null)
                        ? ChangeCardDepositForm(cubit: cubit, state: state)
                        : CardServiceStatus(
                            status: state.status,
                            empty: state.isEmpty,
                            receipt: state.receipt,
                            onRetry: cubit.load,
                          ),
                  ),
                  if ((state.status == RequestStatus.success &&
                      !state.isEmpty &&
                      state.receipt == null))
                    CardServiceFooter(
                      label: context.l10n.cardServiceSubmit,
                      loading: state.submissionStatus == RequestStatus.loading,
                      onSubmit: state.canSubmit ? cubit.submit : null,
                      termsAccepted: state.termsAccepted,
                      onTermsChanged: state.editable ? cubit.acceptTerms : null,
                      onTermsRequested: onTermsRequested,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
