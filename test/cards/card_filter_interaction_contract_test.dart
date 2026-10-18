import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_features/cubit/card_features_cubit.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  test(
    'filter dismissal discards draft; Apply commits both fresh fields',
    () async {
      final cubit = CardFeaturesCubit();
      await cubit.fetchCards();
      cubit.requestFilter();
      expect(cubit.state.effect, isA<CardFilterRequested>());
      cubit.selectDraftCardStatus('blocked');
      cubit.selectDraftDepositNumber(cubit.state.depositNumbers.first);
      expect(cubit.state.draftFilter!.status!.name, 'blocked');
      expect(
        cubit.state.draftFilter!.deposit,
        cubit.state.depositNumbers.first,
      );
      cubit.applyFilterSheetResult(null);
      expect(cubit.state.draftFilter, isNull);
      expect(cubit.state.filter.isActive, isFalse);
      cubit.requestFilter();
      cubit.selectDraftCardStatus('active');
      cubit.selectDraftDepositNumber(cubit.state.depositNumbers.first);
      cubit.applyFilterSheetResult(true);
      expect(cubit.state.filter.status!.name, 'active');
      expect(cubit.state.filter.deposit, cubit.state.depositNumbers.first);
      expect(cubit.state.draftFilter, isNull);
      cubit.applyFilterSheetResult(null);
      expect(cubit.state.filter.isActive, isTrue);
      await cubit.close();
    },
  );
}
