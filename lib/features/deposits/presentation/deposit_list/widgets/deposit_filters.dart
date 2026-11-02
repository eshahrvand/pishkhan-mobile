import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/deposit_list_cubit.dart';
import 'deposit_ui.dart';

class DepositFilters extends StatelessWidget {
  const DepositFilters({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositListCubit, DepositListState>(
      buildWhen: (previous, current) =>
          previous.kind != current.kind ||
          previous.depositStatus != current.depositStatus ||
          previous.depositsStatus != current.depositsStatus,
      builder: (context, state) {
        return SingleChildScrollView(
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
                        ? '${AppConstants.baseImage}deposit_list_chevron.svg'
                        : '${AppConstants.baseImage}deposit_list_clear.svg',
                    size: 20,
                  ),
                  onPressed: state.depositsStatus != RequestStatus.success
                      ? null
                      : context.read<DepositListCubit>().requestKindFilter,
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
                        ? '${AppConstants.baseImage}deposit_list_chevron.svg'
                        : '${AppConstants.baseImage}deposit_list_clear.svg',
                    size: 20,
                  ),
                  onPressed: state.depositsStatus != RequestStatus.success
                      ? null
                      : context.read<DepositListCubit>().requestStatusFilter,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
