import 'deposit_filter_options.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../cubit/deposit_list_cubit.dart';
import 'deposit_sheet.dart';
import 'deposit_ui.dart';

class DepositFilters extends StatelessWidget {
  const DepositFilters({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositListCubit, DepositListState>(
      buildWhen: (previous, next) =>
          previous.kind != next.kind ||
          previous.depositStatus != next.depositStatus ||
          previous.status != next.status,
      builder: (context, state) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: AppChips(
                label: S.current.depositListAccountType,
                selected: state.kind != null,
                icon: depositIcon(
                  state.kind == null
                      ? AppAssets.depositFeatureChevron
                      : AppAssets.depositFeatureClear,
                  size: 20,
                ),
                onPressed: state.status != RequestStatus.success
                    ? null
                    : () async {
                        final cubit = context.read<DepositListCubit>();
                        if (state.kind != null) {
                          cubit.filterKind(null);
                          return;
                        }
                        final kind = await showDepositSheet<DepositKind>(
                          context,
                          DepositFilterOptions(
                            title: S.current.depositListAccountType,
                            labels: [
                              for (final k in DepositKind.values)
                                depositKindLabel(context, k),
                            ],
                            onSelected: (context, i) =>
                                context.pop(DepositKind.values[i]),
                          ),
                        );
                        if (!cubit.isClosed && kind != null) {
                          cubit.filterKind(kind);
                        }
                      },
              ),
            ),
            const SizedBox(width: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: AppChips(
                label: S.current.depositListStatus,
                selected: state.depositStatus != null,
                icon: depositIcon(
                  state.depositStatus == null
                      ? AppAssets.depositFeatureChevron
                      : AppAssets.depositFeatureClear,
                  size: 20,
                ),
                onPressed: state.status != RequestStatus.success
                    ? null
                    : () async {
                        final cubit = context.read<DepositListCubit>();
                        if (state.depositStatus != null) {
                          cubit.filterStatus(null);
                          return;
                        }
                        final status = await showDepositSheet<DepositStatus>(
                          context,
                          DepositFilterOptions(
                            title: S.current.depositListStatus,
                            labels: [
                              for (final s in DepositStatus.values)
                                depositStatusLabel(context, s),
                            ],
                            onSelected: (context, i) =>
                                context.pop(DepositStatus.values[i]),
                          ),
                        );
                        if (!cubit.isClosed && status != null) {
                          cubit.filterStatus(status);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
