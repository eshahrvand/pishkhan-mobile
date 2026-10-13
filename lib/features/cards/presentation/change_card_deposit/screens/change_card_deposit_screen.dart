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
  late ChangeCardDepositCubit cubit = _createCubit();

  ChangeCardDepositCubit _createCubit() => ChangeCardDepositCubit(
    repository: widget.repository ?? MockCardServicesRepository(),
    initialCardNumber: widget.initialCardNumber,
  )..load();

  @override
  void didUpdateWidget(covariant ChangeCardDepositScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.initialCardNumber != widget.initialCardNumber) {
      cubit.close();
      cubit = _createCubit();
    }
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocConsumer<ChangeCardDepositCubit, ChangeCardDepositState>(
      bloc: cubit,
      listenWhen: (old, next) => old.submissionStatus != next.submissionStatus,
      listener: (context, state) {
        if (state.receipt != null) widget.onCompleted?.call(state.receipt!);
      },
      builder: (context, state) {
        final loading = state.submissionStatus == RequestStatus.loading;
        final empty =
            state.catalog?.cards.isEmpty == true ||
            state.catalog?.deposits.isEmpty == true;
        final form =
            state.status == RequestStatus.success &&
            !empty &&
            state.receipt == null;
        return PopScope(
          canPop: !loading,
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
                      if (!loading) NavigationActions.back(context);
                    },
                  ),
                  Expanded(
                    child: form
                        ? ChangeCardDepositForm(cubit: cubit, state: state)
                        : CardServiceStatus(
                            status: state.status,
                            empty: empty,
                            receipt: state.receipt,
                            onRetry: cubit.load,
                          ),
                  ),
                  if (form)
                    CardServiceFooter(
                      label: context.l10n.cardServiceSubmit,
                      loading: loading,
                      onSubmit: state.canSubmit ? cubit.submit : null,
                      termsAccepted: state.termsAccepted,
                      onTermsChanged: state.editable ? cubit.acceptTerms : null,
                      onTermsRequested: widget.onTermsRequested,
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
