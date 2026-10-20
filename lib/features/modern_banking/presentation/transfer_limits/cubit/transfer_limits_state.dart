part of 'transfer_limits_cubit.dart';

@Freezed(toStringOverride: false)
abstract class TransferLimitsState with _$TransferLimitsState {
  const factory TransferLimitsState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    MobileBankCatalog? catalog,
    @Default(false) bool isEditing,
    @Default('') String internalAmount,
    @Default('') String payaAmount,
    @Default('') String satnaAmount,
    @Default(0) int internalToman,
    @Default(0) int payaToman,
    @Default(0) int satnaToman,
    @Default(false) bool isInternalValid,
    @Default(false) bool isPayaValid,
    @Default(false) bool isSatnaValid,
    @Default(false) bool isInternalError,
    @Default(false) bool isPayaError,
    @Default(false) bool isSatnaError,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    Failure? catalogFailure,
    Failure? submissionFailure,
    FlowNavigation? navigation,
    @Default(0) int effectId,
  }) = _TransferLimitsState;
}
