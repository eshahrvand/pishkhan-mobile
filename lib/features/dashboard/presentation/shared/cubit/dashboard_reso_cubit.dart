import 'dart:async';

import 'package:characters/characters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_reso_state.dart';
part 'dashboard_reso_cubit.freezed.dart';

class DashboardResoCubit extends Cubit<DashboardResoState> {
  DashboardResoCubit({
    DashboardResoState initialState = const DashboardResoState.initial(),
  }) : super(initialState);

  Timer? _typingTimer;
  List<String> _phrases = const [];
  int _phraseIndex = 0, _position = 0, _holdTicks = 0;
  bool _erasing = false;

  void updatePrompt(String value) {
    emit(
      state.copyWith(
        prompt: value,
        hasInput: value.isNotEmpty,
        canSubmitPrompt: value.trim().isNotEmpty,
      ),
    );
    _syncTypingTimer();
  }

  String? submitPrompt() {
    final prompt = state.prompt.trim();
    if (isClosed || prompt.isEmpty) return null;
    emit(
      state.copyWith(
        submittedPrompt: prompt,
        submissionId: state.submissionId + 1,
      ),
    );
    return prompt;
  }

  void configurePhrases(List<String> phrases) {
    _phrases = phrases;
  }

  void updateForeground(bool value) {
    emit(state.copyWith(isForeground: value));
  }

  void updateMotion({required bool enabled, required bool hasFocus}) {
    emit(
      state.copyWith(
        isMotionEnabled: enabled && state.isForeground,
        hasFocus: hasFocus,
      ),
    );
    _syncTypingTimer();
  }

  // Resource management only; State updates remain explicit in each action.
  void _syncTypingTimer() {
    if (state.isMotionEnabled &&
        !state.hasFocus &&
        !state.hasInput &&
        _phrases.isNotEmpty) {
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
