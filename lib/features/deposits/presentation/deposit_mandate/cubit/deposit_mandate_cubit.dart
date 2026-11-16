import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/entities/deposit_mandate.dart';
import '../../../domain/usecases/deposit_mandate_usecase.dart';

part 'deposit_mandate_state.dart';
part 'deposit_mandate_cubit.freezed.dart';

class DepositMandateCubit extends Cubit<DepositMandateState> {
  DepositMandateCubit({
    this.initialDepositNumber,
    DepositMandateState initialState = const DepositMandateState.initial(),
  }) : super(initialState);
  final String? initialDepositNumber;
  final fetchDepositMandateCatalogUseCase =
      getIt<FetchDepositMandateCatalogUseCase>();
  final submitDepositMandateUseCase = getIt<SubmitDepositMandateUseCase>();

  Future<void> fetchCatalog() async {
    emit(
      state.copyWith(catalogStatus: RequestStatus.loading, isEditable: false),
    );
    final result = await fetchDepositMandateCatalogUseCase();
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.success,
            catalog: data,
            subjects: data.subjects,
            deposits: data.deposits,
            deposit: _resolveInitialDeposit(data.deposits),
            isEditable: true,
            idempotencyKey: _createRequestKey(),
          ),
        );
    }
  }

  void selectCompany(DepositMandateCompany company) {
    emit(
      state.copyWith(
        company: company,
        subjects: _subjectsForCompany(company),
        subject: null,
        amountToman: null,
        deposits: state.catalog!.deposits,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void selectSubject(DepositMandateSubject subject) {
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
        subjects: _subjectsForCompany(company),
        deposits: deposits,
        deposit: deposit,
        amountToman: subject.amountRial / 10,
        termsAccepted: false,
        canSubmit: false,
        hasChanges: true,
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
        idempotencyKey: _createRequestKey(),
      ),
    );
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit: _canSubmit(accepted),
        hasChanges: true,
      ),
    );
  }

  Future<void> submitDepositMandate() async {
    final request = DepositMandateRequest(
      companyId: state.company!.id,
      subjectId: state.subject!.id,
      depositId: state.deposit!.id,
      catalogToken: state.catalog!.token,
      idempotencyKey: state.idempotencyKey!,
    );
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
      ),
    );
    final result = await submitDepositMandateUseCase(request);
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            isEditable: true,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
            canSubmit: false,
          ),
        );
    }
  }

  void requestTerms() {
    emit(state.copyWith(effect: DepositMandateEffect.termsUnavailable));
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? DepositMandateEffect.confirmExit
            : DepositMandateEffect.back,
        isExitToAssistant: false,
      ),
    );
  }

  void requestAssistant() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? DepositMandateEffect.confirmExit
            : DepositMandateEffect.assistant,
        isExitToAssistant: true,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true
            ? (state.isExitToAssistant
                  ? DepositMandateEffect.assistant
                  : DepositMandateEffect.back)
            : null,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(effect: DepositMandateEffect.home));
  }

  ListedDeposit? _resolveInitialDeposit(List<ListedDeposit> deposits) {
    final number = _normalizeDepositNumber(initialDepositNumber ?? '');
    return deposits
        .where((deposit) => _normalizeDepositNumber(deposit.number) == number)
        .firstOrNull;
  }

  String _normalizeDepositNumber(String number) =>
      DigitNormalizer.normalize(number).replaceAll(RegExp(r'[^0-9]'), '');

  List<DepositMandateSubject> _subjectsForCompany(
    DepositMandateCompany company,
  ) => state.catalog!.subjects
      .where((subject) => subject.companyId == company.id)
      .toList();

  bool _canSubmit(bool termsAccepted) {
    return termsAccepted &&
        state.company != null &&
        state.subject != null &&
        state.deposit != null;
  }

  String _createRequestKey() =>
      'proxy-deposit-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeDepositMandateInteraction() {
    emit(state.copyWith(effect: null));
  }
}
