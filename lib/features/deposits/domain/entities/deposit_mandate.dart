import 'package:equatable/equatable.dart';

import 'listed_deposit.dart';

class DepositMandateCompany extends Equatable {
  const DepositMandateCompany({required this.id, required this.name});
  final String id;
  final String name;
  @override
  List<Object?> get props => [id, name];
}

class DepositMandateSubject extends Equatable {
  DepositMandateSubject({
    required this.id,
    required this.companyId,
    required this.title,
    required this.brokerName,
    required this.amountRial,
    required Iterable<String> depositIds,
  }) : depositIds = List.unmodifiable(depositIds);
  final String id;
  final String companyId;
  final String title;
  final String brokerName;
  final int amountRial;
  final List<String> depositIds;
  @override
  List<Object?> get props => [
    id,
    companyId,
    title,
    brokerName,
    amountRial,
    depositIds,
  ];
}

class DepositMandateCatalog extends Equatable {
  DepositMandateCatalog({
    required Iterable<DepositMandateCompany> companies,
    required Iterable<DepositMandateSubject> subjects,
    required Iterable<ListedDeposit> deposits,
    required this.token,
  }) : companies = List.unmodifiable(companies),
       subjects = List.unmodifiable(subjects),
       deposits = List.unmodifiable(deposits);
  final List<DepositMandateCompany> companies;
  final List<DepositMandateSubject> subjects;
  final List<ListedDeposit> deposits;
  final String token;
  @override
  List<Object?> get props => [companies, subjects, deposits, token];
}

class DepositMandateRequest extends Equatable {
  const DepositMandateRequest({
    required this.companyId,
    required this.subjectId,
    required this.depositId,
    required this.catalogToken,
    required this.idempotencyKey,
  });
  final String companyId;
  final String subjectId;
  final String depositId;
  final String catalogToken;
  final String idempotencyKey;
  @override
  List<Object?> get props => [
    companyId,
    subjectId,
    depositId,
    catalogToken,
    idempotencyKey,
  ];
}

class DepositMandateReceipt extends Equatable {
  const DepositMandateReceipt({required this.reference, required this.isMock});
  final String reference;
  final bool isMock;
  @override
  List<Object?> get props => [reference, isMock];
}
