import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'mobile_bank_guide_effect.dart';
export 'mobile_bank_guide_effect.dart';
part 'mobile_bank_guide_state.dart';
part 'mobile_bank_guide_cubit.freezed.dart';

class MobileBankGuideCubit extends Cubit<MobileBankGuideState> {
  MobileBankGuideCubit({
    MobileBankGuideState initialState = const MobileBankGuideState.initial(),
  }) : super(initialState);
  void selectPage(int page) {
    emit(state.copyWith(page: page));
  }

  void requestPage(int page) {
    emit(state.copyWith(effect: MobileBankGuidePageRequested(page)));
  }

  void requestBack() {
    emit(state.copyWith(effect: const MobileBankGuideBackRequested()));
  }

  void requestHome() {
    emit(state.copyWith(effect: const MobileBankGuideHomeRequested()));
  }

  void consumeGuideInteraction() {
    emit(state.copyWith(effect: null));
  }
}
