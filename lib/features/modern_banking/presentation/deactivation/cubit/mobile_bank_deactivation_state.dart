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
    Failure? failure,
    String? message,

    FlowNavigation? navigation,
  }) = _MobileBankDeactivationState;
}
