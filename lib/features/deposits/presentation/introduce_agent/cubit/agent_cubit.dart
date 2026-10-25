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
        failure: null,
        message: null,
      ),
    );
    return _fetchDeposits().then((result) {
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
        canSaveDraft: false,
        canSubmit: state.termsAccepted,
        hasChanges: true,
        failure: null,
        message: null,
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
        message: null,
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
          failure: null,
          message: null,
        ),
      );
    } else {
      emit(state.copyWith(agents: agents, failure: null, message: null));
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
        isEditable: false,
        failure: null,
        message: null,
      ),
    );
    return _submitAgents(request).then((result) {
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
        message: null,
      ),
    );
  }

  void requestHome() {
    emit(
      state.copyWith(
        effect: state.hasChanges ? AgentEffect.confirmExit : AgentEffect.home,
        isExitToHome: true,
        message: null,
      ),
    );
  }

  void applyExitConfirmation(bool? confirmed) {
    emit(
      state.copyWith(
        effect: confirmed == true
            ? (state.isExitToHome ? AgentEffect.home : AgentEffect.back)
            : null,
        message: null,
      ),
    );
  }

  void applyReceiptDismissal() {
    emit(state.copyWith(effect: AgentEffect.home, message: null));
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeAgentInteraction() {
    emit(state.copyWith(effect: null));
  }
}
