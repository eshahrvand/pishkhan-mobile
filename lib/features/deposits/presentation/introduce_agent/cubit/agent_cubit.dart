import 'dart:math';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/jalali_date_parser.dart';
import 'package:pishkhan_mobile/core/validators/national_code_validator.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/entities/agent_request.dart';
import '../../../domain/usecases/deposit_list_usecase.dart';
import '../../../domain/usecases/submit_agents_usecase.dart';

part 'agent_state.dart';
part 'agent_cubit.freezed.dart';

class AgentCubit extends Cubit<AgentState> {
  AgentCubit({
    this.initialDepositNumber,
    AgentState initialState = const AgentState.initial(),
  }) : super(initialState);

  final String? initialDepositNumber;
  final loadDepositsUseCase = getIt<LoadDepositsUseCase>();
  final submitAgentsUseCase = getIt<SubmitAgentsUseCase>();
  AgentRequest? _submittedRequest;

  Future<void> fetchDeposits() async {
    emit(state.copyWith(depositsStatus: RequestStatus.loading));
    final result = await loadDepositsUseCase();
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            depositsStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        final deposits = data
            .where((deposit) => deposit.status == DepositStatus.open)
            .toList();
        final initialDeposit = _resolveInitialDeposit(deposits);
        emit(
          state.copyWith(
            depositsStatus: RequestStatus.success,
            deposits: deposits,
            deposit: initialDeposit,
          ),
        );
    }
  }

  void selectDeposit(ListedDeposit deposit) {
    emit(
      state.copyWith(
        deposit: deposit,
        hasChanges: true,
        canSaveDraft: _canSaveDraft(deposit: deposit),
      ),
    );
  }

  void selectOperation(AgentOperation operation) {
    emit(
      state.copyWith(
        operation: operation,
        hasChanges: true,
        canSaveDraft: _canSaveDraft(operation: operation),
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
        canSaveDraft: _canSaveDraft(isNationalIdValid: valid),
      ),
    );
  }

  void updateValidity(String value) {
    final normalized = DigitNormalizer.normalize(value).trim();
    final parsed = JalaliDateParser.parse(normalized);
    final validUntil = _validUntil(parsed);
    emit(
      state.copyWith(
        validityText: normalized,
        validUntil: validUntil,
        isValidityValid: validUntil != null,
        isValidityError: normalized.isNotEmpty && validUntil == null,
        hasChanges: true,
        canSaveDraft: _canSaveDraft(isValidityValid: validUntil != null),
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
        canSaveDraft: false,
        canSubmit: state.termsAccepted,
        hasChanges: true,
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
        ),
      );
    } else {
      emit(state.copyWith(agents: agents));
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

  Future<void> submitAgents() async {
    var request = _createRequest(_submittedRequest?.idempotencyKey);
    if (_submittedRequest != null && request != _submittedRequest) {
      request = _createRequest(null);
    }
    _submittedRequest = request;
    emit(
      state.copyWith(
        submissionStatus: RequestStatus.loading,
        isEditable: false,
      ),
    );
    final result = await submitAgentsUseCase(request);
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
      ),
    );
  }

  void requestHome() {
    emit(
      state.copyWith(
        effect: state.hasChanges ? AgentEffect.confirmExit : AgentEffect.home,
        isExitToHome: true,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true
            ? (state.isExitToHome ? AgentEffect.home : AgentEffect.back)
            : null,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(effect: AgentEffect.home));
  }

  ListedDeposit? _resolveInitialDeposit(List<ListedDeposit> deposits) {
    final number = _normalizeDepositNumber(initialDepositNumber ?? '');
    return deposits
        .where(
          (deposit) =>
              number.isNotEmpty &&
              _normalizeDepositNumber(deposit.number) == number,
        )
        .firstOrNull;
  }

  String _normalizeDepositNumber(String number) =>
      DigitNormalizer.normalize(number).replaceAll(RegExp(r'[^0-9]'), '');

  bool _canSaveDraft({
    ListedDeposit? deposit,
    AgentOperation? operation,
    bool? isNationalIdValid,
    bool? isValidityValid,
  }) {
    return (deposit ?? state.deposit) != null &&
        (operation ?? state.operation) != null &&
        (isNationalIdValid ?? state.isNationalIdValid) &&
        (isValidityValid ?? state.isValidityValid);
  }

  DateTime? _validUntil(DateTime? parsed) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    return parsed != null && !parsed.isBefore(today) ? parsed : null;
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeAgentInteraction() {
    emit(state.copyWith(effect: null));
  }
}
