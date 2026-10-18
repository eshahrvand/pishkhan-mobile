import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/entities/proxy_deposit.dart';
import '../../../domain/repositories/proxy_deposits_repository.dart';
import '../../../domain/usecases/proxy_deposits.dart';

part 'proxy_deposit_state.dart';
part 'proxy_deposit_cubit.freezed.dart';

class ProxyDepositCubit extends Cubit<ProxyDepositState> {
  ProxyDepositCubit({
    this.initialDepositNumber,
    ProxyDepositState initialState = const ProxyDepositState.initial(),
  }) : super(initialState);
  final String? initialDepositNumber;
  final _repository = getIt<ProxyDepositsRepository>();
  late final _fetchCatalog = FetchProxyDepositCatalog(_repository);
  late final _submitProxyDeposit = SubmitProxyDeposit(_repository);

  Future<void> fetchCatalog() {
    emit(
      state.copyWith(
        catalogStatus: RequestStatus.loading,
        catalogFailure: null,
        isEditable: false,
      ),
    );
    return _fetchCatalog().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.failure,
              catalogFailure: failure,
            ),
          );
        case Success(:final data):
          final number = DigitNormalizer.normalize(initialDepositNumber ?? '')
              .replaceAll(RegExp(r'[^0-9]'), '');
          final deposit = data.deposits
              .where(
                (deposit) =>
                    DigitNormalizer.normalize(deposit.number)
                        .replaceAll(RegExp(r'[^0-9]'), '') ==
                    number,
              )
              .firstOrNull;
          emit(
            state.copyWith(
              catalogStatus: RequestStatus.success,
              catalog: data,
              subjects: data.subjects,
              deposits: data.deposits,
              deposit: deposit,
              isEditable: true,
              idempotencyKey: _createRequestKey(),
            ),
          );
      }
    });
  }

  void selectCompany(ProxyCompany company) {
    emit(
      state.copyWith(
        company: company,
        subjects: state.catalog!.subjects
            .where((subject) => subject.companyId == company.id)
            .toList(),
        subject: null,
        amountToman: null,
        deposits: state.catalog!.deposits,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        submissionFailure: null,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void selectSubject(ProxySubject subject) {
    final company = state.catalog!.companies.firstWhere(
      (company) => company.id == subject.companyId,
    );
    final deposits = state.catalog!.deposits
        .where((deposit) => subject.depositIds.contains(deposit.id))
        .toList();
    final deposit = deposits
        .where((deposit) => deposit.id == state.deposit?.id)
        .firstOrNull;
    emit(
      state.copyWith(
        subject: subject,
        company: company,
        subjects: state.catalog!.subjects
            .where((option) => option.companyId == company.id)
            .toList(),
        deposits: deposits,
        deposit: deposit,
        amountToman: subject.amountRial / 10,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        submissionFailure: null,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void selectDeposit(ListedDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        submissionFailure: null,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit:
            accepted &&
            state.company != null &&
            state.subject != null &&
            state.deposit != null,
        hasChanges: true,
      ),
    );
  }

  Future<void> submitProxyDeposit() {
    final request = ProxyDepositRequest(
      companyId: state.company!.id,
      subjectId: state.subject!.id,
      depositId: state.deposit!.id,
      catalogToken: state.catalog!.token,
      idempotencyKey: state.idempotencyKey!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        submissionFailure: null,
        isEditable: false,
      ),
    );
    return _submitProxyDeposit(request).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.failure,
              submissionFailure: failure,
              isEditable: true,
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              submissionStatus: RequestStatus.success,
              receipt: data,
              canSubmit: false,
              hasChanges: false,
            ),
          );
      }
    });
  }

  void requestTerms() {
    emit(
      state.copyWith(
        effect: ProxyDepositEffect.termsUnavailable,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? ProxyDepositEffect.confirmExit
            : ProxyDepositEffect.back,
        isExitToAssistant: false,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestAssistant() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? ProxyDepositEffect.confirmExit
            : ProxyDepositEffect.assistant,
        isExitToAssistant: true,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true
            ? (state.isExitToAssistant
                  ? ProxyDepositEffect.assistant
                  : ProxyDepositEffect.back)
            : null,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(
      state.copyWith(
        effect: ProxyDepositEffect.home,
        effectId: state.effectId + 1,
      ),
    );
  }

  String _createRequestKey() =>
      'proxy-deposit-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
}
