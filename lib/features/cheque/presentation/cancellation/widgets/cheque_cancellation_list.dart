import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/cheque_cancellation_cubit.dart';
import 'cheque_cancellation_details.dart';

class ChequeCancellationList extends StatefulWidget {
  const ChequeCancellationList({super.key, required this.state});
  final ChequeCancellationState state;
  @override
  State<ChequeCancellationList> createState() => _ChequeCancellationListState();
}

class _ChequeCancellationListState extends State<ChequeCancellationList> {
  final _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _searchController.text = widget.state.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.chequeCancelChequesPrompt,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        AppSearchField(
          controller: _searchController,
          enabled: widget.state.isEditable,
          hintText: S.current.chequeCancelSearchHint,
          textStyle: certificateValueStyle(context),
          hintColor: context.colors.textDisabled,
          focusRing: AppTextFieldFocusRing.none,
          searchIcon: const Center(
            widthFactor: 1,
            child: AvpImage(
              image: '${AppConstants.baseImage}card_features_search.svg',
              width: 20,
              height: 20,
            ),
          ),
          clearIcon: const AvpImage(
            image: '${AppConstants.baseImage}dashboard_search_clear.svg',
            width: 20,
            height: 20,
          ),
          onChanged: context.read<ChequeCancellationCubit>().updateSearchQuery,
        ),
        const SizedBox(height: 20),
        if (widget.state.chequesStatus == RequestStatus.loading)
          const Center(child: CircularProgressIndicator())
        else if (widget.state.chequesStatus == RequestStatus.failure)
          AppButton(
            isLoading: widget.state.chequesStatus == RequestStatus.loading,
            label: S.current.dashboardRetry,
            onPressed: context.read<ChequeCancellationCubit>().fetchCheques,
          )
        else ...[
          if (widget.state.searchQuery.isEmpty &&
              widget.state.cheques.isNotEmpty) ...[
            Row(
              children: [
                AppToggle(
                  value: widget.state.isAllSelected,
                  appearance: AppToggleAppearance.issuance,
                  onChanged: widget.state.isEditable
                      ? context.read<ChequeCancellationCubit>().toggleAllCheques
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  S.current.giftBalanceSelectAll,
                  style: certificateLabelStyle(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          if (widget.state.visibleCheques.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                S.current.chequeCancelEmpty,
                textAlign: TextAlign.center,
                style: certificateValueStyle(context),
              ),
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.state.visibleCheques.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: widget.state.isEditable
                    ? () =>
                          context.read<ChequeCancellationCubit>().toggleCheque(
                            widget.state.visibleCheques[index].cheque,
                          )
                    : null,
                borderRadius: AppRadius.borderSm,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.state.visibleCheques[index].isSelected
                          ? context.colors.primary
                          : context.colors.border,
                    ),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Row(
                    children: [
                      AppCheckbox(
                        value: widget.state.visibleCheques[index].isSelected,
                        size: AppCheckboxSize.md,
                        onChanged: widget.state.isEditable
                            ? (_) => context
                                  .read<ChequeCancellationCubit>()
                                  .toggleCheque(
                                    widget.state.visibleCheques[index].cheque,
                                  )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChequeCancellationDetails(
                          cheque: widget.state.visibleCheques[index].cheque,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
