part of 'proxy_deposit_cubit.dart';

enum ProxyDepositEffect { confirmExit, back, home, assistant, termsUnavailable }

@Freezed(toStringOverride: false)
abstract class ProxyDepositState with _$ProxyDepositState {
  const factory ProxyDepositState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    ProxyDepositCatalog? catalog,
    @Default(<ProxySubject>[]) List<ProxySubject> subjects,
    @Default(<ListedDeposit>[]) List<ListedDeposit> deposits,
    ProxyCompany? company,
    ProxySubject? subject,
    ListedDeposit? deposit,
    num? amountToman,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    @Default(false) bool isEditable,
    @Default(false) bool hasChanges,
    @Default(false) bool isExitToAssistant,
    Failure? catalogFailure,
    Failure? submissionFailure,
    String? idempotencyKey,
    ProxyDepositReceipt? receipt,
    ProxyDepositEffect? effect,
    @Default(0) int effectId,
  }) = _ProxyDepositState;
}
