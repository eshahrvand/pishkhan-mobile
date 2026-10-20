import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'mobile_bank_guide_state.dart';
part 'mobile_bank_guide_cubit.freezed.dart';

class MobileBankGuideCubit extends Cubit<MobileBankGuideState> {
  MobileBankGuideCubit({
    MobileBankGuideState initialState = const MobileBankGuideState.initial(),
  }) : super(initialState);
  void selectPage(int page) {
    emit(state.copyWith(page: page));
  }
}
