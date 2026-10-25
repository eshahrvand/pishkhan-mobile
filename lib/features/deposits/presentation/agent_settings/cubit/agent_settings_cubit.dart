import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/deposit_agent.dart';
import '../../../domain/repositories/agent_settings_repository.dart';
import '../../../domain/usecases/agent_settings.dart';
import 'agent_settings_effect.dart';

export '../../../domain/entities/deposit_agent.dart';
export 'agent_settings_effect.dart';

part 'agent_settings_state.dart';
part 'agent_settings_cubit.freezed.dart';

class AgentSettingsCubit extends Cubit<AgentSettingsState> {
  AgentSettingsCubit({
    this.initialDepositNumber,
    AgentSettingsState initialState = const AgentSettingsState.initial(),
  }) : super(initialState);

  final String? initialDepositNumber;
  final _repository = getIt<AgentSettingsRepository>();
  late final _fetchAgents = FetchAgents(_repository);

  Future<void> fetchAgents() {
    final resolveEntry = state.depositNumbers.isEmpty;
    emit(
      state.copyWith(
        agentsStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return _fetchAgents().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              agentsStatus: RequestStatus.failure,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          final deposits =
              data.map((record) => record.depositNumber).toSet().toList()
                ..sort();
          final requestedNumber = DigitNormalizer.normalize(
            initialDepositNumber ?? '',
          ).replaceAll(RegExp(r'[^0-9]'), '');
          final entryDeposit = resolveEntry
              ? deposits
                    .where(
                      (deposit) =>
                          DigitNormalizer.normalize(deposit)
                              .replaceAll(RegExp(r'[^0-9]'), '') ==
                          requestedNumber,
                    )
                    .firstOrNull
              : null;
          final depositFilter = entryDeposit == null
              ? state.depositFilter
              : {entryDeposit};
          emit(
            state.copyWith(
              agentsStatus: RequestStatus.success,
              agents: data,
              depositNumbers: deposits,
              depositFilter: depositFilter,
              visibleAgents: _filterAgents(
                data,
                state.tab,
                depositFilter,
                state.kindFilter,
                state.statusFilter,
              ),
            ),
          );
      }
    });
  }

  void selectTab(AgentTab tab) {
    emit(
      state.copyWith(
        tab: tab,
        canAddAgent: tab == AgentTab.myAgents,
        visibleAgents: _filterAgents(
          state.agents,
          tab,
          state.depositFilter,
          state.kindFilter,
          state.statusFilter,
        ),
      ),
    );
  }

  void requestDepositFilter() {
    if (state.depositFilter != null) {
      emit(
        state.copyWith(
          depositFilter: null,
          visibleAgents: _filterAgents(
            state.agents,
            state.tab,
            null,
            state.kindFilter,
            state.statusFilter,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          draftDeposits: state.depositNumbers.toSet(),
          isEveryDepositSelected: true,
          effect: const AgentDepositFilterRequested(),
          message: null,
        ),
      );
    }
  }

  void requestKindFilter() {
    if (state.kindFilter != null) {
      emit(
        state.copyWith(
          kindFilter: null,
          visibleAgents: _filterAgents(
            state.agents,
            state.tab,
            state.depositFilter,
            null,
            state.statusFilter,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          draftKinds: AgentKind.values.toSet(),
          isEveryKindSelected: true,
          effect: const AgentKindFilterRequested(),
          message: null,
        ),
      );
    }
  }

  void requestStatusFilter() {
    if (state.statusFilter != null) {
      emit(
        state.copyWith(
          statusFilter: null,
          visibleAgents: _filterAgents(
            state.agents,
            state.tab,
            state.depositFilter,
            state.kindFilter,
            null,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          draftStatuses: AgentStatus.values.toSet(),
          isEveryStatusSelected: true,
          effect: const AgentStatusFilterRequested(),
          message: null,
        ),
      );
    }
  }

  void toggleDraftDeposit(String depositNumber) {
    final deposits = state.draftDeposits.contains(depositNumber)
        ? state.draftDeposits.difference({depositNumber})
        : state.draftDeposits.union({depositNumber});
    emit(
      state.copyWith(
        draftDeposits: deposits,
        isEveryDepositSelected: deposits.length == state.depositNumbers.length,
      ),
    );
  }

  void toggleDraftKind(AgentKind kind) {
    final kinds = state.draftKinds.contains(kind)
        ? state.draftKinds.difference({kind})
        : state.draftKinds.union({kind});
    emit(
      state.copyWith(
        draftKinds: kinds,
        isEveryKindSelected: kinds.length == AgentKind.values.length,
      ),
    );
  }

  void toggleDraftStatus(AgentStatus status) {
    final statuses = state.draftStatuses.contains(status)
        ? state.draftStatuses.difference({status})
        : state.draftStatuses.union({status});
    emit(
      state.copyWith(
        draftStatuses: statuses,
        isEveryStatusSelected: statuses.length == AgentStatus.values.length,
      ),
    );
  }

  void toggleAllDraftDeposits() {
    emit(
      state.copyWith(
        draftDeposits: state.isEveryDepositSelected
            ? <String>{}
            : state.depositNumbers.toSet(),
        isEveryDepositSelected: !state.isEveryDepositSelected,
      ),
    );
  }

  void toggleAllDraftKinds() {
    emit(
      state.copyWith(
        draftKinds: state.isEveryKindSelected
            ? <AgentKind>{}
            : AgentKind.values.toSet(),
        isEveryKindSelected: !state.isEveryKindSelected,
      ),
    );
  }

  void toggleAllDraftStatuses() {
    emit(
      state.copyWith(
        draftStatuses: state.isEveryStatusSelected
            ? <AgentStatus>{}
            : AgentStatus.values.toSet(),
        isEveryStatusSelected: !state.isEveryStatusSelected,
      ),
    );
  }

  void applyDepositFilterResult(bool? applied) {
    if (applied == true) {
      final deposits = state.isEveryDepositSelected
          ? null
          : state.draftDeposits;
      emit(
        state.copyWith(
          depositFilter: deposits,
          draftDeposits: <String>{},
          isEveryDepositSelected: false,
          visibleAgents: _filterAgents(
            state.agents,
            state.tab,
            deposits,
            state.kindFilter,
            state.statusFilter,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          draftDeposits: <String>{},
          isEveryDepositSelected: false,
        ),
      );
    }
  }

  void applyKindFilterResult(bool? applied) {
    if (applied == true) {
      final kinds = state.isEveryKindSelected ? null : state.draftKinds;
      emit(
        state.copyWith(
          kindFilter: kinds,
          draftKinds: <AgentKind>{},
          isEveryKindSelected: false,
          visibleAgents: _filterAgents(
            state.agents,
            state.tab,
            state.depositFilter,
            kinds,
            state.statusFilter,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(draftKinds: <AgentKind>{}, isEveryKindSelected: false),
      );
    }
  }

  void applyStatusFilterResult(bool? applied) {
    if (applied == true) {
      final statuses = state.isEveryStatusSelected ? null : state.draftStatuses;
      emit(
        state.copyWith(
          statusFilter: statuses,
          draftStatuses: <AgentStatus>{},
          isEveryStatusSelected: false,
          visibleAgents: _filterAgents(
            state.agents,
            state.tab,
            state.depositFilter,
            state.kindFilter,
            statuses,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          draftStatuses: <AgentStatus>{},
          isEveryStatusSelected: false,
        ),
      );
    }
  }

  void requestAgentActions(DepositAgent agent) {
    emit(state.copyWith(effect: AgentActionsRequested(agent), message: null));
  }

  void selectAgentAction(DepositAgent agent, AgentAction? action) {
    switch (action) {
      case AgentAction.details:
        emit(state.copyWith(details: agent));
      case AgentAction.cancel:
        requestCancellation();
      case null:
        break;
    }
  }

  void requestCancellation() {
    emit(
      state.copyWith(effect: const AgentUnavailableRequested(), message: null),
    );
  }

  void requestIntroduction() {
    emit(
      state.copyWith(
        effect: AgentIntroductionRequested(initialDepositNumber),
        message: null,
      ),
    );
  }

  void requestBack() {
    if (state.details != null) {
      emit(state.copyWith(details: null));
    } else {
      emit(state.copyWith(effect: const AgentBackRequested(), message: null));
    }
  }

  void requestAssistant() {
    emit(
      state.copyWith(effect: const AgentAssistantRequested(), message: null),
    );
  }

  List<DepositAgent> _filterAgents(
    List<DepositAgent> agents,
    AgentTab tab,
    Set<String>? deposits,
    Set<AgentKind>? kinds,
    Set<AgentStatus>? statuses,
  ) {
    return agents
        .where(
          (record) =>
              record.tab == tab &&
              (deposits == null || deposits.contains(record.depositNumber)) &&
              (kinds == null || kinds.contains(record.kind)) &&
              (statuses == null || statuses.contains(record.status)),
        )
        .toList();
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeAgentSettingsInteraction() {
    emit(state.copyWith(effect: null));
  }
}
