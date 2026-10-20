part of 'mobile_bank_deactivation_cubit.dart';

@Freezed(toStringOverride: false)
abstract class MobileBankDeactivationState with _$MobileBankDeactivationState {
  const factory MobileBankDeactivationState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    MobileBankCatalog? catalog,
    DeactivationReason? reason,
    MobileBankRecord? receipt,
    @Default(false) bool termsAccepted,
    @Default(false) bool canSubmit,
    Failure? catalogFailure,
    Failure? submissionFailure,
    FlowNavigation? navigation,
    @Default(0) int effectId,
  }) = _MobileBankDeactivationState;
}
