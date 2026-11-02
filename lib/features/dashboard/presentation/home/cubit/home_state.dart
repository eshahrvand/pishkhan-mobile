part of 'home_cubit.dart';

@Freezed(toStringOverride: false)
abstract class HomeState with _$HomeState {
  const factory HomeState.initial({
    @Default(AppPrimaryTab.dashboard) AppPrimaryTab selectedTab,
    @Default('') String servicePickerQuery,
    @Default(<DashboardCategory>{})
    Set<DashboardCategory> servicePickerCollapsedCategories,
    @Default(<DashboardServiceGroup>[])
    List<DashboardServiceGroup> servicePickerGroups,
    @Default(false) bool isServicePickerSearching,
    DashboardService? pickedService,
    @Default(true) bool enableAnimations,
    @Default('') String drawerQuery,
    @Default(<DashboardDrawerGroup>[]) List<DashboardDrawerGroup> drawerGroups,
    DashboardDrawerSection? expandedDrawerSection,
    @Default(DashboardDrawerSection.home)
    DashboardDrawerSection selectedDrawerSection,
    DashboardDrawerSelection? drawerSelection,
    @Default('') String prompt,
    String? submittedPrompt,
    @Default(false) bool canSubmitPrompt,
    @Default(false) bool isInputPresent,
    @Default(false) bool isInputFocused,
    @Default(false) bool isMotionAllowed,
    @Default(false) bool isMotionEnabled,
    @Default(false) bool isHintTyping,
    @Default(true) bool isForeground,
    @Default('') String typedHint,
    @Default(false) bool isEditingFavorites,
    @Default(<DashboardService>[]) List<DashboardService> favoriteServices,
    @Default(<DashboardService>[]) List<DashboardService> fixedServices,
    @Default(true) bool canAddFavorite,
    @Default(false) bool isFavoritesLimitReached,
    @Default(RequestStatus.initial) RequestStatus homeStatus,
    DashboardHomeData? homeData,
    Failure? failure,
    String? message,
    @Default(RequestStatus.initial) RequestStatus cardsStatus,
    @Default(<BankCard>[]) List<BankCard> visibleCards,
    @Default(0) int selectedCardIndex,
    BankCard? selectedCard,
    @Default(<CardAction>[]) List<CardAction> cardActions,
    @Default(<CardAction>[]) List<CardAction> pinActions,
    @Default(<CardAction>[]) List<CardAction> cardQuickActions,
    @Default({}) Map<String, bool> cardVisibility,

    List<NotificationMessage>? messages,
    HomeEffect? effect,

    @Default(RequestStatus.initial) RequestStatus depositsStatus,
    @Default(<BankDeposit>[]) List<BankDeposit> visibleDeposits,
    @Default(0) int selectedDepositIndex,
    BankDeposit? selectedDeposit,

    @Default(RequestStatus.initial) RequestStatus loansStatus,
    @Default(<BankLoan>[]) List<BankLoan> visibleLoans,
    @Default(0) int selectedLoanIndex,
    BankLoan? selectedLoan,

    @Default(<DepositAction>[]) List<DepositAction> depositActions,
    @Default(<DepositAction>[]) List<DepositAction> depositChequeActions,
    @Default(<DepositAction>[]) List<DepositAction> depositQuickActions,
    @Default(<LoanAction>[]) List<LoanAction> loanActions,
    @Default(<LoanAction>[]) List<LoanAction> loanQuickActions,
  }) = _HomeState;
}
