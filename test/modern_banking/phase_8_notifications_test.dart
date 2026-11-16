import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/modern_banking/data/repositories/mock_modern_banking_repository.dart';
import 'package:pishkhan_mobile/features/modern_banking/domain/entities/mobile_bank.dart';
import 'package:pishkhan_mobile/features/modern_banking/domain/repositories/modern_banking_repository.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/mobile_bank/cubit/mobile_bank_cubit.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/mobile_bank/screens/mobile_bank_screen.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/transfer_limits/cubit/transfer_limits_cubit.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/transfer_limits/screens/mobile_bank_limits_screen.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/deactivation/cubit/mobile_bank_deactivation_cubit.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/deactivation/screens/mobile_bank_deactivation_screen.dart';
import 'package:pishkhan_mobile/features/modern_banking/presentation/shared/modern_bank_receipt.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_sheet.dart';

import '../deposits/certificate_test_support.dart';

class RetryingModernRepository extends MockModernBankingRepository {
  bool fail = true;
  final identities = <MobileBankIdentityRequest>[];
  final limits = <TransferLimitsRequest>[];
  final deactivations = <MobileBankDeactivationRequest>[];
  @override
  Future<Result<MobileBankRecord>> submitIdentity(
    MobileBankIdentityRequest request,
  ) {
    identities.add(request);
    return fail
        ? Future.value(const Err(DataFailure('timeout')))
        : super.submitIdentity(request);
  }

  @override
  Future<Result<TransferLimits>> submitTransferLimits(
    TransferLimitsRequest request,
  ) {
    limits.add(request);
    return fail
        ? Future.value(const Err(DataFailure('timeout')))
        : super.submitTransferLimits(request);
  }

  @override
  Future<Result<MobileBankRecord>> submitDeactivation(
    MobileBankDeactivationRequest request,
  ) {
    deactivations.add(request);
    return fail
        ? Future.value(const Err(DataFailure('timeout')))
        : super.submitDeactivation(request);
  }
}

class ThrowingCatalogRepository extends MockModernBankingRepository {
  @override
  Future<Result<MobileBankCatalog>> fetchCatalog() =>
      throw StateError('unexpected transport/mapper error');
}

Future<void> repeatedFailure(
  WidgetTester tester,
  Future<void> Function() submit,
) async {
  for (var attempt = 0; attempt < 2; attempt++) {
    final request = submit();
    await tester.pumpAndSettle();
    await request;
    expect(find.byType(AvpSnackBar), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(AvpSnackBar), findsNothing);
  }
}

void main() {
  setUpAll(loadCertificateFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  test(
    'unexpected modern catalog exceptions produce a terminal failure',
    () async {
      await getIt.unregister<ModernBankingRepository>();
      getIt.registerSingleton<ModernBankingRepository>(
        ThrowingCatalogRepository(),
      );
      final cubit = MobileBankCubit();
      addTearDown(cubit.close);
      await cubit.fetchMobileBank();
      expect(cubit.state.catalogStatus, RequestStatus.failure);
      expect(cubit.state.failure, const UnexpectedFailure());
    },
  );

  for (final operation in MobileBankOperation.values) {
    testWidgets(
      '$operation repeat errors and retained text do not block preview or success receipt',
      (tester) async {
        final repository = RetryingModernRepository();
        await getIt.unregister<ModernBankingRepository>();
        getIt.registerSingleton<ModernBankingRepository>(repository);
        await mountCertificate(tester, MobileBankScreen(operation: operation));
        final cubit = tester
            .element(find.byType(AppTopBar))
            .read<MobileBankCubit>();
        if (operation == MobileBankOperation.activation) {
          await cubit.continueFlow();
        }
        cubit.updateNationalCardSerial('3R12345678');
        await cubit.continueFlow();
        cubit.updateTermsAccepted(true);
        await cubit.continueFlow();
        await cubit.continueFlow();
        await repeatedFailure(tester, cubit.submitIdentity);
        cubit.requestRecordingAgain();
        await tester.pumpAndSettle();
        expect(cubit.state.step, MobileBankStep.instruction);
        expect(find.byType(AvpSnackBar), findsNothing);
        await cubit.continueFlow();
        repository.fail = false;
        final request = cubit.submitIdentity();
        await tester.pumpAndSettle();
        await request;
        expect(cubit.state.submissionStatus, RequestStatus.success);
        expect(cubit.state.step, MobileBankStep.receipt);
        expect(cubit.state.failure, isNotNull);
        expect(
          repository.identities.map((r) => r.idempotencyKey).toSet(),
          hasLength(1),
        );
        expect(find.byType(ModernBankReceipt), findsOneWidget);
        expect(find.byType(AvpSnackBar), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'limits retry identity survives errors and exit cancellation; success uses its own copy',
    (tester) async {
      final repository = RetryingModernRepository();
      await getIt.unregister<ModernBankingRepository>();
      getIt.registerSingleton<ModernBankingRepository>(repository);
      await mountCertificate(tester, const MobileBankLimitsScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<TransferLimitsCubit>();
      cubit.openEditor();
      cubit.updateTermsAccepted(true);
      await repeatedFailure(tester, cubit.submitLimits);
      cubit.requestBack();
      await tester.pumpAndSettle();
      expect(find.byType(FlowExitSheet), findsOneWidget);
      expect(find.byType(AvpSnackBar), findsNothing);
      await tester.tap(find.text(S.current.passwordStay));
      await tester.pumpAndSettle();
      repository.fail = false;
      final request = cubit.submitLimits();
      await tester.pumpAndSettle();
      await request;
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(repository.limits.toSet(), hasLength(1));
      expect(find.text(S.current.modernLimitsSaved), findsOneWidget);
      expect(find.byType(AvpSnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'deactivation errors repeat; navigation and successful receipt ignore retained failure text',
    (tester) async {
      final repository = RetryingModernRepository();
      await getIt.unregister<ModernBankingRepository>();
      getIt.registerSingleton<ModernBankingRepository>(repository);
      await mountCertificate(tester, const MobileBankDeactivationScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<MobileBankDeactivationCubit>();
      cubit.selectReason(cubit.state.catalog!.reasons.first);
      cubit.updateTermsAccepted(true);
      await repeatedFailure(tester, cubit.submitDeactivation);
      cubit.requestBack();
      await tester.pumpAndSettle();
      expect(find.byType(FlowExitSheet), findsOneWidget);
      expect(find.byType(AvpSnackBar), findsNothing);
      await tester.tap(find.text(S.current.passwordStay));
      await tester.pumpAndSettle();
      repository.fail = false;
      final request = cubit.submitDeactivation();
      await tester.pumpAndSettle();
      await request;
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(repository.deactivations.toSet(), hasLength(1));
      expect(find.byType(ModernBankReceipt), findsOneWidget);
      expect(find.byType(AvpSnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
