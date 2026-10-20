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
import '../../../domain/entities/agent_request.dart';
import '../../../domain/repositories/deposits_repository.dart';
import '../../../domain/repositories/agent_repository.dart';
import '../../../domain/usecases/deposit_list.dart';
import '../../../domain/usecases/submit_agents.dart';

part 'agent_state.dart';
part 'agent_cubit.freezed.dart';

class AgentCubit extends Cubit<AgentState> {
  AgentCubit({
    this.initialDepositNumber,
    AgentState initialState = const AgentState.initial(),
  }) : super(initialState);

  final String? initialDepositNumber;
  final _depositsRepository = getIt<DepositsRepository>();
  final _agentRepository = getIt<AgentRepository>();
  late final _fetchDeposits = LoadDeposits(_depositsRepository);
  late final _submitAgents = SubmitAgents(_agentRepository);
  AgentRequest? _submittedRequest;

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

  void selectOperation(AgentOperation operation) {
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
    final agent = PendingAgent(
      deposit: state.deposit!,
      operation: state.operation!,
      nationalId: state.nationalId,
      validUntil: state.validUntil!,
    );
    emit(
      state.copyWith(
        agents: [...state.agents, agent],
        draftSavedId: state.draftSavedId + 1,
        canSaveDraft: false,
        canSubmit: state.termsAccepted,
        hasChanges: true,
        submissionFailure: null,
      ),
    );
  }

  void requestNextAgent() {
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
        effect: AgentEffect.addNext,
        effectId: state.effectId + 1,
      ),
    );
  }

  void removeAgent(PendingAgent agent) {
    final agents = List.of(state.agents)..remove(agent);
    if (agents.isEmpty) {
      // The initial form becomes visible again; discard the consumed/cancelled form.
      emit(
        state.copyWith(
          agents: agents,
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
      emit(state.copyWith(agents: agents, submissionFailure: null));
    }
  }

  void updateTermsAcceptance(bool accepted) {
    emit(
      state.copyWith(
        termsAccepted: accepted,
        canSubmit: accepted && state.agents.isNotEmpty,
      ),
    );
  }

  Future<void> submitAgents() {
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
    return _submitAgents(request).then((result) {
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

  AgentRequest _createRequest(String? idempotencyKey) {
    return AgentRequest(
      agents: state.agents,
      idempotencyKey:
          idempotencyKey ??
          'agents-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
    );
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: state.hasChanges ? AgentEffect.confirmExit : AgentEffect.back,
        isExitToHome: false,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestHome() {
    emit(
      state.copyWith(
        effect: state.hasChanges ? AgentEffect.confirmExit : AgentEffect.home,
        isExitToHome: true,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true
            ? (state.isExitToHome ? AgentEffect.home : AgentEffect.back)
            : null,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(
      state.copyWith(effect: AgentEffect.home, effectId: state.effectId + 1),
    );
  }
}
