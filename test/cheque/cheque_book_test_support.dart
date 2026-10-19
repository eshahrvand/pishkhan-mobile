import 'dart:async';

import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/cheque/domain/entities/cheque_book.dart';
import 'package:pishkhan_mobile/features/cheque/domain/repositories/cheque_book_repository.dart';

List<ChequeBookResidence> bookResidences(List<bool> registered) => [
  for (var i = 0; i < registered.length; i++)
    ChequeBookResidence(
      address: DeliveryAddress(
        id: 'address-$i',
        title: i == 0 ? 'خانه' : 'خانه دوم',
        detail: i == 0
            ? 'تهران - خیابان شریعتی - روبروی خیابان یخچال - بن بست شریف - پلاک ۴ - واحد ۱'
            : 'تهران - تجریش - ابتدای شریعتی - کوچه پروین - پلاک ۲۰ - واحد ۳',
        postalCode: '1944692133',
      ),
      isRegistered: registered[i],
    ),
];

class TestChequeBookRepository implements ChequeBookRepository {
  TestChequeBookRepository({
    this.applicant = ChequeBookApplicant.individual,
    List<bool> registered = const [true],
  }) : residences = bookResidences(registered);
  final ChequeBookApplicant applicant;
  List<ChequeBookResidence> residences;
  final requests = <ChequeBookRequest>[];
  final drafts = <ChequeBookDraft>[];
  Completer<Result<ChequeBookResidency>>? pendingResidency;
  Completer<Result<ChequeBookQuote>>? pendingQuote;
  Completer<Result<ChequeBookReceipt>>? pendingSubmission;
  bool throwsCatalog = false;
  bool failsQuote = false;
  bool failsSubmission = false;
  bool failsDeletion = false;
  int walletBalanceRial = 2000000;

  @override
  Future<Result<ChequeBookCatalog>> fetchCatalog() async {
    if (throwsCatalog) throw StateError('catalog unavailable');
    return Success(
      ChequeBookCatalog(
        applicant: applicant,
        deposits: [
          ChequeBookDeposit(
            id: 'deposit-1',
            number: '10.1234567.1',
            openedAt: DateTime.utc(2023, 9, 3),
            leafCounts: [10, 25, 50],
          ),
          ChequeBookDeposit(
            id: 'deposit-2',
            number: '10.1234567.2',
            openedAt: DateTime.utc(2026, 9, 3),
            leafCounts: [10, 25],
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<ChequeBookResidency>> checkResidency(String depositId) =>
      pendingResidency?.future ??
      Future.value(
        Success(
          ChequeBookResidency(
            token: 'residency-$depositId',
            residences: residences,
          ),
        ),
      );
  @override
  Future<Result<ChequeBookResidency>> deleteResidence(
    String depositId,
    DeliveryAddress address,
  ) async {
    if (failsDeletion) return const Err(DataFailure('address unavailable'));
    residences = residences
        .where((residence) => residence.address.id != address.id)
        .toList();
    return Success(
      ChequeBookResidency(
        token: 'updated-residency-$depositId',
        residences: residences,
      ),
    );
  }

  @override
  Future<Result<DeliveryAddress>> saveDeliveryAddress(
    DeliveryAddress address,
  ) async => Success(
    DeliveryAddress(
      id: 'saved-address',
      title: address.title,
      detail: address.detail,
      postalCode: address.postalCode,
    ),
  );
  @override
  Future<Result<ChequeBookQuote>> fetchQuote(ChequeBookDraft draft) async {
    drafts.add(draft);
    if (failsQuote) return const Err(DataFailure('quote unavailable'));
    return pendingQuote?.future ??
        Success(
          ChequeBookQuote(
            token: 'quote-${drafts.length}',
            issueFeeRial: 300000,
            deliveryFeeRial: 1000000,
            walletBalanceRial: walletBalanceRial,
            expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
          ),
        );
  }

  @override
  Future<Result<ChequeBookReceipt>> submitIssuance(
    ChequeBookRequest request,
  ) async {
    requests.add(request);
    if (failsSubmission) return const Err(DataFailure('timeout'));
    return pendingSubmission?.future ??
        const Success(ChequeBookReceipt(reference: 'DEMO-123', isMock: true));
  }
}
