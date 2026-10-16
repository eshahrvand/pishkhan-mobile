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
import '../../shared/deposit_actions.dart';
import '../../shared/loan_actions.dart';
import '../../shared/dashboard_services.dart';
import '../../shared/dashboard_tab.dart';
import 'home_effect.dart';

part 'home_state.dart';

part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required DashboardRepositories repositories,
    HomeState initialState = const HomeState.initial(),
  }) : _repositories = repositories,
       _loadHome = LoadDashboardHome(repositories.home),
       _loadCards = LoadDashboardItems(repositories.cards.getCards),
       _loadDeposits = LoadDashboardItems(repositories.deposits.getDeposits),
       _loadLoans = LoadDashboardItems(repositories.loans.getLoans),
       super(initialState);
  DashboardRepositories _repositories;
  LoadDashboardItems<BankCard> _loadCards;
  LoadDashboardItems<BankDeposit> _loadDeposits;
  LoadDashboardItems<BankLoan> _loadLoans;
  // Loading one tab must not invalidate another tab's pending response.
  int _cardsRequest = 0;
  int _depositsRequest = 0;
  int _loansRequest = 0;

  Future<void> load() async {
    await Future.wait([loadHome(), loadCards(), loadDeposits(), loadLoans()]);
  }

  Future<void> changeRepositories(DashboardRepositories repositories) async {
    if (isClosed) return;
    final previous = _repositories;
    _repositories = repositories;
    final pending = <Future<void>>[];
    if (previous.home != repositories.home) {
      _loadHome = LoadDashboardHome(repositories.home);
      pending.add(loadHome());
    }
    if (previous.cards != repositories.cards) {
      _loadCards = LoadDashboardItems(repositories.cards.getCards);
      pending.add(loadCards());
    }
    if (previous.deposits != repositories.deposits) {
      _loadDeposits = LoadDashboardItems(repositories.deposits.getDeposits);
      pending.add(loadDeposits());
    }
    if (previous.loans != repositories.loans) {
      _loadLoans = LoadDashboardItems(repositories.loans.getLoans);
      pending.add(loadLoans());
    }
    await Future.wait(pending);
  }

  void selectTab(AppPrimaryTab tab) {
    if (isClosed) return;
    emit(
      state.copyWith(
        selectedTab: tab,
        effect: HomeTabRequested(tab),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestMenu([AppPrimaryTab tab = AppPrimaryTab.dashboard]) {
    if (isClosed) return;
    emit(
      state.copyWith(
        effect: HomeMenuRequested(
          category: switch (tab) {
            AppPrimaryTab.deposits => DashboardService.deposits,
            AppPrimaryTab.loans => DashboardService.loans,
            _ => null,
          },
        ),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestAssistant() {
    if (isClosed) return;
    emit(
      state.copyWith(
        selectedTab: AppPrimaryTab.dashboard,
        effect: const HomeAssistantRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestService(DashboardService service) {
    if (isClosed) return;
    if (service == DashboardService.assistant) {
      requestAssistant();
      return;
    }
    emit(
      state.copyWith(
        effect: HomeServiceRequested(service.id),
        effectId: state.effectId + 1,
      ),
    );
  }

  void submitPrompt(String value) {
    if (isClosed) return;
    final prompt = value.trim();
    if (prompt.isEmpty) return;
    emit(
      state.copyWith(
        submittedPrompt: prompt,
        effect: HomePromptSubmitted(prompt),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestProfile() {
    if (isClosed) return;
    emit(
      state.copyWith(
        effect: const HomeProfileRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestNotifications() {
    if (isClosed) return;
    emit(
      state.copyWith(
        effect: const HomeNotificationsRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestFavoritePicker() {
    if (isClosed || state.draft == null || !state.canAddFavorite) return;
    emit(
      state.copyWith(
        effect: const HomeFavoritePickerRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestFavoritesReset() {
    if (isClosed || state.draft == null || state.homeData == null) return;
    emit(
      state.copyWith(
        effect: const HomeFavoritesResetRequested(),
        effectId: state.effectId + 1,
      ),
    );
  }

  static const maxFavorites = 8;
  LoadDashboardHome _loadHome;
  int _homeRequest = 0;

  Future<void> loadHome() async {
    if (isClosed) return;
    final token = ++_homeRequest;
    emit(
      state.copyWith(
        homeStatus: RequestStatus.loading,
        homeData: null,
        draft: null,
        homeFailure: null,
        activeFavorites: const [],
        favoriteServices: const [],
        fixedServices: const [],
        canAddFavorite: true,
        isFavoritesLimitReached: false,
      ),
    );
    final result = await _loadHome();
    if (isClosed || token != _homeRequest) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            homeStatus: RequestStatus.failure,
            homeFailure: failure,
          ),
        );
      case Success(:final data):
        final home = data?.withFavorites(
          data.favorites.toSet().take(maxFavorites),
        );
        final favorites = home?.favorites ?? const <String>[];
        final services = getServices(favorites);
        emit(
          state.copyWith(
            homeStatus: RequestStatus.success,
            homeData: home,
            activeFavorites: favorites,
            favoriteServices: services,
            fixedServices: getServices(home?.fixedServiceIds ?? const []),
            canAddFavorite: services.length < maxFavorites,
            isFavoritesLimitReached: favorites.length == maxFavorites,
          ),
        );
    }
  }

  void editFavorites() {
    if (state.homeStatus != RequestStatus.success || state.homeData == null) {
      return;
    }
    final favorites = state.homeData!.favorites.isEmpty
        ? state.homeData!.suggestedServiceIds
              .toSet()
              .take(maxFavorites)
              .toList()
        : state.homeData!.favorites;
    final services = getServices(favorites);
    emit(
      state.copyWith(
        draft: favorites,
        activeFavorites: favorites,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }

  void addFavorite(String id) {
    if (state.homeStatus != RequestStatus.success ||
        state.homeData == null ||
        state.draft == null ||
        state.draft!.length >= maxFavorites ||
        state.draft!.contains(id)) {
      return;
    }
    final favorites = [...state.draft!, id];
    final services = getServices(favorites);
    emit(
      state.copyWith(
        draft: favorites,
        activeFavorites: favorites,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }

  void removeFavorite(String id) {
    if (state.homeStatus != RequestStatus.success ||
        state.homeData == null ||
        state.draft == null) {
      return;
    }
    final favorites = state.draft!.where((item) => item != id).toList();
    final services = getServices(favorites);
    emit(
      state.copyWith(
        draft: favorites,
        activeFavorites: favorites,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }

  void confirmFavorites() {
    if (state.homeStatus != RequestStatus.success || state.homeData == null) {
      return;
    }
    final favorites = state.draft ?? state.homeData!.favorites;
    final services = getServices(favorites);
    emit(
      state.copyWith(
        homeData: state.homeData!.withFavorites(favorites),
        draft: null,
        activeFavorites: favorites,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }

  void cancelFavorites() {
    if (state.homeStatus != RequestStatus.success || state.homeData == null) {
      return;
    }
    final favorites = state.homeData!.favorites;
    final services = getServices(favorites);
    emit(
      state.copyWith(
        draft: null,
        activeFavorites: favorites,
        favoriteServices: services,
        canAddFavorite: services.length < maxFavorites,
        isFavoritesLimitReached: favorites.length == maxFavorites,
      ),
    );
  }

  void resetFavorites() {
    if (state.homeStatus != RequestStatus.success || state.homeData == null) {
      return;
    }
    emit(
      state.copyWith(
        homeData: state.homeData!.withFavorites([]),
        draft: null,
        activeFavorites: const [],
        favoriteServices: const [],
        canAddFavorite: true,
        isFavoritesLimitReached: false,
      ),
    );
  }

  List<DashboardService> getServices(List<String> ids) {
    return [
      for (final id in ids)
        for (final service in DashboardService.values)
          if (service.id == id) service,
    ];
  }

  static const _cardActions = [
    CardAction.reissue,
    CardAction.changeDeposit,
    CardAction.block,
  ];
  static const _quickActions = [
    CardAction.issue,
    CardAction.virtualCard,
    CardAction.giftPurchase,
    CardAction.giftBalance,
  ];

  List<CardAction> getCardPinActions(BankCard? card) {
    if (card == null) return const [];
    return [
      CardAction.changeFirstPin,
      card.canSetSecondPin
          ? CardAction.setSecondPin
          : CardAction.forgotSecondPin,
      CardAction.forgotFirstPin,
    ];
  }

  CardActionRequest? requestCardAction(CardAction action) {
    if (isClosed ||
        state.cardsStatus != RequestStatus.success ||
        state.selectedCard == null ||
        !(state.cardActions.contains(action) ||
            state.pinActions.contains(action) ||
            state.cardQuickActions.contains(action))) {
      return null;
    }
    final request = CardActionRequest(
      action: action,
      card: state.selectedCard!,
    );
    emit(
      state.copyWith(
        effect: HomeCardActionRequested(request),
        effectId: state.effectId + 1,
      ),
    );
    return request;
  }

  void requestCardMore(String cardId) {
    if (isClosed || state.cardsStatus != RequestStatus.success) return;
    final card = state.visibleCards
        .where((card) => card.id == cardId)
        .firstOrNull;
    if (card == null) return;
    emit(
      state.copyWith(
        effect: HomeCardMoreRequested(card),
        effectId: state.effectId + 1,
      ),
    );
  }

  void copyCardNumber(String cardId) {
    if (isClosed || state.cardsStatus != RequestStatus.success) return;
    final card = state.visibleCards
        .where((card) => card.id == cardId)
        .firstOrNull;
    if (card == null) return;
    emit(
      state.copyWith(
        effect: HomeCardNumberCopyRequested(card.number),
        effectId: state.effectId + 1,
      ),
    );
  }

  void copyCardIban(String cardId) {
    if (isClosed || state.cardsStatus != RequestStatus.success) return;
    final card = state.visibleCards
        .where((card) => card.id == cardId)
        .firstOrNull;
    if (card == null) return;
    emit(
      state.copyWith(
        effect: HomeCardIbanCopyRequested(card.iban),
        effectId: state.effectId + 1,
      ),
    );
  }

  Future<void> loadCards() async {
    if (isClosed) return;
    final token = ++_cardsRequest;
    final previous = state;
    emit(
      state.copyWith(
        cardsStatus: RequestStatus.loading,
        cardsFailure: null,
        visibleCards: const [],
        selectedCardIndex: 0,
        selectedCard: null,
        cardActions: const [],
        pinActions: const [],
        cardQuickActions: const [],
        effect: null,
      ),
    );
    final result = await _loadCards();
    if (isClosed || token != _cardsRequest) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            cardsStatus: RequestStatus.failure,
            cardsFailure: failure,
            visibleCards: const [],
            selectedCardIndex: 0,
            selectedCard: null,
          ),
        );
      case Success(:final data):
        final id = data.any((item) => item.id == previous.selectedCardId)
            ? previous.selectedCardId
            : data.firstOrNull?.id;
        final index = data.indexWhere((item) => item.id == id);
        emit(
          state.copyWith(
            cardsStatus: RequestStatus.success,
            cards: data.isEmpty ? null : data,
            selectedCardId: id,
            visibleCards: data,
            selectedCardIndex: index < 0 ? 0 : index,
            selectedCard: index < 0 ? null : data[index],
            cardActions: index < 0 ? const [] : _cardActions,
            pinActions: getCardPinActions(index < 0 ? null : data[index]),
            cardQuickActions: index < 0 ? const [] : _quickActions,
            cardVisibility: {
              for (final item in data)
                item.id: previous.cardVisibility[item.id] ?? data.length == 1,
            },
          ),
        );
    }
  }

  void selectCard(int index) {
    final items = state.cards;
    if (state.cardsStatus != RequestStatus.success ||
        items == null ||
        index < 0 ||
        index >= items.length) {
      return;
    }
    final selectedIndex = items.indexWhere(
      (item) => item.id == items[index].id,
    );
    if (state.selectedCardId == items[selectedIndex].id &&
        state.selectedCardIndex == selectedIndex) {
      return;
    }
    emit(
      state.copyWith(
        selectedCardId: items[index].id,
        selectedCardIndex: selectedIndex,
        selectedCard: items[selectedIndex],
        cardActions: _cardActions,
        pinActions: getCardPinActions(items[selectedIndex]),
        cardQuickActions: _quickActions,
        effect: HomeCardSelectionChanged(items[selectedIndex]),
        effectId: state.effectId + 1,
      ),
    );
  }

  void setCardVisibility(String id, bool value) {
    if (state.cardsStatus != RequestStatus.success ||
        !(state.cards?.any((item) => item.id == id) ?? false)) {
      return;
    }
    emit(state.copyWith(cardVisibility: {...state.cardVisibility, id: value}));
  }

  Future<void> loadDeposits() async {
    if (isClosed) return;
    final token = ++_depositsRequest;
    final previous = state;
    emit(
      state.copyWith(
        depositsStatus: RequestStatus.loading,
        depositsFailure: null,
        visibleDeposits: const [],
        selectedDepositIndex: 0,
        selectedDeposit: null,
        depositActions: const [],
        depositQuickActions: const [],
        depositChequeActions: const [],
      ),
    );
    final result = await _loadDeposits();
    if (isClosed || token != _depositsRequest) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            depositsStatus: RequestStatus.failure,
            depositsFailure: failure,
            visibleDeposits: const [],
            selectedDepositIndex: 0,
            selectedDeposit: null,
            depositActions: const [],
            depositQuickActions: const [],
            depositChequeActions: const [],
          ),
        );
      case Success(:final data):
        final id = data.any((item) => item.id == previous.selectedDepositId)
            ? previous.selectedDepositId
            : data.firstOrNull?.id;
        final index = data.indexWhere((item) => item.id == id);
        emit(
          state.copyWith(
            depositsStatus: RequestStatus.success,
            deposits: data.isEmpty ? null : data,
            selectedDepositId: id,
            visibleDeposits: data,
            selectedDepositIndex: index < 0 ? 0 : index,
            selectedDeposit: index < 0 ? null : data[index],
            depositActions: index < 0 ? const [] : DepositAction.operations,
            depositQuickActions: index < 0 ? const [] : DepositAction.quick,
            depositChequeActions: index >= 0 && data[index].hasChequeOperations
                ? DepositAction.cheques
                : const [],
          ),
        );
    }
  }

  void selectDeposit(int index) {
    final items = state.deposits;
    if (state.depositsStatus != RequestStatus.success ||
        items == null ||
        index < 0 ||
        index >= items.length) {
      return;
    }
    final selectedIndex = items.indexWhere(
      (item) => item.id == items[index].id,
    );
    if (state.selectedDepositId == items[selectedIndex].id &&
        state.selectedDepositIndex == selectedIndex) {
      return;
    }
    emit(
      state.copyWith(
        selectedDepositId: items[index].id,
        selectedDepositIndex: selectedIndex,
        selectedDeposit: items[selectedIndex],
        depositActions: DepositAction.operations,
        depositQuickActions: DepositAction.quick,
        depositChequeActions: items[selectedIndex].hasChequeOperations
            ? DepositAction.cheques
            : const [],
        effect: HomeDepositSelectionChanged(items[selectedIndex]),
        effectId: state.effectId + 1,
      ),
    );
  }

  Future<void> loadLoans() async {
    if (isClosed) return;
    final token = ++_loansRequest;
    final previous = state;
    emit(
      state.copyWith(
        loansStatus: RequestStatus.loading,
        loansFailure: null,
        visibleLoans: const [],
        selectedLoanIndex: 0,
        selectedLoan: null,
        loanActions: const [],
        loanQuickActions: const [],
      ),
    );
    final result = await _loadLoans();
    if (isClosed || token != _loansRequest) return;
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            loansStatus: RequestStatus.failure,
            loansFailure: failure,
            visibleLoans: const [],
            selectedLoanIndex: 0,
            selectedLoan: null,
            loanActions: const [],
            loanQuickActions: const [],
          ),
        );
      case Success(:final data):
        final id = data.any((item) => item.id == previous.selectedLoanId)
            ? previous.selectedLoanId
            : data.firstOrNull?.id;
        final index = data.indexWhere((item) => item.id == id);
        emit(
          state.copyWith(
            loansStatus: RequestStatus.success,
            loans: data.isEmpty ? null : data,
            selectedLoanId: id,
            visibleLoans: data,
            selectedLoanIndex: index < 0 ? 0 : index,
            selectedLoan: index < 0 ? null : data[index],
            loanActions: index < 0 ? const [] : LoanAction.operations,
            loanQuickActions: index < 0 ? const [] : LoanAction.quick,
          ),
        );
    }
  }

  void selectLoan(int index) {
    final items = state.loans;
    if (state.loansStatus != RequestStatus.success ||
        items == null ||
        index < 0 ||
        index >= items.length) {
      return;
    }
    final selectedIndex = items.indexWhere(
      (item) => item.id == items[index].id,
    );
    if (state.selectedLoanId == items[selectedIndex].id &&
        state.selectedLoanIndex == selectedIndex) {
      return;
    }
    emit(
      state.copyWith(
        selectedLoanId: items[index].id,
        selectedLoanIndex: selectedIndex,
        selectedLoan: items[selectedIndex],
        loanActions: LoanAction.operations,
        loanQuickActions: LoanAction.quick,
        effect: HomeLoanSelectionChanged(items[selectedIndex]),
        effectId: state.effectId + 1,
      ),
    );
  }

  DepositActionRequest? requestDepositAction(DepositAction action) {
    if (isClosed ||
        state.depositsStatus != RequestStatus.success ||
        state.selectedDeposit == null ||
        !(state.depositActions.contains(action) ||
            state.depositQuickActions.contains(action) ||
            state.depositChequeActions.contains(action))) {
      return null;
    }
    final request = DepositActionRequest(
      action: action,
      deposit: state.selectedDeposit!,
    );
    emit(
      state.copyWith(
        effect: HomeDepositActionRequested(request),
        effectId: state.effectId + 1,
      ),
    );
    return request;
  }

  void copyDepositNumber(String id) {
    if (isClosed || state.depositsStatus != RequestStatus.success) return;
    final item = state.visibleDeposits
        .where((item) => item.id == id)
        .firstOrNull;
    if (item == null) return;
    emit(
      state.copyWith(
        effect: HomeDepositNumberCopyRequested(item.number),
        effectId: state.effectId + 1,
      ),
    );
  }

  void copyDepositIban(String id) {
    if (isClosed || state.depositsStatus != RequestStatus.success) return;
    final item = state.visibleDeposits
        .where((item) => item.id == id)
        .firstOrNull;
    if (item == null) return;
    emit(
      state.copyWith(
        effect: HomeDepositIbanCopyRequested(item.iban),
        effectId: state.effectId + 1,
      ),
    );
  }

  LoanActionRequest? requestLoanAction(LoanAction action) {
    if (isClosed ||
        state.loansStatus != RequestStatus.success ||
        state.selectedLoan == null ||
        !(state.loanActions.contains(action) ||
            state.loanQuickActions.contains(action))) {
      return null;
    }
    final request = LoanActionRequest(
      action: action,
      loan: state.selectedLoan!,
    );
    emit(
      state.copyWith(
        effect: HomeLoanActionRequested(request),
        effectId: state.effectId + 1,
      ),
    );
    return request;
  }

  void copyLoanNumber(String id) {
    if (isClosed || state.loansStatus != RequestStatus.success) return;
    final item = state.visibleLoans.where((item) => item.id == id).firstOrNull;
    if (item == null) return;
    emit(
      state.copyWith(
        effect: HomeLoanNumberCopyRequested(item.number),
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestLoanDetails(String id) {
    if (isClosed || state.loansStatus != RequestStatus.success) return;
    final loan = state.visibleLoans.where((loan) => loan.id == id).firstOrNull;
    if (loan == null) return;
    emit(
      state.copyWith(
        effect: HomeLoanDetailsRequested(loan),
        effectId: state.effectId + 1,
      ),
    );
  }

  @override
  Future<void> close() {
    _homeRequest++;
    _cardsRequest++;
    _depositsRequest++;
    _loansRequest++;
    return super.close();
  }
}
