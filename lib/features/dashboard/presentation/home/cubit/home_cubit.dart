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
import '../../../domain/entities/dashboard_item.dart';
import '../../../domain/usecases/home_usecase.dart';
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

  final loadDashboardHomeUseCase = getIt<LoadDashboardHomeUseCase>();
  final loadDashboardItemsUseCaseForCards =
      getIt<LoadDashboardItemsUseCase<BankCard>>();
  final loadDashboardItemsUseCaseForDeposits =
      getIt<LoadDashboardItemsUseCase<BankDeposit>>();
  final loadDashboardItemsUseCaseForLoans =
      getIt<LoadDashboardItemsUseCase<BankLoan>>();

  static const maxFavorites = 8;

  Future<void> fetchDashboard() async {
    await Future.wait([
      fetchHome(),
      fetchCards(),
      fetchDeposits(),
      fetchLoans(),
    ]);
  }

  void selectTab(AppPrimaryTab tab) {
    emit(state.copyWith(selectedTab: tab, effect: HomeTabRequested(tab)));
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

  String _normalizeDrawerQuery(String query) {
    return _normalizeSearchCharacters(query.toLowerCase()).trim();
  }

  String _normalizeSearchCharacters(String value) {
    return value
        .replaceAll('ي', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('\u200c', ' ');
  }

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
      ),
    );
  }

  void requestService(DashboardService service) {
    if (service == DashboardService.assistant) {
      requestAssistant();
    } else {
      emit(state.copyWith(effect: HomeServiceRequested(service.id)));
    }
  }

  void requestAllServices() {
    emit(state.copyWith(effect: const HomeAllServicesRequested()));
  }

  void requestProfile() {
    emit(state.copyWith(effect: const HomeProfileRequested()));
  }

  void requestNotifications() {
    emit(
      state.copyWith(
        messages: state.messages ?? NotificationMessage.examples(),
        effect: const HomeNotificationsRequested(),
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

  String _normalizeServicePickerQuery(String value) {
    return _normalizeSearchCharacters(value.trim())
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  void requestFavoritesReset() {
    emit(state.copyWith(effect: const HomeFavoritesResetRequested()));
  }

  void applyFavoriteSelection(DashboardService? service) {
    if (service != null) addFavorite(service);
  }

  void applyResetConfirmation(bool? confirmed) {
    if (confirmed == true) resetFavorites();
  }

  Future<void> fetchHome() async {
    emit(
      state.copyWith(
        homeStatus: RequestStatus.loading,
        isEditingFavorites: false,
      ),
    );
    final result = await loadDashboardHomeUseCase();
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
            canAddFavorite: _canAddFavorite(services),
            isFavoritesLimitReached: _isFavoritesLimitReached(services),
          ),
        );
    }
  }

  bool _canAddFavorite(List<DashboardService> services) {
    return services.length < maxFavorites;
  }

  bool _isFavoritesLimitReached(List<DashboardService> services) {
    return services.length == maxFavorites;
  }

  bool _canConfirmFavorites(List<DashboardService> services) {
    return services.isNotEmpty || state.homeData!.favorites.isNotEmpty;
  }

  void openFavoritesEditing() {
    final services = _servicesForIds(state.homeData!.favorites);
    emit(
      state.copyWith(
        isEditingFavorites: true,
        favoriteServices: services,
        canConfirmFavorites: _canConfirmFavorites(services),
        canAddFavorite: _canAddFavorite(services),
        isFavoritesLimitReached: _isFavoritesLimitReached(services),
      ),
    );
  }

  void addFavorite(DashboardService service) {
    final services = [...state.favoriteServices, service];
    emit(
      state.copyWith(
        favoriteServices: services,
        canConfirmFavorites: _canConfirmFavorites(services),
        canAddFavorite: _canAddFavorite(services),
        isFavoritesLimitReached: _isFavoritesLimitReached(services),
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
        canConfirmFavorites: _canConfirmFavorites(services),
        canAddFavorite: _canAddFavorite(services),
        isFavoritesLimitReached: _isFavoritesLimitReached(services),
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
        canAddFavorite: _canAddFavorite(services),
        isFavoritesLimitReached: _isFavoritesLimitReached(services),
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

  Future<void> fetchCards() async {
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
      ),
    );
    final result = await loadDashboardItemsUseCaseForCards();
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
        final selected = _findRetainedSelection(data, previous?.id);
        emit(
          state.copyWith(
            cardsStatus: RequestStatus.success,
            visibleCards: data,
            selectedCard: selected,
            selectedCardIndex: _selectedItemIndex(data, selected),
            cardActions: _hasSelection(selected) ? _cardActions : const [],
            pinActions: _hasSelection(selected)
                ? _pinActions(selected!)
                : const [],
            cardQuickActions: _hasSelection(selected)
                ? _quickActions
                : const [],
            cardVisibility: {
              for (final card in data)
                card.id: visibility[card.id] ?? data.length == 1,
            },
          ),
        );
    }
  }

  T? _findRetainedSelection<T extends DashboardItem>(
    List<T> items,
    String? previousId,
  ) {
    return items.where((item) => item.id == previousId).firstOrNull ??
        items.firstOrNull;
  }

  bool _hasSelection(DashboardItem? selected) {
    return selected != null;
  }

  int _selectedItemIndex<T extends DashboardItem>(List<T> items, T? selected) {
    return _hasSelection(selected) ? items.indexOf(selected!) : 0;
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
    emit(state.copyWith(effect: HomeCardActionRequested(request)));
  }

  void requestCardNumberCopy(BankCard card) {
    emit(state.copyWith(effect: HomeCardNumberCopyRequested(card.number)));
  }

  void requestCardIbanCopy(BankCard card) {
    emit(state.copyWith(effect: HomeCardIbanCopyRequested(card.iban)));
  }

  Future<void> fetchDeposits() async {
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
      ),
    );
    final result = await loadDashboardItemsUseCaseForDeposits();
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
        final selected = _findRetainedSelection(data, previous?.id);
        emit(
          state.copyWith(
            depositsStatus: RequestStatus.success,
            visibleDeposits: data,
            selectedDeposit: selected,
            selectedDepositIndex: _selectedItemIndex(data, selected),
            depositActions: _hasSelection(selected)
                ? DepositAction.operations
                : const [],
            depositQuickActions: _hasSelection(selected)
                ? DepositAction.quick
                : const [],
            depositChequeActions: selected?.hasChequeOperations == true
                ? DepositAction.cheques
                : const [],
          ),
        );
    }
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
    emit(state.copyWith(effect: HomeDepositActionRequested(request)));
  }

  void requestDepositNumberCopy(BankDeposit deposit) {
    emit(
      state.copyWith(effect: HomeDepositNumberCopyRequested(deposit.number)),
    );
  }

  void requestDepositIbanCopy(BankDeposit deposit) {
    emit(state.copyWith(effect: HomeDepositIbanCopyRequested(deposit.iban)));
  }

  Future<void> fetchLoans() async {
    final previous = state.selectedLoan;

    emit(
      state.copyWith(
        loansStatus: RequestStatus.loading,
        visibleLoans: const [],
        selectedLoanIndex: 0,
        selectedLoan: null,
        loanActions: const [],
        loanQuickActions: const [],
      ),
    );
    final result = await loadDashboardItemsUseCaseForLoans();
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
        final selected = _findRetainedSelection(data, previous?.id);
        emit(
          state.copyWith(
            loansStatus: RequestStatus.success,
            visibleLoans: data,
            selectedLoan: selected,
            selectedLoanIndex: _selectedItemIndex(data, selected),
            loanActions: _hasSelection(selected)
                ? LoanAction.operations
                : const [],
            loanQuickActions: _hasSelection(selected)
                ? LoanAction.quick
                : const [],
          ),
        );
    }
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
    emit(state.copyWith(effect: HomeLoanActionRequested(request)));
  }

  void requestLoanNumberCopy(BankLoan loan) {
    emit(state.copyWith(effect: HomeLoanNumberCopyRequested(loan.number)));
  }

  void updateCardVisibility(BankCard card, bool visible) {
    emit(
      state.copyWith(
        cardVisibility: {...state.cardVisibility, card.id: visible},
      ),
    );
  }

  void requestCardMore(BankCard card) {
    emit(state.copyWith(effect: HomeCardMoreRequested(card)));
  }

  void requestLoanDetails(BankLoan loan) {
    emit(state.copyWith(effect: HomeLoanDetailsRequested(loan)));
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
        isHintTyping: _canTypeHint(isInputPresent: value.isNotEmpty),
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
      ),
    );
  }

  void updateHintPhrases(List<String> phrases) {
    _phrases = List.unmodifiable(phrases);
    _syncTypingTimer();
  }

  void updateForeground(bool foreground) {
    emit(
      state.copyWith(
        isForeground: foreground,
        isMotionEnabled: _isMotionEnabled(isForeground: foreground),
        isHintTyping: _canTypeHint(
          isMotionEnabled: _isMotionEnabled(isForeground: foreground),
        ),
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
    emit(
      state.copyWith(
        isMotionAllowed: _isMotionAllowed(
          enabled,
          animationsDisabled,
          tickerEnabled,
        ),
        isMotionEnabled: _isMotionEnabled(
          isMotionAllowed: _isMotionAllowed(
            enabled,
            animationsDisabled,
            tickerEnabled,
          ),
        ),
        isInputFocused: hasFocus,
        isHintTyping: _canTypeHint(
          isMotionEnabled: _isMotionEnabled(
            isMotionAllowed: _isMotionAllowed(
              enabled,
              animationsDisabled,
              tickerEnabled,
            ),
          ),
          isInputFocused: hasFocus,
        ),
      ),
    );
    _syncTypingTimer();
  }

  bool _isMotionAllowed(
    bool enabled,
    bool animationsDisabled,
    bool tickerEnabled,
  ) {
    return enabled && !animationsDisabled && tickerEnabled;
  }

  bool _isMotionEnabled({bool? isMotionAllowed, bool? isForeground}) {
    return (isMotionAllowed ?? state.isMotionAllowed) &&
        (isForeground ?? state.isForeground);
  }

  bool _canTypeHint({
    bool? isMotionEnabled,
    bool? isInputFocused,
    bool? isInputPresent,
  }) {
    return (isMotionEnabled ?? state.isMotionEnabled) &&
        !(isInputFocused ?? state.isInputFocused) &&
        !(isInputPresent ?? state.isInputPresent);
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
