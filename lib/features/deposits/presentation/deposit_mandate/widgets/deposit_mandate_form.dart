import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/entities/deposit_mandate.dart';
import '../../shared/certificate_fields.dart';
import '../cubit/deposit_mandate_cubit.dart';
import 'deposit_mandate_subject_details.dart';

class DepositMandateForm extends StatelessWidget {
  const DepositMandateForm({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositMandateCubit, DepositMandateState>(
      buildWhen: (previous, current) =>
          previous.catalogStatus != current.catalogStatus ||
          previous.catalog != current.catalog ||
          previous.company != current.company ||
          previous.subject != current.subject ||
          previous.deposit != current.deposit ||
          previous.subjects != current.subjects ||
          previous.deposits != current.deposits ||
          previous.amountToman != current.amountToman ||
          previous.isEditable != current.isEditable,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CertificateSelect<DepositMandateCompany>(
                label: S.current.depositMandateCompany,
                hint: S.current.depositMandateCompanyHint,
                value: state.company,
                enabled: state.isEditable,
                options: [
                  for (final company
                      in state.catalog?.companies ?? <DepositMandateCompany>[])
                    AppSelectOption(value: company, label: company.name),
                ],
                onChanged: context.read<DepositMandateCubit>().selectCompany,
              ),
              const SizedBox(height: 20),
              CertificateSelect<DepositMandateSubject>(
                label: S.current.depositMandateSubject,
                hint: S.current.depositMandateSubjectHint,
                value: state.subject,
                enabled: state.isEditable,
                options: [
                  for (final subject in state.subjects)
                    AppSelectOption(value: subject, label: subject.title),
                ],
                onChanged: context.read<DepositMandateCubit>().selectSubject,
              ),
              const SizedBox(height: 20),
              CertificateSelect<ListedDeposit>(
                label: S.current.agentDepositShort,
                hint: S.current.depositMandateHint,
                value: state.deposit,
                enabled: state.isEditable,
                options: [
                  for (final deposit in state.deposits)
                    AppSelectOption(value: deposit, label: deposit.number),
                ],
                onChanged: context.read<DepositMandateCubit>().selectDeposit,
              ),
              if (state.subject != null) ...[
                const SizedBox(height: 20),
                DepositMandateSubjectDetails(
                  subject: state.subject!,
                  amountToman: state.amountToman!,
                ),
              ],
              if (state.catalogStatus == RequestStatus.loading) ...[
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator()),
              ],
              if (state.catalogStatus == RequestStatus.failure) ...[
                const SizedBox(height: 20),
                const SizedBox.shrink(),
                AppButton(
                  isLoading: state.catalogStatus == RequestStatus.loading,
                  label: S.current.dashboardRetry,
                  onPressed: context.read<DepositMandateCubit>().fetchCatalog,
                ),
              ],
              if (state.catalogStatus == RequestStatus.success &&
                  state.deposits.isEmpty) ...[
                const SizedBox(height: 20),
                Text(S.current.depositsEmpty),
              ],
            ],
          ),
        );
      },
    );
  }
}
