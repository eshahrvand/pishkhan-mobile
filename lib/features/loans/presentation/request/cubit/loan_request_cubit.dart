import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/validators/code_validator.dart';
import 'package:pishkhan_mobile/core/validators/national_code_validator.dart';

import '../../../domain/entities/loan_application.dart';
import '../../../domain/entities/loan_credit_assessment.dart';
import '../../../domain/usecases/loan_request_usecase.dart';

part 'loan_request_state.dart';
part 'loan_request_cubit.freezed.dart';

class LoanRequestCubit extends Cubit<LoanRequestState> {
  LoanRequestCubit({
    LoanRequestState initialState = const LoanRequestState.initial(),
  }) : super(initialState);
  final fetchLoanCatalogUseCase = getIt<FetchLoanCatalogUseCase>();
  final quoteLoanUseCase = getIt<QuoteLoanUseCase>();
  final fetchLoanInquiriesUseCase = getIt<FetchLoanInquiriesUseCase>();
  final checkLoanGuarantorUseCase = getIt<CheckLoanGuarantorUseCase>();
  final checkLoanCollateralUseCase = getIt<CheckLoanCollateralUseCase>();
  final saveLoanDraftUseCase = getIt<SaveLoanDraftUseCase>();
  final requestLoanSigningOtpUseCase = getIt<RequestLoanSigningOtpUseCase>();
  final submitLoanApplicationUseCase = getIt<SubmitLoanApplicationUseCase>();
  final cancelLoanApplicationUseCase = getIt<CancelLoanApplicationUseCase>();
  int _quoteRequestId = 0;
  Timer? _otpTimer;
  Timer? _draftTimer;

