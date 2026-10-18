import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/financial_certificate_data.dart';
import '../../shared/certificate_fields.dart';
import '../cubit/financial_certificate_cubit.dart';

/// One explicitly authored condition in the fixed certificate form.
class FinancialConditionOption extends StatelessWidget {
  const FinancialConditionOption({
    super.key,
    required this.condition,
    required this.label,
    required this.state,
  });
  final FinancialCertificateCondition condition;
  final String label;
  final FinancialCertificateState state;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          AppCheckbox(
            value: state.conditions.contains(condition),
            size: AppCheckboxSize.md,
            onChanged: (value) => context
                .read<FinancialCertificateCubit>()
                .toggleCondition(condition),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context
                  .read<FinancialCertificateCubit>()
                  .toggleCondition(condition),
              child: Text(
                label,
                style: certificateValueStyle(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
