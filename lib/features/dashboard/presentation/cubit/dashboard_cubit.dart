import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardState {
  DashboardState({Iterable<String> favorites = const [], List<String>? draft})
    : favorites = List.unmodifiable(favorites),
      draft = draft == null ? null : List.unmodifiable(draft);

  final List<String> favorites;
  final List<String>? draft;
  bool get isEditing => draft != null;
  List<String> get visibleFavorites => draft ?? favorites;
}

/// Keeps customization transactional: cancel discards the draft.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({Iterable<String> favorites = const []})
    : super(DashboardState(favorites: favorites.toSet().take(4)));

  void edit() =>
      emit(DashboardState(favorites: state.favorites, draft: state.favorites));

  void add(String id) {
    final draft = state.draft;
    if (draft == null || draft.length >= 4 || draft.contains(id)) return;
    emit(DashboardState(favorites: state.favorites, draft: [...draft, id]));
  }

  void remove(String id) {
    if (!state.isEditing) return;
    emit(
      DashboardState(
        favorites: state.favorites,
        draft: state.draft!.where((item) => item != id).toList(),
      ),
    );
  }

  void confirm() => emit(DashboardState(favorites: state.visibleFavorites));
  void cancel() => emit(DashboardState(favorites: state.favorites));
  void reset() => emit(DashboardState());
}
