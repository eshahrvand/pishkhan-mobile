import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../data/repositories/mock_card_services_repository.dart';
import '../../../domain/entities/card_service_data.dart';
import '../../../domain/repositories/card_services_repository.dart';
import '../cubit/change_card_deposit_cubit.dart';
import '../widgets/change_card_deposit_form.dart';
import '../../shared/card_service_widgets.dart';

class ChangeCardDepositScreen extends StatefulWidget {
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
  State<ChangeCardDepositScreen> createState() =>
      _ChangeCardDepositScreenState();
}

class _ChangeCardDepositScreenState extends State<ChangeCardDepositScreen> {
  // This State owns the Cubit; input changes restart the flow without widget keys.
  late ChangeCardDepositCubit _cubit;
  ChangeCardDepositCubit _createCubit() => ChangeCardDepositCubit(
    initialState: const ChangeCardDepositState.initial(),
    repository: widget.repository ?? MockCardServicesRepository(),
    initialCardNumber: widget.initialCardNumber,
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChangeCardDepositScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.initialCardNumber != widget.initialCardNumber) {
      _cubit.close();
      _cubit = _createCubit();
    }
  }

  @override
  void initState() {
    super.initState();
    _cubit = _createCubit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChangeCardDepositCubit>.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<ChangeCardDepositCubit, ChangeCardDepositState>(
          listenWhen: (old, next) =>
              old.submissionStatus != next.submissionStatus,
          listener: (context, state) {
            if (state.receipt != null) widget.onCompleted?.call(state.receipt!);
          },
          builder: (context, state) {
            return PopScope(
              canPop: state.submissionStatus != RequestStatus.loading,
              child: Scaffold(
                backgroundColor: context.colors.surfaceSubtle,
                body: SafeArea(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: S.current.changeCardDepositTitle,
                        showLeadingActions: false,
                        trailingIcon: cardServiceIcon(
                          AppAssets.cardFeaturesBack,
                          size: 24,
                        ),
                        trailingTooltip: S.current.backLabel,
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
                            ? ChangeCardDepositForm(
                                cubit: context.read<ChangeCardDepositCubit>(),
                                state: state,
                              )
                            : CardServiceStatus(
                                status: state.status,
                                empty: state.isEmpty,
                                receipt: state.receipt,
                                onRetry: context
                                    .read<ChangeCardDepositCubit>()
                                    .load,
                              ),
                      ),
                      if ((state.status == RequestStatus.success &&
                          !state.isEmpty &&
                          state.receipt == null))
                        CardServiceFooter(
                          label: S.current.cardServiceSubmit,
                          loading:
                              state.submissionStatus == RequestStatus.loading,
                          onSubmit: state.canSubmit
                              ? context.read<ChangeCardDepositCubit>().submit
                              : null,
                          termsAccepted: state.termsAccepted,
                          onTermsChanged: state.editable
                              ? context
                                    .read<ChangeCardDepositCubit>()
                                    .acceptTerms
                              : null,
                          onTermsRequested: widget.onTermsRequested,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
