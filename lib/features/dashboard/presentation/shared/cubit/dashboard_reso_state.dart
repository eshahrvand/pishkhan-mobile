part of 'dashboard_reso_cubit.dart';

@freezed
abstract class DashboardResoState with _$DashboardResoState {
  const factory DashboardResoState.initial({
    @Default('') String prompt,
    @Default('') String submittedPrompt,
    @Default(0) int submissionId,
    @Default(false) bool canSubmitPrompt,
    @Default('') String typedHint,
    @Default(false) bool isMotionEnabled,
    @Default(false) bool hasFocus,
    @Default(false) bool hasInput,
    @Default(true) bool isForeground,
  }) = _DashboardResoState;
}
