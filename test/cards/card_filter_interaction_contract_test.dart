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
      final request = cubit.state.effectId;
      cubit.requestFilter();
      expect(cubit.state.effectId, request);
      cubit.updateDraftCardStatus('blocked');
      cubit.updateDraftDepositNumber(cubit.state.deposits.first);
      expect(cubit.state.draftFilter!.status!.name, 'blocked');
      expect(cubit.state.draftFilter!.deposit, cubit.state.deposits.first);
      cubit.handleFilterSheetResult(null);
      expect(cubit.state.draftFilter, isNull);
      expect(cubit.state.filter.isActive, isFalse);
      cubit.requestFilter();
      cubit.updateDraftCardStatus('active');
      cubit.updateDraftDepositNumber(cubit.state.deposits.first);
      cubit.handleFilterSheetResult(true);
      expect(cubit.state.filter.status!.name, 'active');
      expect(cubit.state.filter.deposit, cubit.state.deposits.first);
      expect(cubit.state.draftFilter, isNull);
      cubit.handleFilterSheetResult(null);
      expect(cubit.state.filter.isActive, isTrue);
      await cubit.close();
    },
  );
}
