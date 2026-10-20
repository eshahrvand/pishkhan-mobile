import 'package:equatable/equatable.dart';

import 'listed_deposit.dart';

class ProxyCompany extends Equatable {
  const ProxyCompany({required this.id, required this.name});
  final String id;
  final String name;
  @override
  List<Object?> get props => [id, name];
}

class ProxySubject extends Equatable {
  ProxySubject({
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

class ProxyDepositCatalog extends Equatable {
  ProxyDepositCatalog({
    required Iterable<ProxyCompany> companies,
    required Iterable<ProxySubject> subjects,
    required Iterable<ListedDeposit> deposits,
    required this.token,
  }) : companies = List.unmodifiable(companies),
       subjects = List.unmodifiable(subjects),
       deposits = List.unmodifiable(deposits);
  final List<ProxyCompany> companies;
  final List<ProxySubject> subjects;
  final List<ListedDeposit> deposits;
  final String token;
  @override
  List<Object?> get props => [companies, subjects, deposits, token];
}

class ProxyDepositRequest extends Equatable {
  const ProxyDepositRequest({
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

class ProxyDepositReceipt extends Equatable {
  const ProxyDepositReceipt({required this.reference, required this.isMock});
  final String reference;
  final bool isMock;
  @override
  List<Object?> get props => [reference, isMock];
}
