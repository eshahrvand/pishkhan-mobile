import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/jalali_date_parser.dart';
import 'package:pishkhan_mobile/core/validators/national_code_validator.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/entities/representative_request.dart';
import '../../../domain/repositories/deposits_repository.dart';
import '../../../domain/repositories/representative_repository.dart';
import '../../../domain/usecases/deposit_list.dart';
import '../../../domain/usecases/submit_representatives.dart';

part 'representative_state.dart';
part 'representative_cubit.freezed.dart';

class RepresentativeCubit extends Cubit<RepresentativeState> {
  RepresentativeCubit({
    this.initialDepositNumber,
    RepresentativeState initialState = const RepresentativeState.initial(),
  }) : super(initialState);

  final String? initialDepositNumber;
  final _depositsRepository = getIt<DepositsRepository>();
  final _representativeRepository = getIt<RepresentativeRepository>();
  late final _fetchDeposits = LoadDeposits(_depositsRepository);
  late final _submitRepresentatives = SubmitRepresentatives(
    _representativeRepository,
  );
  RepresentativeRequest? _submittedRequest;

  Future<void> fetchDeposits() {
    emit(
      state.copyWith(
        depositsStatus: RequestStatus.loading,
        depositsFailure: null,
      ),
    );
    return _fetchDeposits().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              depositsStatus: RequestStatus.failure,
              depositsFailure: failure,
            ),
          );
        case Success(:final data):
          final deposits = data
              .where((deposit) => deposit.status == DepositStatus.open)
              .toList();
          final number = DigitNormalizer.normalize(initialDepositNumber ?? '')
              .replaceAll(RegExp(r'[^0-9]'), '');
          final initialDeposit = deposits
              .where(
                (deposit) =>
                    number.isNotEmpty &&
                    DigitNormalizer.normalize(deposit.number)
                            .replaceAll(RegExp(r'[^0-9]'), '') ==
                        number,
              )
              .firstOrNull;
          emit(
            state.copyWith(
              depositsStatus: RequestStatus.success,
              deposits: deposits,
              deposit: initialDeposit,
            ),
          );
      }
    });
  }

  void selectDeposit(ListedDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        hasChanges: true,
        canSaveDraft:
            state.operation != null &&
            state.isNationalIdValid &&
            state.isValidityValid,
      ),
    );
  }

  void selectOperation(RepresentativeOperation operation) {
    emit(
      state.copyWith(
        operation: operation,
        hasChanges: true,
        canSaveDraft:
            state.deposit != null &&
            state.isNationalIdValid &&
            state.isValidityValid,
      ),
    );
  }

  void updateNationalId(String value) {
    final normalized = DigitNormalizer.normalize(value).trim();
    final valid = NationalCodeValidator.isValid(normalized);
    emit(
      state.copyWith(
        nationalId: normalized,
        isNationalIdValid: valid,
        isNationalIdError: normalized.isNotEmpty && !valid,
        hasChanges: true,
        canSaveDraft:
            state.deposit != null &&
            state.operation != null &&
            valid &&
            state.isValidityValid,
      ),
    );
  }

  void updateValidity(String value) {
    final normalized = DigitNormalizer.normalize(value).trim();
    final parsed = JalaliDateParser.parse(normalized);
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final validUntil = parsed != null && !parsed.isBefore(today)
        ? parsed
        : null;
    emit(
      state.copyWith(
        validityText: normalized,
        validUntil: validUntil,
        isValidityValid: validUntil != null,
        isValidityError: normalized.isNotEmpty && validUntil == null,
        hasChanges: true,
        canSaveDraft:
            state.deposit != null &&
            state.operation != null &&
            state.isNationalIdValid &&
            validUntil != null,
      ),
    );
  }

  void saveDraft() {
    final representative = PendingRepresentative(
      deposit: state.deposit!,
      operation: state.operation!,
      nationalId: state.nationalId,
      validUntil: state.validUntil!,
    );
    emit(
      state.copyWith(
        representatives: [...state.representatives, representative],
        draftSavedId: state.draftSavedId + 1,
        canSaveDraft: false,
        canSubmit: state.termsAccepted,
        hasChanges: true,
        submissionFailure: null,
      ),
    );
  }

  void requestNextRepresentative() {
    emit(
      state.copyWith(
        deposit: null,
        operation: null,
        nationalId: '',
        isNationalIdValid: false,
        isNationalIdError: false,
        validityText: '',
        validUntil: null,
        isValidityValid: false,
        isValidityError: false,
        canSaveDraft: false,
        effect: RepresentativeEffect.addNext,
        effectId: state.effectId + 1,
      ),
    );
  }

  void removeRepresentative(PendingRepresentative representative) {
    final representatives = List.of(state.representatives)
      ..remove(representative);
    if (representatives.isEmpty) {
      // The initial form becomes visible again; discard the consumed/cancelled form.
      emit(
        state.copyWith(
          representatives: representatives,
          canSubmit: false,
          hasChanges: false,
          deposit: null,
          operation: null,
          nationalId: '',
          isNationalIdValid: false,
          isNationalIdError: false,
          validityText: '',
          validUntil: null,
          isValidityValid: false,
          isValidityError: false,
          canSaveDraft: false,
          submissionFailure: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          representatives: representatives,
          submissionFailure: null,
        ),
      );
    }
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit: accepted && state.representatives.isNotEmpty,
      ),
    );
  }

  Future<void> submitRepresentatives() {
    var request = _createRequest(_submittedRequest?.idempotencyKey);
    if (_submittedRequest != null && request != _submittedRequest) {
      request = _createRequest(null);
    }
    _submittedRequest = request;
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        submissionFailure: null,
        isEditable: false,
      ),
    );
    return _submitRepresentatives(request).then((result) {
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

  RepresentativeRequest _createRequest(String? idempotencyKey) {
    return RepresentativeRequest(
      representatives: state.representatives,
      idempotencyKey:
          idempotencyKey ??
          'representatives-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
    );
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? RepresentativeEffect.confirmExit
            : RepresentativeEffect.back,
        isExitToHome: false,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestHome() {
    emit(
      state.copyWith(
        effect: state.hasChanges
            ? RepresentativeEffect.confirmExit
            : RepresentativeEffect.home,
        isExitToHome: true,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true
            ? (state.isExitToHome
                  ? RepresentativeEffect.home
                  : RepresentativeEffect.back)
            : null,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(
      state.copyWith(
        effect: RepresentativeEffect.home,
        effectId: state.effectId + 1,
      ),
    );
  }
}
