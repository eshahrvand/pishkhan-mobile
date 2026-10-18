import 'package:equatable/equatable.dart';

import '../../../domain/entities/card_service_data.dart';

/// A real deposit selection or the explicit "all deposits" option.
class GiftBalanceDepositFilter extends Equatable {
  const GiftBalanceDepositFilter.all() : deposit = null;

  const GiftBalanceDepositFilter.forDeposit(CardServiceDeposit this.deposit);

  final CardServiceDeposit? deposit;

  @override
  List<Object?> get props => [deposit];

  @override
  bool get stringify => false;
}
