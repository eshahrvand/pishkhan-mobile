import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/validators/jalali_date_parser.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_agent_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/listed_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/agent_request.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/agent_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/cubit/agent_cubit.dart';

class RecordingAgentRepository implements AgentRepository {
  final requests = <AgentRequest>[];
  Future<Result<AgentReceipt>> Function()? response;

  @override
  Future<Result<AgentReceipt>> submit(AgentRequest request) {
    requests.add(request);
    return response?.call() ?? Future.value(const Err(DataFailure('timeout')));
  }
}

void fillAgent(AgentCubit cubit, {String date = '۱۴۱۰/۰۶/۳۰'}) {
  cubit.selectDeposit(cubit.state.deposits.first);
  cubit.selectOperation(AgentOperation.chequeBook);
  cubit.updateNationalId('۱۲۳۴۵۶۷۸۹۱');
  cubit.updateValidity(date);
}

void main() {
  late RecordingAgentRepository repository;
  late AgentCubit cubit;

  setUp(() {
    repository = RecordingAgentRepository();
    getIt.registerSingleton<DepositsRepository>(MockDepositsRepository());
    getIt.registerSingleton<AgentRepository>(repository);
    cubit = AgentCubit();
  });
  tearDown(() async {
    await cubit.close();
    await getIt.reset();
  });

  test('valid fields enable preliminary save; it only appends immutable local drafts', () async {
    await cubit.fetchDeposits();
    cubit.selectDeposit(cubit.state.deposits.first);
    cubit.selectOperation(AgentOperation.chequeBook);
    cubit.updateValidity('۱۴۱۰/۰۶/۳۰');
    cubit.updateNationalId('۰۰۸۱۲۳۴۵۶۷');
    expect(cubit.state.isNationalIdError, isTrue);
    expect(cubit.state.canSaveDraft, isFalse);
    cubit.updateNationalId('۱۲۳۴۵۶۷۸۹۱');
    expect(cubit.state.isNationalIdError, isFalse);
    expect(cubit.state.canSaveDraft, isTrue);
    cubit.saveDraft();
    expect(cubit.state.agents.single.nationalId, '1234567891');
    expect(cubit.state.agents.single.validUntil.isUtc, isTrue);
    expect(() => cubit.state.agents.clear(), throwsUnsupportedError);
    expect(repository.requests, isEmpty);
    expect(cubit.state.canSubmit, isFalse);
    cubit.updateTermsAcceptance(true);
    expect(cubit.state.canSubmit, isTrue);
  });

  test(
    'date errors clear on edit and aggregate eligibility follows each field',
    () async {
      await cubit.fetchDeposits();
      fillAgent(cubit, date: '۱۴۱۰/۱۳/۰۱');
      expect(cubit.state.isValidityError, isTrue);
      expect(cubit.state.canSaveDraft, isFalse);
      cubit.updateValidity('۱۳۸۰/۰۱/۰۱');
      expect(cubit.state.isValidityError, isTrue);
      cubit.updateValidity('۱۴۱۰/۰۱/۰۱');
      expect(cubit.state.isValidityError, isFalse);
      expect(cubit.state.canSaveDraft, isTrue);
      cubit.updateNationalId('');
      expect(cubit.state.canSaveDraft, isFalse);
      expect(cubit.state.isNationalIdError, isFalse);
    },
  );

  test('opening or abandoning the next form never adds an agent; remove returns to initial form', () async {
    await cubit.fetchDeposits();
    fillAgent(cubit);
    cubit.saveDraft();
    final first = cubit.state.agents.single;
    cubit.requestNextAgent();
    expect(cubit.state.canSaveDraft, isFalse);
    fillAgent(cubit);
    expect(cubit.state.agents, [first]);
    cubit.requestNextAgent();
    expect(cubit.state.nationalId, isEmpty);
    fillAgent(cubit, date: '۱۴۱۱/۰۱/۰۱');
    cubit.saveDraft();
    expect(cubit.state.agents.length, 2);
    cubit.removeAgent(first);
    expect(
      cubit.state.agents.single.validUntil,
      JalaliDateParser.parse('1411/01/01'),
    );
    cubit.removeAgent(cubit.state.agents.single);
    expect(cubit.state.agents, isEmpty);
    expect(cubit.state.canSaveDraft, isFalse);
    expect(cubit.state.canSubmit, isFalse);
  });

  test('retry uses the same payload/key; uncommitted edits do not change request identity', () async {
    await cubit.fetchDeposits();
    fillAgent(cubit);
    cubit.saveDraft();
    cubit.updateTermsAcceptance(true);
    await cubit.submitAgents();
    expect(cubit.state.submissionStatus, RequestStatus.failure);
    expect(cubit.state.isEditable, isTrue);
    cubit.requestNextAgent();
    fillAgent(cubit, date: '۱۴۱۱/۰۱/۰۱');
    await cubit.submitAgents();
    expect(repository.requests[1], repository.requests[0]);
    cubit.saveDraft();
    await cubit.submitAgents();
    expect(
      repository.requests[2].idempotencyKey,
      isNot(repository.requests[0].idempotencyKey),
    );
    expect(repository.requests[2].agents.length, 2);
  });

  test('submit takes a snapshot, locks edits, preserves navigation and leaves success non-resubmittable', () async {
    await cubit.fetchDeposits();
    fillAgent(cubit);
    cubit.saveDraft();
    cubit.updateTermsAcceptance(true);
    final completer = Completer<Result<AgentReceipt>>();
    repository.response = () => completer.future;
    final submission = cubit.submitAgents();
    expect(cubit.state.isEditable, isFalse);
    cubit.requestHome();
    expect(cubit.state.effect, AgentEffect.confirmExit);
    cubit.applyExitConfirmation(false);
    expect(cubit.state.effect, isNull);
    completer.complete(
      const Success(AgentReceipt(reference: 'test', isMock: true)),
    );
    await submission;
    expect(cubit.state.submissionStatus, RequestStatus.success);
    expect(cubit.state.canSubmit, isFalse);
    cubit.applyReceiptDismissal();
    expect(cubit.state.effect, AgentEffect.home);
    expect(
      () => repository.requests.single.agents.clear(),
      throwsUnsupportedError,
    );
  });

  test('unexpected repository exceptions become retryable failures', () async {
    await cubit.fetchDeposits();
    fillAgent(cubit);
    cubit.saveDraft();
    cubit.updateTermsAcceptance(true);
    repository.response = () => Future.error(StateError('transport'));
    await cubit.submitAgents();
    expect(cubit.state.submissionFailure, const UnexpectedFailure());
    expect(cubit.state.canSubmit, isTrue);
  });

  test('mock repository deduplicates a key and rejects a changed payload with the same key', () async {
    await cubit.fetchDeposits();
    fillAgent(cubit);
    cubit.saveDraft();
    final mock = MockAgentRepository();
    final request = AgentRequest(
      agents: cubit.state.agents,
      idempotencyKey: 'same',
    );
    final first = await mock.submit(request);
    final retry = await mock.submit(request);
    expect(
      (retry as Success<AgentReceipt>).data,
      (first as Success<AgentReceipt>).data,
    );
    final changed = AgentRequest(agents: [], idempotencyKey: 'same');
    expect(await mock.submit(changed), isA<Err<AgentReceipt>>());
  });

  test('Jalali parser rejects overflow and round-trips the package calendar including leap days', () {
    expect(JalaliDateParser.parse('1400/12/30'), isNull);
    expect(JalaliDateParser.parse('1405/07/31'), isNull);
    expect(JalaliDateParser.parse('1410/1/1'), isNull);
    expect(JalaliDateParser.parse('1403/12/30'), DateTime.utc(2025, 3, 20));
    for (
      var day = DateTime.utc(2020);
      day.isBefore(DateTime.utc(2040));
      day = day.add(const Duration(days: 17))
    ) {
      final text = JalaliDateFormatter.format(day, usePersianDigits: false);
      expect(JalaliDateParser.parse(text), day, reason: text);
    }
  });

  test(
    'catalog resolves entry deposit and excludes closed/blocked deposits',
    () async {
      await cubit.close();
      await getIt.unregister<DepositsRepository>();
      getIt.registerSingleton<DepositsRepository>(
        MockDepositsRepository(
          deposits: [
            ListedDeposit(id: 'open', number: '001'),
            ListedDeposit(
              id: 'blocked',
              number: '002',
              status: DepositStatus.blocked,
            ),
          ],
        ),
      );
      cubit = AgentCubit(initialDepositNumber: '001');
      await cubit.fetchDeposits();
      expect(cubit.state.deposit!.id, 'open');
      expect(cubit.state.deposits.length, 1);
      expect(cubit.state.hasChanges, isFalse);
    },
  );
}
