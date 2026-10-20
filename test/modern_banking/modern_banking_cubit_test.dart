import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/modern_banking/data/repositories/mock_modern_banking_repository.dart';
import 'package:pishkhan_mobile/features/modern_banking/domain/entities/mobile_bank.dart';
import 'package:pishkhan_mobile/features/modern_banking/domain/repositories/modern_banking_repository.dart';
import 'package:pishkhan_mobile/features/modern_banking/domain/usecases/mobile_bank.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/mobile_bank/cubit/mobile_bank_cubit.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/transfer_limits/cubit/transfer_limits_cubit.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/deactivation/cubit/mobile_bank_deactivation_cubit.dart';

class RetryIdentityRepository extends MockModernBankingRepository {
  final attempts = <MobileBankIdentityRequest>[];
  @override
  Future<Result<MobileBankRecord>> submitIdentity(
    MobileBankIdentityRequest request,
  ) {
    attempts.add(request);
    if (attempts.length == 1) {
      return Future.value(const Err(DataFailure('test.retry')));
    }
    return super.submitIdentity(request);
  }
}

Future<void> reachPreview(MobileBankCubit cubit) async {
  await cubit.fetchMobileBank();
  if (cubit.operation == MobileBankOperation.activation) {
    await cubit.continueFlow();
  }
  cubit.updateNationalCardSerial('3R12345678');
  await cubit.continueFlow();
  cubit.updateTermsAccepted(true);
  await cubit.continueFlow();
  await cubit.continueFlow();
}

