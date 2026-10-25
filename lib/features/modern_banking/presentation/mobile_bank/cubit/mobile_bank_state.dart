part of 'mobile_bank_cubit.dart';

enum MobileBankStep {
  introduction,
  serial,
  payment,
  instruction,
  preview,
  receipt,
  pending,
  active,
  recoveryApproved,
}

@Freezed(toStringOverride: false)
abstract class MobileBankState with _$MobileBankState {
  const factory MobileBankState.initial({
    @Default(RequestStatus.initial) RequestStatus catalogStatus,
    @Default(RequestStatus.initial) RequestStatus submissionStatus,
    @Default(MobileBankStep.introduction) MobileBankStep step,
    @Default(1) int stepNumber,
    @Default(.3) double progress,
    MobileBankCatalog? catalog,
    MobileBankRecord? record,
    @Default('') String nationalCardSerial,
    @Default(false) bool isSerialValid,
    @Default(false) bool isSerialError,
    @Default(false) bool termsAccepted,
    @Default(true) bool isInvoiceExpanded,
    @Default(false) bool isWalletSufficient,
    @Default(0) int totalRial,
    @Default(false) bool canContinue,
    Failure? failure,
    String? message,

    FlowNavigation? navigation,
    @Default(false) bool isExitToHome,
    MobileBankDestination? destination,
  }) = _MobileBankState;
}
