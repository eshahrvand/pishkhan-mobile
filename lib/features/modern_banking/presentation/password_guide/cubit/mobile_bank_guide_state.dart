part of 'mobile_bank_guide_cubit.dart';

@freezed
abstract class MobileBankGuideState with _$MobileBankGuideState {
  const factory MobileBankGuideState.initial({@Default(0) int page}) =
      _MobileBankGuideState;
}
