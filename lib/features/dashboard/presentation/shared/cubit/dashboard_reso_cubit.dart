import 'dart:async';

import 'package:characters/characters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_reso_state.dart';
part 'dashboard_reso_cubit.freezed.dart';

class DashboardResoCubit extends Cubit<DashboardResoState> {
  DashboardResoCubit() : super(const DashboardResoState.initial());

  Timer? _typingTimer;
  List<String> _phrases = const [];
  int _phraseIndex = 0, _position = 0, _holdTicks = 0;
  bool _erasing = false;

  void configurePhrases(List<String> phrases) {
    _phrases = phrases;
  }

  void updateForeground(bool value) {
    emit(state.copyWith(isForeground: value));
  }

  void updateMotion({
    required bool enabled,
    required bool hasFocus,
    required bool hasInput,
  }) {
    emit(
      state.copyWith(
        isMotionEnabled: enabled,
        hasFocus: hasFocus,
        hasInput: hasInput,
      ),
    );
    if (enabled && !hasFocus && !hasInput && _phrases.isNotEmpty) {
      _typingTimer ??= Timer.periodic(
        const Duration(milliseconds: 90),
        (_) => typeNext(),
      );
    } else {
      _typingTimer?.cancel();
      _typingTimer = null;
    }
  }

  void typeNext() {
    if (isClosed || _phrases.isEmpty) return;
    if (_holdTicks > 0) {
      _holdTicks--;
      return;
    }
    final phrase = _phrases[_phraseIndex];
    final length = phrase.characters.length;
    if (_erasing) {
      _position--;
      if (_position <= 0) {
        _position = 0;
        _erasing = false;
        _phraseIndex = (_phraseIndex + 1) % _phrases.length;
        _holdTicks = 5;
      }
    } else {
      _position++;
      if (_position >= length) {
        _position = length;
        _erasing = true;
        _holdTicks = 24;
      }
    }
    emit(
      state.copyWith(typedHint: phrase.characters.take(_position).toString()),
    );
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    return super.close();
  }
}
