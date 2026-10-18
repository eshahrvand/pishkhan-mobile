import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/features/cards/presentation/card_issuance/cubit/card_issuance_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/change_card_deposit/cubit/change_card_deposit_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/expired_gift_balance/cubit/expired_gift_balance_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/cubit/virtual_card_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/cubit/average_balance_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/cubit/financial_certificate_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/certificate_data.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  test(
    'issuance clean entry exits; edited selection survives cancelled exit',
    () async {
      final clean = CardIssuanceCubit();
      await clean.fetchIssuanceCatalog();
      clean.requestBack();
      expect(clean.state.navigation, FlowNavigation.back);
      await clean.close();
      final cubit = CardIssuanceCubit();
      await cubit.fetchIssuanceCatalog();
      cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      cubit.requestBack();
      expect(cubit.state.navigation, FlowNavigation.confirmExit);
      cubit.applyExitConfirmation(null);
      expect(cubit.state.navigation, isNull);
      expect(cubit.state.draft.deposit?.id, isNotNull);
      cubit.requestBack();
      cubit.applyExitConfirmation(true);
      expect(cubit.state.navigation, FlowNavigation.back);
      await cubit.close();
    },
  );

  test('deposit change confirms discarded card selection', () async {
    final cubit = ChangeCardDepositCubit();
    await cubit.fetchCatalog();
    cubit.selectCard(cubit.state.catalog!.cards.first);
    cubit.requestBack();
    expect(cubit.state.navigation, FlowNavigation.confirmExit);
    cubit.applyExitConfirmation(false);
    expect(cubit.state.card, isNotNull);
    cubit.requestBack();
    cubit.applyExitConfirmation(true);
    expect(cubit.state.navigation, FlowNavigation.back);
    await cubit.close();
  });

  test(
    'gift selection confirms exit and keeps selection on outside dismissal',
    () async {
      final cubit = ExpiredGiftBalanceCubit();
      await cubit.fetchCatalog();
      cubit.toggleCard(cubit.state.catalog!.gifts.first);
      cubit.requestBack();
      expect(cubit.state.navigation, FlowNavigation.confirmExit);
      cubit.applyExitConfirmation(null);
      expect(cubit.state.selectedCards, hasLength(1));
      cubit.requestBack();
      cubit.applyExitConfirmation(true);
      expect(cubit.state.navigation, FlowNavigation.back);
      await cubit.close();
    },
  );

  test(
    'virtual count is discardable even before a quote; clean entry exits',
    () async {
      final clean = VirtualCardCubit();
      await clean.fetchCatalog();
      clean.requestBack();
      expect(clean.state.navigation, FlowNavigation.back);
      await clean.close();
      final cubit = VirtualCardCubit();
      await cubit.fetchCatalog();
      await cubit.updateCount('1');
      cubit.requestBack();
      expect(cubit.state.navigation, FlowNavigation.confirmExit);
      cubit.applyExitConfirmation(false);
      expect(cubit.state.countText, '1');
      cubit.requestBack();
      cubit.applyExitConfirmation(true);
      expect(cubit.state.navigation, FlowNavigation.back);
      await cubit.close();
    },
  );

  test('average balance compares seeded deposit against entry, then confirms edits', () async {
    final cubit = AverageBalanceCubit();
    await cubit.fetchCatalog();
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    cubit.selectLanguage(CertificateLanguage.english);
    cubit.requestBack();
    expect(cubit.state.navigation, FlowNavigation.confirmExit);
    cubit.applyExitConfirmation(false);
    expect(cubit.state.language, CertificateLanguage.english);
    cubit.requestBack();
    cubit.applyExitConfirmation(true);
    expect(cubit.state.navigation, FlowNavigation.back);
    await cubit.close();
  });

  test('financial conditions confirm exit', () async {
    final cubit = FinancialCertificateCubit();
    await cubit.fetchCatalog();
    cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    cubit.requestBack();
    expect(cubit.state.navigation, FlowNavigation.confirmExit);
    cubit.applyExitConfirmation(true);
    expect(cubit.state.navigation, FlowNavigation.back);
    await cubit.close();
  });
}
