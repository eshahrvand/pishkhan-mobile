import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';

import '../../shared/profile_actions_sheet.dart';

import 'package:pishkhan_mobile/shared/widgets/app_decision_sheet.dart';

import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

import '../cubit/addresses_cubit.dart';
import '../widgets/addresses_list.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key, this.onAssistantPressed});
  final VoidCallback? onAssistantPressed;
  void _showRequestFailure(BuildContext context, AddressesState state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message!)));
  }

  Future<void> _handleEffect(BuildContext context, AddressesState state) async {
    switch (state.effect) {
      case AddressEffect.actions:
        context.read<AddressesCubit>().consumeAddressesInteraction();
        final action = await showProfileActionsSheet<AddressAction>(
          context,
          editLabel: S.current.profileEditAddress,
          deleteLabel: S.current.profileDeleteAddress,
          editAction: AddressAction.edit,
          deleteAction: AddressAction.delete,
        );
        if (context.mounted) {
          context.read<AddressesCubit>().applyAddressAction(action);
        }
      case AddressEffect.confirmDeletion:
        context.read<AddressesCubit>().consumeAddressesInteraction();
        await showAppServiceSheet<void>(
          context,
          AppDeleteAddressSheet(
            address: state.selectedAddress!.address.detail,
            postalCode: CurrencyFormatter.toPersianDigits(
              state.selectedAddress!.address.postalCode,
            ),
            title: S.current.profileDeleteAddress,
            prompt: S.current.chequeBookDeletePrompt,
            postalCodeLabel: S.current.issuancePostalCode,
            confirmLabel: S.current.chequeCancelRemove,
            cancelLabel: S.current.dashboardCancel,
            onConfirm: () {
              context.read<AddressesCubit>().submitDeletion(
                state.selectedAddress!,
              );
              Navigator.of(context).pop();
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AddressEffect.minimumAddress:
        context.read<AddressesCubit>().consumeAddressesInteraction();
        await showAppDecisionSheet(
          context,
          message: S.current.profileMinimumAddress,
          confirmLabel: S.current.passwordUnderstood,
          onConfirm: () {
            Navigator.of(context).pop();
          },
        );
      case AddressEffect.editor:
        context.read<AddressesCubit>().consumeAddressesInteraction();
        final address = await ServiceRegistry.openAddressEditor(
          context,
          initialAddress: state.selectedAddress?.address,
          includeContact: true,
          retainHomeAddress: state.retainHomeAddress,
        );
        if (context.mounted) {
          context.read<AddressesCubit>().applyAddressEditor(address);
        }
      case AddressEffect.back:
        NavigationActions.back(context);
      case AddressEffect.assistant:
        context.read<AddressesCubit>().consumeAddressesInteraction();
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressesCubit()..fetchAddresses(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AddressesCubit, AddressesState>(
            listenWhen: (previous, current) =>
                previous.addressesStatus != current.addressesStatus &&
                current.addressesStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<AddressesCubit, AddressesState>(
            listenWhen: (previous, current) =>
                previous.saveStatus != current.saveStatus &&
                current.saveStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<AddressesCubit, AddressesState>(
            listenWhen: (previous, current) =>
                previous.deletionStatus != current.deletionStatus &&
                current.deletionStatus == RequestStatus.failure,
            listener: _showRequestFailure,
          ),
          BlocListener<AddressesCubit, AddressesState>(
            listenWhen: (previous, current) =>
                current.reviewStatuses.entries.any(
                  (review) =>
                      previous.reviewStatuses[review.key] != review.value &&
                      review.value == RequestStatus.failure,
                ),
            listener: _showRequestFailure,
          ),
          BlocListener<AddressesCubit, AddressesState>(
            listenWhen: (previous, current) =>
                previous.effect != current.effect && current.effect != null,
            listener: _handleEffect,
          ),
        ],
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<AddressesCubit, AddressesState>(
            builder: (context, state) {
              return PopScope(
                canPop:
                    state.addressesStatus != RequestStatus.loading &&
                    state.saveStatus != RequestStatus.loading &&
                    state.deletionStatus != RequestStatus.loading &&
                    !state.reviewStatuses.containsValue(RequestStatus.loading),
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        Builder(
                          builder: (context) {
                            return AppTopBar(
                              title: S.current.dashboardAddresses,
                              showLeadingActions: false,
                              leadingAction: const SizedBox.shrink(),
                              trailingIcon: AvpImage(
                                image:
                                    '${AppConstants.baseImage}deposit_list_back.svg',
                                width: 24,
                                height: 24,
                              ),
                              trailingTooltip: S.current.backLabel,
                              onTrailingPressed: () {
                                context.read<AddressesCubit>().requestBack();
                              },
                              isTrailingActive:
                                  (state.addressesStatus !=
                                      RequestStatus.loading &&
                                  state.saveStatus != RequestStatus.loading &&
                                  state.deletionStatus !=
                                      RequestStatus.loading &&
                                  !state.reviewStatuses.containsValue(
                                    RequestStatus.loading,
                                  )),
                            );
                          },
                        ),
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              const AddressesList(),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: Builder(
                                  builder: (context) {
                                    return AppAssistantButton(
                                      onPressed: () {
                                        context
                                            .read<AddressesCubit>()
                                            .requestAssistant();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: AppButton(
                            label: S.current.profileAddAddress,
                            size: AppButtonSize.lg,
                            isLoading:
                                state.saveStatus == RequestStatus.loading ||
                                state.deletionStatus == RequestStatus.loading,
                            onPressed: () {
                              context
                                  .read<AddressesCubit>()
                                  .requestNewAddress();
                            },
                            isActive:
                                state.addressesStatus == RequestStatus.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
