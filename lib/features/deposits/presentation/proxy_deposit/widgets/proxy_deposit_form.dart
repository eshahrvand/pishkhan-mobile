import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/entities/proxy_deposit.dart';
import '../../shared/certificate_fields.dart';
import '../cubit/proxy_deposit_cubit.dart';
import 'proxy_subject_details.dart';

class ProxyDepositForm extends StatelessWidget {
  const ProxyDepositForm({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProxyDepositCubit, ProxyDepositState>(
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
              CertificateSelect<ProxyCompany>(
                label: S.current.proxyCompany,
                hint: S.current.proxyCompanyHint,
                value: state.company,
                enabled: state.isEditable,
                options: [
                  for (final company
                      in state.catalog?.companies ?? <ProxyCompany>[])
                    AppSelectOption(value: company, label: company.name),
                ],
                onChanged: context.read<ProxyDepositCubit>().selectCompany,
              ),
              const SizedBox(height: 20),
              CertificateSelect<ProxySubject>(
                label: S.current.proxySubject,
                hint: S.current.proxySubjectHint,
                value: state.subject,
                enabled: state.isEditable,
                options: [
                  for (final subject in state.subjects)
                    AppSelectOption(value: subject, label: subject.title),
                ],
                onChanged: context.read<ProxyDepositCubit>().selectSubject,
              ),
              const SizedBox(height: 20),
              CertificateSelect<ListedDeposit>(
                label: S.current.agentDepositShort,
                hint: S.current.proxyDepositHint,
                value: state.deposit,
                enabled: state.isEditable,
                options: [
                  for (final deposit in state.deposits)
                    AppSelectOption(value: deposit, label: deposit.number),
                ],
                onChanged: context.read<ProxyDepositCubit>().selectDeposit,
              ),
              if (state.subject != null) ...[
                const SizedBox(height: 20),
                ProxySubjectDetails(
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
                Text(
                  S.current.dashboardLoadError,
                  style: certificateLabelStyle(context)
                      .copyWith(color: context.colors.error),
                ),
                AppButton(
                  label: S.current.dashboardRetry,
                  onPressed: context.read<ProxyDepositCubit>().fetchCatalog,
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