  Future<void> fetchCatalog() async {
    emit(state.copyWith(catalogStatus: RequestStatus.loading));
    final result = await fetchLoanCatalogUseCase();
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
        final limits = _repaymentLimits(state.repayment, data);
        final amount = state.amountRial.clamp(
          data.minimumRial,
          data.maximumRial,
        );
        final months = state.months.clamp(limits.minimum, limits.maximum);
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.success,
            catalog: data,
            minimumMonths: limits.minimum,
            maximumMonths: limits.maximum,
            amountRial: amount,
            months: months,
            amountPosition: _positionWithinLimits(
              amount,
              data.minimumRial,
              data.maximumRial,
            ),
            monthsPosition: _positionWithinLimits(
              months,
              limits.minimum,
              limits.maximum,
            ),
            canContinue: data.currentDraft == null && data.latestRecord == null,
            draftRemainingSeconds: data.currentDraft?.expiresAt == null
                ? null
                : _remainingSeconds(data.currentDraft!.expiresAt!),
          ),
        );
    }
    _draftTimer?.cancel();
    if (state.catalog?.currentDraft?.expiresAt != null) {
      _draftTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final remaining = _remainingSeconds(
          state.catalog!.currentDraft!.expiresAt!,
        );
        emit(state.copyWith(draftRemainingSeconds: remaining));
        if (remaining == 0) _draftTimer?.cancel();
      });
    }
  }

  Future<void> selectDeposit(LoanDeposit deposit) async {
    emit(state.copyWith(deposit: deposit));
    await fetchQuote();
  }

  Future<void> selectRepayment(LoanRepayment repayment) async {
    final limits = _repaymentLimits(repayment, state.catalog!);
    final months = state.months.clamp(limits.minimum, limits.maximum);
    emit(
      state.copyWith(
        repayment: repayment,
        minimumMonths: limits.minimum,
        maximumMonths: limits.maximum,
        months: months,
        monthsPosition: _positionWithinLimits(
          months,
          limits.minimum,
          limits.maximum,
        ),
      ),
    );
    await fetchQuote();
  }

  Future<void> updateAmount(double normalized) async {
    final amount =
        state.catalog!.minimumRial +
        ((state.catalog!.maximumRial - state.catalog!.minimumRial) * normalized)
            .round();
    emit(
      state.copyWith(
        amountRial: amount,
        amountPosition: _positionWithinLimits(
          amount,
          state.catalog!.minimumRial,
          state.catalog!.maximumRial,
        ),
      ),
    );
    await fetchQuote();
  }

  Future<void> updateMonths(double normalized) async {
    final months =
        state.minimumMonths +
        ((state.maximumMonths - state.minimumMonths) * normalized).round();
    emit(
      state.copyWith(
        months: months,
        monthsPosition: _positionWithinLimits(
          months,
          state.minimumMonths,
          state.maximumMonths,
        ),
      ),
    );
    await fetchQuote();
  }

  Future<void> fetchQuote() async {
    final requestId = ++_quoteRequestId;
    final input = LoanQuoteInput(
      deposit: state.deposit!,
      amountRial: state.amountRial,
      months: state.months,
      repayment: state.repayment,
    );
    emit(
      state.copyWith(
        quoteStatus: RequestStatus.loading,
        assessment: assessMockLoanInput(
          input,
          minimumRial: state.catalog!.minimumRial,
          maximumRial: state.catalog!.maximumRial,
        ),
        collateral: null,
        guarantor: null,
        ownNumber: '',
        guarantorNumber: '',
        isOwnNumberValid: false,
        isOwnNumberError: false,
        isGuarantorNumberValid: false,
        isGuarantorNumberError: false,
        canContinue: false,
      ),
    );
    final result = await quoteLoanUseCase(input);
    if (requestId != _quoteRequestId) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            quoteStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            quoteStatus: RequestStatus.success,
            quote: data,
            canContinue: data.canProceed,
          ),
        );
    }
  }

  Future<void> continueFlow() async {
    switch (state.step) {
      case LoanApplicationStep.introduction:
        emit(
          state.copyWith(
            step: LoanApplicationStep.assessment,
            stepNumber: 1,
            canContinue: false,
          ),
        );
      case LoanApplicationStep.assessment:
        emit(
          state.copyWith(step: LoanApplicationStep.inquiries, stepNumber: 2),
        );
        await fetchInquiries();
      case LoanApplicationStep.inquiries:
        await saveDraft();
      case LoanApplicationStep.collateral:
        await checkCollateral();
      case LoanApplicationStep.contract:
        emit(state.copyWith(effect: LoanRequestEffect.contract));
    }
  }

  Future<void> fetchInquiries() async {
    emit(
      state.copyWith(
        inquiryStatus: RequestStatus.loading,
        canContinue: false,
        inquiries: LoanInquiryKind.values
            .map((kind) => LoanInquiry(kind, LoanInquiryOutcome.processing))
            .toList(),
      ),
    );
    await for (final result in fetchLoanInquiriesUseCase(state.quote!)) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              inquiryStatus: RequestStatus.failure,
              canRetryInquiries: true,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              inquiryStatus:
                  data.any(
                    (row) => row.outcome == LoanInquiryOutcome.processing,
                  )
                  ? RequestStatus.loading
                  : RequestStatus.success,
              inquiries: data,
              canRetryInquiries: data.any(
                (row) => row.outcome == LoanInquiryOutcome.rejected,
              ),
              canContinue: data.every(
                (row) => row.outcome == LoanInquiryOutcome.approved,
              ),
            ),
          );
      }
    }
  }

  Future<void> saveDraft() async {
    emit(state.copyWith(draftStatus: RequestStatus.loading));
    final result = await saveLoanDraftUseCase(
      LoanDraft(
        id: state.quote!.id,
        quote: state.quote!,
        step: state.quote!.needsCollateral && state.collateral == null
            ? LoanApplicationStep.collateral
            : LoanApplicationStep.contract,
        collateral: state.collateral,
        insuranceSelected: state.isInsuranceSelected,
      ),
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            draftStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            draftStatus: RequestStatus.success,
            draft: data,
            termsAccepted: state.draft == data && state.termsAccepted,
            step: data.step,
            stepNumber: _stepNumber(data.step),
            canContinue: data.step == LoanApplicationStep.contract,
          ),
        );
    }
  }

  void updateGuarantorNationalId(String value) {
    final valid = NationalCodeValidator.isValid(value);
    emit(
      state.copyWith(
        guarantorNationalId: value,
        isGuarantorIdValid: valid,
        isGuarantorIdError: false,
        guarantor: null,
        guarantorNumber: '',
        isGuarantorNumberValid: false,
        isGuarantorNumberError: false,
        collateral: null,
        canCheckGuarantor: valid,
        canContinue: false,
      ),
    );
  }

  void validateGuarantorNationalId() {
    emit(state.copyWith(isGuarantorIdError: !state.isGuarantorIdValid));
  }

  void validateOwnNumber() {
    emit(state.copyWith(isOwnNumberError: !state.isOwnNumberValid));
  }

  void validateGuarantorNumber() {
    emit(state.copyWith(isGuarantorNumberError: !state.isGuarantorNumberValid));
  }

  Future<void> checkGuarantor() async {
    emit(state.copyWith(guarantorStatus: RequestStatus.loading));
    final result = await checkLoanGuarantorUseCase(
      state.guarantorNationalId,
      state.quote!,
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            guarantorStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            guarantorStatus: RequestStatus.success,
            guarantor: data,
            canContinue: _canContinueCollateral(guarantor: data),
          ),
        );
    }
  }

  void selectOwnInstrument(LoanInstrument instrument) {
    emit(
      state.copyWith(
        ownInstrument: instrument,
        ownNumber: '',
        isOwnNumberValid: false,
        isOwnNumberError: false,
        collateral: null,
        canContinue: false,
      ),
    );
  }

  void selectGuarantorInstrument(LoanInstrument instrument) {
    emit(
      state.copyWith(
        guarantorInstrument: instrument,
        guarantorNumber: '',
        isGuarantorNumberValid: false,
        isGuarantorNumberError: false,
        collateral: null,
        canContinue: false,
      ),
    );
  }

  void updateOwnNumber(String value) {
    final valid = LoanInstrumentValidator.isValid(value);
    emit(
      state.copyWith(
        ownNumber: value,
        isOwnNumberValid: valid,
        isOwnNumberError: false,
        isCollateralError: false,
        collateral: null,
        canContinue: _canContinueCollateral(ownValid: valid),
      ),
    );
  }

  void updateGuarantorNumber(String value) {
    final valid = LoanInstrumentValidator.isValid(value);
    emit(
      state.copyWith(
        guarantorNumber: value,
        isGuarantorNumberValid: valid,
        isGuarantorNumberError: false,
        isCollateralError: false,
        collateral: null,
        canContinue: _canContinueCollateral(guarantorNumberValid: valid),
      ),
    );
  }

  bool _canContinueCollateral({
    bool? ownValid,
    bool? guarantorNumberValid,
    LoanGuarantor? guarantor,
  }) {
    return (ownValid ?? state.isOwnNumberValid) &&
        (!state.quote!.needsGuarantor ||
            ((guarantor ?? state.guarantor)?.outcome ==
                    LoanGuarantorOutcome.approved &&
                (guarantorNumberValid ?? state.isGuarantorNumberValid)));
  }

  Future<void> checkCollateral() async {
    emit(state.copyWith(collateralStatus: RequestStatus.loading));
    final result = await checkLoanCollateralUseCase(
      state.quote!,
      LoanCollateral(
        ownInstrument: state.ownInstrument,
        ownNumber: state.ownNumber,
        guarantorInstrument: state.guarantorInstrument,
        guarantorNumber: state.guarantorNumber,
        guarantor: state.guarantor,
      ),
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            collateralStatus: RequestStatus.failure,
            isCollateralError: failure.code == 'loan.collateral.invalid',
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            collateralStatus: RequestStatus.success,
            collateral: data,
          ),
        );
        await saveDraft();
    }
  }

  void toggleSummary() =>
      emit(state.copyWith(isSummaryExpanded: !state.isSummaryExpanded));
  void toggleCredit() =>
      emit(state.copyWith(isCreditExpanded: !state.isCreditExpanded));
  void requestCreditInfo() =>
      emit(state.copyWith(effect: LoanRequestEffect.creditInfo));
  void requestInstallments() =>
      emit(state.copyWith(effect: LoanRequestEffect.installments));
  void requestInsurance() =>
      emit(state.copyWith(effect: LoanRequestEffect.insurance));
  void requestUnavailable() =>
      emit(state.copyWith(effect: LoanRequestEffect.unavailable));
  Future<void> updateInsuranceSelection(bool value) async {
    emit(state.copyWith(isInsuranceSelected: value, termsAccepted: false));
    await saveDraft();
  }

  void updateTermsAccepted(bool value) =>
      emit(state.copyWith(termsAccepted: value));

  void toggleTermsAcceptance() {
    emit(state.copyWith(termsAccepted: !state.termsAccepted));
  }

  Future<void> applyContractResult(bool? accepted) async {
    if (_isConfirmed(accepted)) {
      emit(state.copyWith(challenge: null));
      await requestSigningOtp();
    }
  }

  Future<void> requestSigningOtp() async {
    emit(state.copyWith(otpStatus: RequestStatus.loading));
    final result = await requestLoanSigningOtpUseCase(state.draft!);
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            otpStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        _otpTimer?.cancel();
        emit(
          state.copyWith(
            otpStatus: RequestStatus.success,
            challenge: data,
            otp: '',
            isOtpValid: false,
            isOtpError: false,
            remainingSeconds: _remainingSeconds(data.expiresAt),
            canSubmit: false,
            effect: state.challenge == null ? LoanRequestEffect.otp : null,
          ),
        );
        _otpTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          final remaining = _remainingSeconds(data.expiresAt);
          emit(
            state.copyWith(
              remainingSeconds: remaining,
              canSubmit: _canSubmitOtp(state.isOtpValid, remaining),
            ),
          );
          if (remaining == 0) _otpTimer?.cancel();
        });
    }
  }

  int _remainingSeconds(DateTime expiresAt) {
    final seconds =
        (expiresAt.difference(DateTime.now().toUtc()).inMilliseconds / 1000)
            .ceil();
    return seconds < 0 ? 0 : seconds;
  }

  bool _canSubmitOtp(bool valid, int seconds) => valid && seconds > 0;

  void updateOtp(String value) {
    final valid = CodeValidator.isValid(
      value,
      length: state.challenge!.codeLength,
    );
    emit(
      state.copyWith(
        otp: value,
        isOtpValid: valid,
        isOtpError: false,
        canSubmit: _canSubmitOtp(valid, state.remainingSeconds),
      ),
    );
  }

  Future<void> submitLoan() async {
    emit(state.copyWith(submissionStatus: RequestStatus.loading));
    final result = await submitLoanApplicationUseCase(
      state.draft!,
      state.challenge!,
      state.otp,
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            isOtpError: failure.code == 'loan.otp.invalid',
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        _otpTimer?.cancel();
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
            canSubmit: false,
          ),
        );
    }
  }

  void applyOtpResult() {
    _otpTimer?.cancel();
    if (state.submissionStatus == RequestStatus.success) {
      emit(
        state.copyWith(
          step: LoanApplicationStep.introduction,
          stepNumber: 1,
          canContinue: false,
          effect: LoanRequestEffect.receipt,
        ),
      );
    }
  }

  Future<void> completeReceipt() async {
    emit(const LoanRequestState.initial());
    await fetchCatalog();
  }

  void resumeRequest(LoanDraft draft) {
    _draftTimer?.cancel();
    final limits = _repaymentLimits(
      draft.quote.input.repayment,
      state.catalog!,
    );
    emit(
      state.copyWith(
        step: draft.step,
        stepNumber: _stepNumber(draft.step),
        draft: draft,
        isInsuranceSelected: draft.insuranceSelected,
        quote: draft.quote,
        quoteStatus: RequestStatus.success,
        assessment: assessMockLoanInput(
          draft.quote.input,
          minimumRial: state.catalog!.minimumRial,
          maximumRial: state.catalog!.maximumRial,
        ),
        inquiries: LoanInquiryKind.values
            .map((kind) => LoanInquiry(kind, LoanInquiryOutcome.approved))
            .toList(),
        isOwnNumberValid: draft.collateral != null,
        isGuarantorNumberValid: draft.collateral?.guarantor != null,
        ownInstrument:
            draft.collateral?.ownInstrument ?? LoanInstrument.promissoryNote,
        guarantorInstrument:
            draft.collateral?.guarantorInstrument ??
            LoanInstrument.promissoryNote,
        guarantorNationalId: draft.collateral?.guarantor?.nationalId ?? '',
        deposit: draft.quote.input.deposit,
        amountRial: draft.quote.input.amountRial,
        months: draft.quote.input.months,
        minimumMonths: limits.minimum,
        maximumMonths: limits.maximum,
        amountPosition: _positionWithinLimits(
          draft.quote.input.amountRial,
          state.catalog!.minimumRial,
          state.catalog!.maximumRial,
        ),
        monthsPosition: _positionWithinLimits(
          draft.quote.input.months,
          limits.minimum,
          limits.maximum,
        ),
        repayment: draft.quote.input.repayment,
        collateral: draft.collateral,
        guarantor: draft.collateral?.guarantor,
        ownNumber: draft.collateral?.ownNumber ?? '',
        guarantorNumber: draft.collateral?.guarantorNumber ?? '',
        canContinue: draft.step == LoanApplicationStep.contract,
      ),
    );
  }

  void requestCopyRequestNumber() =>
      emit(state.copyWith(effect: LoanRequestEffect.copyRequestNumber));

  void requestCancel() =>
      emit(state.copyWith(effect: LoanRequestEffect.confirmCancel));
  Future<void> applyCancelResult(bool? accepted) async {
    if (_isConfirmed(accepted)) await cancelRequest();
  }

  Future<void> cancelRequest() async {
    emit(state.copyWith(cancellationStatus: RequestStatus.loading));
    final result = await cancelLoanApplicationUseCase(
      state.catalog!.currentDraft!.id,
    );
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            cancellationStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success():
        emit(state.copyWith(cancellationStatus: RequestStatus.success));
        await fetchCatalog();
    }
  }

  void requestBack() {
    switch (state.step) {
      case LoanApplicationStep.introduction:
        emit(state.copyWith(effect: LoanRequestEffect.exit));
      case LoanApplicationStep.assessment:
        emit(state.copyWith(effect: LoanRequestEffect.confirmExit));
      case LoanApplicationStep.inquiries:
        emit(
          state.copyWith(
            step: LoanApplicationStep.assessment,
            stepNumber: 1,
            canContinue: state.quote!.canProceed,
          ),
        );
      case LoanApplicationStep.collateral:
        emit(
          state.copyWith(
            step: LoanApplicationStep.inquiries,
            stepNumber: 2,
            canContinue: state.inquiries.every(
              (row) => row.outcome == LoanInquiryOutcome.approved,
            ),
          ),
        );
      case LoanApplicationStep.contract:
        emit(
          state.copyWith(
            step: state.quote!.needsCollateral
                ? LoanApplicationStep.collateral
                : LoanApplicationStep.inquiries,
            stepNumber: state.quote!.needsCollateral ? 3 : 2,
            canContinue: true,
          ),
        );
    }
  }

  Future<void> applyExitResult(bool? accepted) async {
    if (_isConfirmed(accepted)) {
      emit(const LoanRequestState.initial());
      await fetchCatalog();
    }
  }

  double _positionWithinLimits(int value, int minimum, int maximum) =>
      (value - minimum) / (maximum - minimum);

  ({int minimum, int maximum}) _repaymentLimits(
    LoanRepayment repayment,
    LoanCatalog catalog,
  ) => switch (repayment) {
    LoanRepayment.lumpSum => (minimum: 4, maximum: 10),
    LoanRepayment.installments => (
      minimum: catalog.minimumMonths,
      maximum: catalog.maximumMonths,
    ),
  };

  int _stepNumber(LoanApplicationStep step) => switch (step) {
    LoanApplicationStep.introduction || LoanApplicationStep.assessment => 1,
    LoanApplicationStep.inquiries => 2,
    LoanApplicationStep.collateral => 3,
    LoanApplicationStep.contract => 4,
  };

  bool _isConfirmed(bool? value) => value == true;

  void consumeInteraction() => emit(state.copyWith(effect: null));
  @override
  Future<void> close() {
    _otpTimer?.cancel();
    _draftTimer?.cancel();
    return super.close();
  }
}