void main() {
  setUp(() {
    getIt.registerSingleton<ModernBankingRepository>(
      MockModernBankingRepository(),
    );
  });
  tearDown(() => getIt.reset());

  test('constructor preserves supplied snapshot without initialization', () {
    const snapshot = MobileBankState.initial(nationalCardSerial: 'seed');
    final cubit = MobileBankCubit(initialState: snapshot);
    addTearDown(cubit.close);
    expect(cubit.state, same(snapshot));
    expect(cubit.state.catalogStatus, RequestStatus.initial);
  });

  test(
    'activation validates serial, calculates fees, submits and returns pending',
    () async {
      final cubit = MobileBankCubit();
      addTearDown(cubit.close);
      await cubit.fetchMobileBank();
      expect(cubit.state.step, MobileBankStep.introduction);
      expect(cubit.state.totalRial, 1600000);
      await cubit.continueFlow();
      cubit.updateNationalCardSerial('3333333333');
      expect(cubit.state.canContinue, isFalse);
      cubit.validateSerial();
      expect(cubit.state.isSerialError, isTrue);
      cubit.updateNationalCardSerial('3R12345678');
      expect(cubit.state.isSerialError, isFalse);
      expect(cubit.state.canContinue, isTrue);
      await cubit.continueFlow();
      expect(cubit.state.stepNumber, 2);
      expect(cubit.state.canContinue, isFalse);
      cubit.updateTermsAccepted(true);
      await cubit.continueFlow();
      expect(cubit.state.stepNumber, 3);
      await cubit.continueFlow();
      expect(cubit.state.step, MobileBankStep.preview);
      await cubit.submitIdentity();
      expect(cubit.state.step, MobileBankStep.receipt);
      expect(cubit.state.canContinue, isFalse);
      final returning = MobileBankCubit();
      addTearDown(returning.close);
      await returning.fetchMobileBank();
      expect(returning.state.step, MobileBankStep.pending);
      expect(
        returning.state.record!.trackingCode,
        cubit.state.record!.trackingCode,
      );
    },
  );

  test('same identity retry keeps its key', () async {
    final repository = RetryIdentityRepository();
    await getIt.unregister<ModernBankingRepository>();
    getIt.registerSingleton<ModernBankingRepository>(repository);
    final cubit = MobileBankCubit();
    addTearDown(cubit.close);
    await reachPreview(cubit);
    await cubit.submitIdentity();
    expect(cubit.state.submissionStatus, RequestStatus.failure);
    expect(cubit.state.nationalCardSerial, '3R12345678');
    await cubit.submitIdentity();
    expect(repository.attempts[0], repository.attempts[1]);
    expect(repository.attempts[1].isPrototypePreview, isTrue);
  });

  test('editing failed identity payload changes its request key', () async {
    final repository = RetryIdentityRepository();
    await getIt.unregister<ModernBankingRepository>();
    getIt.registerSingleton<ModernBankingRepository>(repository);
    final cubit = MobileBankCubit();
    addTearDown(cubit.close);
    await reachPreview(cubit);
    await cubit.submitIdentity();
    cubit.requestBack();
    cubit.requestBack();
    cubit.requestBack();
    cubit.updateNationalCardSerial('3R87654321');
    await cubit.continueFlow();
    await cubit.continueFlow();
    await cubit.continueFlow();
    await cubit.submitIdentity();
    expect(repository.attempts[1].nationalCardSerial, '3R87654321');
    expect(
      repository.attempts[1].idempotencyKey,
      isNot(repository.attempts[0].idempotencyKey),
    );
  });

  test('insufficient wallet cannot continue payment', () async {
    await getIt.unregister<ModernBankingRepository>();
    getIt.registerSingleton<ModernBankingRepository>(
      MockModernBankingRepository(walletBalanceRial: 1),
    );
    final cubit = MobileBankCubit();
    addTearDown(cubit.close);
    await cubit.fetchMobileBank();
    await cubit.continueFlow();
    cubit.updateNationalCardSerial('3R12345678');
    await cubit.continueFlow();
    cubit.updateTermsAccepted(true);
    expect(cubit.state.isWalletSufficient, isFalse);
    expect(cubit.state.canContinue, isFalse);
  });

  test(
    'approved activation exposes operations; recovery remains independent',
    () async {
      await getIt.unregister<ModernBankingRepository>();
      getIt.registerSingleton<ModernBankingRepository>(
        MockModernBankingRepository(
          activationStatus: MobileBankRequestStatus.approved,
        ),
      );
      final active = MobileBankCubit();
      final recovery = MobileBankCubit(
        operation: MobileBankOperation.passwordRecovery,
      );
      addTearDown(active.close);
      addTearDown(recovery.close);
      await active.fetchMobileBank();
      expect(active.state.step, MobileBankStep.active);
      await reachPreview(recovery);
      await recovery.submitIdentity();
      await active.fetchMobileBank();
      expect(active.state.step, MobileBankStep.active);
      final returning = MobileBankCubit(
        operation: MobileBankOperation.passwordRecovery,
      );
      addTearDown(returning.close);
      await returning.fetchMobileBank();
      expect(returning.state.step, MobileBankStep.pending);
    },
  );

  test(
    'limits validate independently and persist for the repository deposit',
    () async {
      final cubit = TransferLimitsCubit();
      addTearDown(cubit.close);
      await cubit.fetchLimits();
      cubit.openEditor();
      cubit.updateTermsAccepted(true);
      expect(cubit.state.canSubmit, isTrue);
      cubit.updateInternalAmount('2000000001');
      expect(cubit.state.isInternalError, isTrue);
      expect(cubit.state.canSubmit, isFalse);
      cubit.updateInternalAmount('15000000');
      expect(cubit.state.internalToman, 1500000);
      expect(cubit.state.canSubmit, isTrue);
      await cubit.submitLimits();
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.canSubmit, isFalse);
      final returning = TransferLimitsCubit();
      addTearDown(returning.close);
      await returning.fetchLimits();
      expect(returning.state.internalAmount, '15000000');
    },
  );

  test('deactivation submits server username and selected reason', () async {
    final cubit = MobileBankDeactivationCubit();
    addTearDown(cubit.close);
    await cubit.fetchMobileBank();
    cubit.updateTermsAccepted(true);
    expect(cubit.state.canSubmit, isFalse);
    cubit.selectReason(cubit.state.catalog!.reasons.single);
    expect(cubit.state.canSubmit, isTrue);
    await cubit.submitDeactivation();
    expect(cubit.state.submissionStatus, RequestStatus.success);
    expect(cubit.state.receipt!.trackingCode, isNotEmpty);
    expect(cubit.state.canSubmit, isFalse);
  });

  test('back follows steps and cancellation never authorizes exit', () async {
    final cubit = MobileBankCubit();
    addTearDown(cubit.close);
    await reachPreview(cubit);
    cubit.requestBack();
    expect(cubit.state.step, MobileBankStep.instruction);
    cubit.requestBack();
    expect(cubit.state.step, MobileBankStep.payment);
    cubit.requestBack();
    expect(cubit.state.step, MobileBankStep.serial);
    cubit.requestBack();
    cubit.requestBack();
    expect(cubit.state.navigation, FlowNavigation.confirmExit);
    cubit.applyExitConfirmation(null);
    expect(cubit.state.navigation, isNull);
    cubit.requestBack();
    cubit.applyExitConfirmation(true);
    expect(cubit.state.navigation, FlowNavigation.back);
  });

  test('limit validator rejects malformed, empty, zero, negative and above maximum', () {
    for (final value in ['', 'x', '-1', '0', '1.5', '2000000001']) {
      expect(
        TransferLimitValidator.isValid(value, 2000000000),
        isFalse,
        reason: value,
      );
    }
    expect(TransferLimitValidator.isValid('2000000000', 2000000000), isTrue);
  });

  for (final operation in MobileBankOperation.values) {
    test(
      '$operation assistant exit confirms before discarding input and retains Home destination',
      () async {
        final cubit = MobileBankCubit(operation: operation);
        addTearDown(cubit.close);
        await cubit.fetchMobileBank();
        cubit.requestHome();
        expect(cubit.state.navigation, FlowNavigation.home);
        if (operation == MobileBankOperation.activation) {
          await cubit.continueFlow();
        }
        cubit.updateNationalCardSerial('3R12345678');
        cubit.requestHome();
        expect(cubit.state.navigation, FlowNavigation.confirmExit);
        cubit.applyExitConfirmation(false);
        expect(cubit.state.navigation, isNull);
        expect(cubit.state.nationalCardSerial, '3R12345678');
        expect(cubit.state.step, MobileBankStep.serial);
        cubit.requestHome();
        cubit.applyExitConfirmation(true);
        expect(cubit.state.navigation, FlowNavigation.home);
        if (operation == MobileBankOperation.activation) {
          cubit.requestBack();
        }
        cubit.requestBack();
        expect(cubit.state.navigation, FlowNavigation.confirmExit);
        cubit.applyExitConfirmation(true);
        expect(cubit.state.navigation, FlowNavigation.back);
      },
    );
  }

  test(
    'completed identity exits Home without another discard confirmation',
    () async {
      final cubit = MobileBankCubit();
      addTearDown(cubit.close);
      await reachPreview(cubit);
      await cubit.submitIdentity();
      cubit.requestHome();
      expect(cubit.state.navigation, FlowNavigation.home);
    },
  );
}
