import 'dart:async';

import 'package:characters/characters.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/notifications/notification_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/bank_card.dart';
import '../../../domain/entities/bank_deposit.dart';
import '../../../domain/entities/bank_loan.dart';
import '../../../domain/entities/dashboard_home_data.dart';
import '../../../domain/repositories/dashboard_repositories.dart';
import '../../../domain/usecases/home.dart';
import '../../shared/card_actions.dart';
import '../../shared/dashboard_drawer_group.dart';
import '../../shared/deposit_actions.dart';
import '../../shared/loan_actions.dart';
import '../../shared/dashboard_services.dart';
import '../../shared/dashboard_service_group.dart';
import '../../shared/dashboard_tab.dart';
import 'home_effect.dart';

part 'home_state.dart';

part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    HomeState initialState = const HomeState.initial(),
    this.drawerSectionLabels = const {},
    this.drawerServiceLabels = const {},
    this.servicePickerLabels = const {},
  }) : super(initialState);

  final Map<DashboardDrawerSection, String> drawerSectionLabels;
  final Map<DashboardService, String> drawerServiceLabels;
  final Map<DashboardService, String> servicePickerLabels;

  final _repositories = getIt<DashboardRepositories>();
  late final _loadHome = LoadDashboardHome(_repositories.home);
  late final _loadCards = LoadDashboardItems(_repositories.cards.getCards);
  late final _loadDeposits = LoadDashboardItems(
    _repositories.deposits.getDeposits,
  );
  late final _loadLoans = LoadDashboardItems(_repositories.loans.getLoans);

  static const maxFavorites = 8;

  Future<void> fetchDashboard() {
    return Future.wait([
      fetchHome(),
      fetchCards(),
      fetchDeposits(),
      fetchLoans(),
    ]).then((_) {});
  }

  void selectTab(AppPrimaryTab tab) {
    emit(
      state.copyWith(
        selectedTab: tab,
        effect: HomeTabRequested(tab),
        message: null,
      ),
    );
  }

  void requestMenu() {
    emit(
      state.copyWith(
        drawerQuery: '',
        drawerGroups: dashboardDrawerGroups,
        expandedDrawerSection: null,
        selectedDrawerSection: DashboardDrawerSection.home,
        drawerSelection: null,
        effect: const HomeMenuRequested(),
        message: null,
      ),
    );
  }

  void updateDrawerSearchQuery(String query) {
    final groups = _filterDrawerGroups(query);
    emit(
      state.copyWith(
        drawerQuery: query,
        drawerGroups: groups,
        expandedDrawerSection: groups
            .where((group) => group.services.isNotEmpty)
            .firstOrNull
            ?.section,
      ),
    );
  }

  List<DashboardDrawerGroup> _filterDrawerGroups(String query) {
    final normalized = _normalizeDrawerQuery(query);
    if (normalized.isEmpty) return dashboardDrawerGroups;
    return List.unmodifiable(
      dashboardDrawerGroups.expand((group) {
        if (_normalizeDrawerQuery(drawerSectionLabels[group.section] ?? '')
            .contains(normalized)) {
          return [group];
        }
        final services = group.services
            .where(
              (service) =>
                  _normalizeDrawerQuery(drawerServiceLabels[service] ?? '')
                      .contains(normalized),
            )
            .toList(growable: false);
        return services.isEmpty
            ? <DashboardDrawerGroup>[]
            : [
                DashboardDrawerGroup(
                  group.section,
                  List.unmodifiable(services),
                ),
              ];
      }),
    );
  }

  String _normalizeDrawerQuery(String query) => query
      .toLowerCase()
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll('\u200c', ' ')
      .trim();

  void selectDrawerSection(DashboardDrawerSection section) {
    switch (section) {
      case DashboardDrawerSection.home:
        emit(
          state.copyWith(drawerSelection: const DashboardDrawerHomeSelected()),
        );
      case DashboardDrawerSection.requests:
        emit(
          state.copyWith(
            drawerSelection: const DashboardDrawerServiceSelected(
              DashboardService.requests,
            ),
          ),
        );
      default:
        emit(
          state.copyWith(
            selectedDrawerSection: section,
            expandedDrawerSection: state.expandedDrawerSection == section
                ? null
                : section,
          ),
        );
    }
  }

  void selectDrawerService(DashboardService service) {
    emit(
      state.copyWith(drawerSelection: DashboardDrawerServiceSelected(service)),
    );
  }

  void applyDrawerSelection(DashboardDrawerSelection? selection) {
    switch (selection) {
      case DashboardDrawerHomeSelected():
        selectTab(AppPrimaryTab.dashboard);
      case DashboardDrawerServiceSelected(:final service):
        requestService(service);
      case null:
        break;
    }
  }

  void requestAssistant() {
    emit(
      state.copyWith(
        selectedTab: AppPrimaryTab.dashboard,
        effect: const HomeAssistantRequested(),
        message: null,
      ),
    );
  }

  void requestService(DashboardService service) {
    if (service == DashboardService.assistant) {
      requestAssistant();
    } else {
      emit(
        state.copyWith(effect: HomeServiceRequested(service.id), message: null),
      );
    }
  }

  void requestAllServices() {
    emit(
      state.copyWith(effect: const HomeAllServicesRequested(), message: null),
    );
  }

  void requestProfile() {
    emit(state.copyWith(effect: const HomeProfileRequested(), message: null));
  }

  void requestNotifications() {
    emit(
      state.copyWith(
        messages: state.messages ?? NotificationMessage.examples(),
        effect: const HomeNotificationsRequested(),
        message: null,
      ),
    );
  }

  void updateNotifications(List<NotificationMessage> messages) {
    emit(state.copyWith(messages: List.unmodifiable(messages)));
  }

  void requestFavoritePicker() {
    emit(
      state.copyWith(
        servicePickerQuery: '',
        servicePickerGroups: _filterServicePickerGroups('', const {}),
        servicePickerCollapsedCategories: const {},
        isServicePickerSearching: false,
        pickedService: null,
        effect: const HomeFavoritePickerRequested(),
        message: null,
      ),
    );
  }

  void updateServicePickerQuery(String value) {
    emit(
      state.copyWith(
        servicePickerQuery: value,
        servicePickerGroups: _filterServicePickerGroups(
          value,
          state.servicePickerCollapsedCategories,
        ),
        isServicePickerSearching: _normalizeServicePickerQuery(value)
            .isNotEmpty,
      ),
    );
  }

  void toggleServicePickerCategory(DashboardCategory category) {
    final collapsed = Set<DashboardCategory>.of(
      state.servicePickerCollapsedCategories,
    );
    if (!collapsed.remove(category)) collapsed.add(category);
    emit(
      state.copyWith(
        servicePickerCollapsedCategories: collapsed,
        servicePickerGroups: _filterServicePickerGroups(
          state.servicePickerQuery,
          collapsed,
        ),
      ),
    );
  }

  void selectPickerService(DashboardService service) {
    emit(state.copyWith(pickedService: service));
  }

  List<DashboardServiceGroup> _filterServicePickerGroups(
    String query,
    Set<DashboardCategory> collapsed,
  ) {
    final normalized = _normalizeServicePickerQuery(query);
    final excluded = state.favoriteServices
        .map((service) => service.id)
        .toSet();
    return [
      for (final category in DashboardCategory.values)
        if (category.services.any(
          (service) => _normalizeServicePickerQuery(
            servicePickerLabels[service] ?? service.id,
          ).contains(normalized),
        ))
          DashboardServiceGroup(
            category: category,
            choices: [
              for (final service in category.services)
                if (_normalizeServicePickerQuery(
                  servicePickerLabels[service] ?? service.id,
                ).contains(normalized))
                  DashboardServiceChoice(
                    service: service,
                    canSelect: !excluded.contains(service.id),
                  ),
            ],
            isCollapsed: normalized.isEmpty && collapsed.contains(category),
            canToggle:
                normalized.isEmpty && category == DashboardCategory.cards,
          ),
    ];
  }

  String _normalizeServicePickerQuery(String value) => value
      .trim()
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll('\u200c', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  void requestFavoritesReset() {
    emit(
      state.copyWith(
        effect: const HomeFavoritesResetRequested(),
        message: null,
      ),
    );
  }

  void applyFavoriteSelection(DashboardService? service) {
    if (service != null) addFavorite(service);
  }

  void applyResetConfirmation(bool? confirmed) {
    if (confirmed == true) resetFavorites();
  }

  Future<void> fetchHome() {
    emit(
      state.copyWith(
        homeStatus: RequestStatus.loading,
        homeData: null,
        isEditingFavorites: false,
        favoriteServices: const [],
        fixedServices: const [],
        canAddFavorite: true,
        isFavoritesLimitReached: false,
        failure: null,
        message: null,
      ),
    );
    return _loadHome().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              homeStatus: RequestStatus.failure,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          final home = data?.withFavorites(
            data.favorites.toSet().take(maxFavorites),
          );
          final services = _servicesForIds(home?.favorites ?? const []);
          emit(
            state.copyWith(
              homeStatus: RequestStatus.success,
              homeData: home,
              favoriteServices: services,
              fixedServices: _servicesForIds(home?.fixedServiceIds ?? const []),
              canAddFavorite: services.length < maxFavorites,
              isFavoritesLimitReached: services.length == maxFavorites,
            ),
          );
      }
    });
  }

  void beginFavoritesEditing() {
    final services = _servicesForIds(
      state.homeData!.favorites.isEmpty
          ? state.homeData!.suggestedServiceIds.toSet().take(maxFavorites)
          : state.homeData!.favorites,
    );
    emit(
      state.copyWith(
        isEditingFavorites: true,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: services.length == maxFavorites,
      ),
    );
  }

  void addFavorite(DashboardService service) {
    final services = [...state.favoriteServices, service];
    emit(
      state.copyWith(
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: services.length == maxFavorites,
      ),
    );
  }

  void removeFavorite(DashboardService service) {
    final services = state.favoriteServices
        .where((favorite) => favorite != service)
        .toList();
    emit(
      state.copyWith(
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: services.length == maxFavorites,
      ),
    );
  }

  void applyFavorites() {
    emit(
      state.copyWith(
        homeData: state.homeData!.withFavorites(
          state.favoriteServices.map((service) => service.id),
        ),
        isEditingFavorites: false,
      ),
    );
  }

  void cancelFavorites() {
    final services = _servicesForIds(state.homeData!.favorites);
    emit(
      state.copyWith(
        isEditingFavorites: false,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: services.length == maxFavorites,
      ),
    );
  }

  void resetFavorites() {
    emit(
      state.copyWith(
        homeData: state.homeData!.withFavorites([]),
        isEditingFavorites: false,
        favoriteServices: const [],
        canAddFavorite: true,
        isFavoritesLimitReached: false,
      ),
    );
  }

  void requestBack() {
    if (state.selectedTab != AppPrimaryTab.dashboard) {
      selectTab(AppPrimaryTab.dashboard);
    } else {
      cancelFavorites();
    }
  }

  List<DashboardService> _servicesForIds(Iterable<String> ids) => [
    for (final id in ids)
      for (final service in DashboardService.values)
        if (service.id == id) service,
  ];

  static const _cardActions = [
    CardAction.list,
    CardAction.virtualList,
    CardAction.changeDeposit,
    CardAction.reissue,
    CardAction.block,
  ];
  static const _quickActions = [
    CardAction.issue,
    CardAction.virtualCard,
    CardAction.giftBalance,
    CardAction.giftPurchase,
  ];

  List<CardAction> _pinActions(BankCard card) => [
    if (card.canSetSecondPin) CardAction.setSecondPin,
    CardAction.changeSecondPin,
    CardAction.forgotSecondPin,
    CardAction.changeFirstPin,
    CardAction.forgotFirstPin,
  ];

  Future<void> fetchCards() {
    final previous = state.selectedCard;
    final visibility = state.cardVisibility;
    emit(
      state.copyWith(
        cardsStatus: RequestStatus.loading,
        visibleCards: const [],
        selectedCardIndex: 0,
        selectedCard: null,
        cardActions: const [],
        pinActions: const [],
        cardQuickActions: const [],
        failure: null,
        message: null,
      ),
    );
    return _loadCards().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              cardsStatus: RequestStatus.failure,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          final selected =
              data.where((item) => item.id == previous?.id).firstOrNull ??
              data.firstOrNull;
          emit(
            state.copyWith(
              cardsStatus: RequestStatus.success,
              visibleCards: data,
              selectedCard: selected,
              selectedCardIndex: selected == null ? 0 : data.indexOf(selected),
              cardActions: selected == null ? const [] : _cardActions,
              pinActions: selected == null ? const [] : _pinActions(selected),
              cardQuickActions: selected == null ? const [] : _quickActions,
              cardVisibility: {
                for (final card in data)
                  card.id: visibility[card.id] ?? data.length == 1,
              },
            ),
          );
      }
    });
  }

  void selectCard(BankCard card) {
    emit(
      state.copyWith(
        selectedCard: card,
        selectedCardIndex: state.visibleCards.indexOf(card),
        cardActions: _cardActions,
        pinActions: _pinActions(card),
        cardQuickActions: _quickActions,
      ),
    );
  }

  void requestCardAction(CardAction action) {
    final request = CardActionRequest(
      action: action,
      card: state.selectedCard!,
    );
    emit(
      state.copyWith(effect: HomeCardActionRequested(request), message: null),
    );
  }

  void requestCardNumberCopy(BankCard card) {
    emit(
      state.copyWith(
        effect: HomeCardNumberCopyRequested(card.number),
        message: null,
      ),
    );
  }

  void requestCardIbanCopy(BankCard card) {
    emit(
      state.copyWith(
        effect: HomeCardIbanCopyRequested(card.iban),
        message: null,
      ),
    );
  }

  Future<void> fetchDeposits() {
    final previous = state.selectedDeposit;

    emit(
      state.copyWith(
        depositsStatus: RequestStatus.loading,
        visibleDeposits: const [],
        selectedDepositIndex: 0,
        selectedDeposit: null,
        depositActions: const [],
        depositQuickActions: const [],
        depositChequeActions: const [],
        failure: null,
        message: null,
      ),
    );
    return _loadDeposits().then((result) {
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
          final selected =
              data.where((item) => item.id == previous?.id).firstOrNull ??
              data.firstOrNull;
          emit(
            state.copyWith(
              depositsStatus: RequestStatus.success,
              visibleDeposits: data,
              selectedDeposit: selected,
              selectedDepositIndex: selected == null
                  ? 0
                  : data.indexOf(selected),
              depositActions: selected == null
                  ? const []
                  : DepositAction.operations,
              depositQuickActions: selected == null
                  ? const []
                  : DepositAction.quick,
              depositChequeActions: selected?.hasChequeOperations == true
                  ? DepositAction.cheques
                  : const [],
            ),
          );
      }
    });
  }

  void selectDeposit(BankDeposit deposit) {
    emit(
      state.copyWith(
        selectedDeposit: deposit,
        selectedDepositIndex: state.visibleDeposits.indexOf(deposit),
        depositActions: DepositAction.operations,
        depositQuickActions: DepositAction.quick,
        depositChequeActions: deposit.hasChequeOperations
            ? DepositAction.cheques
            : const [],
      ),
    );
  }

  void requestDepositAction(DepositAction action) {
    final request = DepositActionRequest(
      action: action,
      deposit: state.selectedDeposit!,
    );
    emit(
      state.copyWith(
        effect: HomeDepositActionRequested(request),
        message: null,
      ),
    );
  }

  void requestDepositNumberCopy(BankDeposit deposit) {
    emit(
      state.copyWith(
        effect: HomeDepositNumberCopyRequested(deposit.number),
        message: null,
      ),
    );
  }

  void requestDepositIbanCopy(BankDeposit deposit) {
    emit(
      state.copyWith(
        effect: HomeDepositIbanCopyRequested(deposit.iban),
        message: null,
      ),
    );
  }

  Future<void> fetchLoans() {
    final previous = state.selectedLoan;

    emit(
      state.copyWith(
        loansStatus: RequestStatus.loading,
        visibleLoans: const [],
        selectedLoanIndex: 0,
        selectedLoan: null,
        loanActions: const [],
        loanQuickActions: const [],
        failure: null,
        message: null,
      ),
    );
    return _loadLoans().then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              loansStatus: RequestStatus.failure,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          final selected =
              data.where((item) => item.id == previous?.id).firstOrNull ??
              data.firstOrNull;
          emit(
            state.copyWith(
              loansStatus: RequestStatus.success,
              visibleLoans: data,
              selectedLoan: selected,
              selectedLoanIndex: selected == null ? 0 : data.indexOf(selected),
              loanActions: selected == null ? const [] : LoanAction.operations,
              loanQuickActions: selected == null ? const [] : LoanAction.quick,
            ),
          );
      }
    });
  }

  void selectLoan(BankLoan loan) {
    emit(
      state.copyWith(
        selectedLoan: loan,
        selectedLoanIndex: state.visibleLoans.indexOf(loan),
        loanActions: LoanAction.operations,
        loanQuickActions: LoanAction.quick,
      ),
    );
  }

  void requestLoanAction(LoanAction action) {
    final request = LoanActionRequest(
      action: action,
      loan: state.selectedLoan!,
    );
    emit(
      state.copyWith(effect: HomeLoanActionRequested(request), message: null),
    );
  }

  void requestLoanNumberCopy(BankLoan loan) {
    emit(
      state.copyWith(
        effect: HomeLoanNumberCopyRequested(loan.number),
        message: null,
      ),
    );
  }

  void updateCardVisibility(BankCard card, bool visible) {
    emit(
      state.copyWith(
        cardVisibility: {...state.cardVisibility, card.id: visible},
      ),
    );
  }

  void requestCardMore(BankCard card) {
    emit(state.copyWith(effect: HomeCardMoreRequested(card), message: null));
  }

  void requestLoanDetails(BankLoan loan) {
    emit(state.copyWith(effect: HomeLoanDetailsRequested(loan), message: null));
  }

  Timer? _typingTimer;
  List<String> _phrases = const [];
  int _phraseIndex = 0;
  int _position = 0;
  int _holdTicks = 0;
  bool _erasing = false;

  void updatePrompt(String value) {
    emit(
      state.copyWith(
        prompt: value,
        isInputPresent: value.isNotEmpty,
        canSubmitPrompt: value.trim().isNotEmpty,
        isHintTyping:
            state.isMotionEnabled && !state.isInputFocused && value.isEmpty,
      ),
    );
    _syncTypingTimer();
  }

  void submitPrompt() {
    final prompt = state.prompt.trim();
    emit(
      state.copyWith(
        submittedPrompt: prompt,
        effect: HomePromptSubmitted(prompt),
        message: null,
      ),
    );
  }

  void updateHintPhrases(List<String> phrases) {
    _phrases = List.unmodifiable(phrases);
    _syncTypingTimer();
  }

  void updateForeground(bool foreground) {
    final enabled = state.isMotionAllowed && foreground;
    emit(
      state.copyWith(
        isForeground: foreground,
        isMotionEnabled: enabled,
        isHintTyping: enabled && !state.isInputFocused && !state.isInputPresent,
      ),
    );
    _syncTypingTimer();
  }

  void updateMotion({
    required bool enabled,
    required bool animationsDisabled,
    required bool tickerEnabled,
    required bool hasFocus,
  }) {
    final allowed = enabled && !animationsDisabled && tickerEnabled;
    final motion = allowed && state.isForeground;
    emit(
      state.copyWith(
        isMotionAllowed: allowed,
        isMotionEnabled: motion,
        isInputFocused: hasFocus,
        isHintTyping: motion && !hasFocus && !state.isInputPresent,
      ),
    );
    _syncTypingTimer();
  }

  // Own only the timer resource here; each action publishes its own State.
  void _syncTypingTimer() {
    if (state.isHintTyping && _phrases.isNotEmpty) {
      _typingTimer ??= Timer.periodic(
        const Duration(milliseconds: 90),
        (_) => _typeNextHint(),
      );
    } else {
      _typingTimer?.cancel();
      _typingTimer = null;
    }
  }

  void _typeNextHint() {
    if (_holdTicks > 0) {
      _holdTicks--;
    } else {
      final phrase = _phrases[_phraseIndex];
      final length = phrase.characters.length;
      if (_erasing) {
        _position--;
        if (_position <= 0) {
          _position = 0;
          _erasing = false;
          _phraseIndex = (_phraseIndex + 1) % _phrases.length;
          _holdTicks = 5;
        }
      } else {
        _position++;
        if (_position >= length) {
          _position = length;
          _erasing = true;
          _holdTicks = 24;
        }
      }
      emit(
        state.copyWith(typedHint: phrase.characters.take(_position).toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    return super.close();
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeHomeInteraction() {
    emit(state.copyWith(effect: null));
  }
}
