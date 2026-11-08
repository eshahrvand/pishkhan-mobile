import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/core/validators/jalali_date_parser.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';

import '../../../domain/entities/wallet.dart';
import '../../../domain/usecases/wallet_usecase.dart';
import '../../../domain/wallet_rules.dart';

part 'transactions_state.dart';
part 'transactions_cubit.freezed.dart';

class WalletTransactionsCubit extends Cubit<WalletTransactionsState> {
  WalletTransactionsCubit({
    WalletTransactionsState initialState =
        const WalletTransactionsState.initial(),
  }) : super(initialState);
  final fetchWalletTransactionsUseCase =
      getIt<FetchWalletTransactionsUseCase>();




  Future<void> fetchTransactions() async {
    emit(state.copyWith(transactionsStatus: RequestStatus.loading));
    final result = await fetchWalletTransactionsUseCase(state.filter);
    switch (result) {
      case Err(:final failure):
        emit(
          state.copyWith(
            transactionsStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            transactionsStatus: RequestStatus.success,
            transactions: data,
          ),
        );
    }
  }

  Future<void> requestTypes() async {
    if (state.filter.types.isEmpty) {
      openFilter(WalletFilterKind.types);
    } else {
      await clearTypes();
    }
  }

  Future<void> requestDate() async {
    if (state.filter.period == null) {
      openFilter(WalletFilterKind.date);
    } else {
      await clearDate();
    }
  }

  Future<void> requestAmount() async {
    if (state.filter.minRial == null && state.filter.maxRial == null) {
      openFilter(WalletFilterKind.amount);
    } else {
      await clearAmount();
    }
  }

  void applyFilterDismissal(bool? applied) {
    if (applied != true) cancelFilter();
  }

  void openFromDatePicker() {
    final date = _dateOnly(state.draftFrom ?? DateTime.now());
    emit(
      state.copyWith(
        datePickerTarget: WalletDateTarget.from,
        datePickerInput: JalaliDateFormatter.format(
          date,
          usePersianDigits: false,
        ),
        datePickerValue: date,
        isDatePickerError: false,
        canConfirmDate: true,
      ),
    );
  }

  void openToDatePicker() {
    final date = _dateOnly(state.draftTo ?? DateTime.now());
    emit(
      state.copyWith(
        datePickerTarget: WalletDateTarget.to,
        datePickerInput: JalaliDateFormatter.format(
          date,
          usePersianDigits: false,
        ),
        datePickerValue: date,
        isDatePickerError: false,
        canConfirmDate: true,
      ),
    );
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  void updateDatePickerInput(String input) {
    final value = JalaliDateParser.parse(WalletRules.normalize(input));
    emit(
      state.copyWith(
        datePickerInput: input,
        datePickerValue: value == null ? null : _dateOnly(value),
        isDatePickerError: input.isNotEmpty && value == null,
        canConfirmDate: value != null,
      ),
    );
  }

  void applyDatePickerResult(String? input) {
    if (input != null) {
      switch (state.datePickerTarget!) {
        case WalletDateTarget.from:
          selectFromDate(state.datePickerValue!);
        case WalletDateTarget.to:
          selectToDate(state.datePickerValue!);
      }
    }
    emit(state.copyWith(datePickerTarget: null));
  }

  void openFilter(WalletFilterKind kind) {
    emit(
      state.copyWith(
        filterKind: kind,
        draftTypes: state.filter.types,
        draftPeriod: state.filter.period,
        draftFrom: state.filter.from,
        draftTo: state.filter.to,
        draftMin: state.filter.minRial?.toString() ?? '',
        draftMax: state.filter.maxRial?.toString() ?? '',
        isAmountRangeError: false,
        isDateRangeError: false,
        draftMinRial: state.filter.minRial,
        draftMaxRial: state.filter.maxRial,
        draftMinToman: state.filter.minRial == null
            ? null
            : state.filter.minRial! / 10,
        draftMaxToman: state.filter.maxRial == null
            ? null
            : state.filter.maxRial! / 10,
        isMinValid: true,
        isMaxValid: true,
        canApply: switch (kind) {
          WalletFilterKind.types => state.filter.types.isNotEmpty,
          WalletFilterKind.date => state.filter.period != null,
          WalletFilterKind.amount => true,
        },
      ),
    );
  }

  void toggleType(WalletTransactionType type) {
    final types = {...state.draftTypes};
    types.contains(type) ? types.remove(type) : types.add(type);
    emit(state.copyWith(draftTypes: types, canApply: types.isNotEmpty));
  }

  void toggleAllTypes() {
    final types = state.draftTypes.length == WalletTransactionType.values.length
        ? <WalletTransactionType>{}
        : WalletTransactionType.values.toSet();
    emit(state.copyWith(draftTypes: types, canApply: types.isNotEmpty));
  }

  void selectPeriod(WalletDatePeriod period) {
    emit(
      state.copyWith(
        draftPeriod: period,
        canApply: _validDateRange(period, state.draftFrom, state.draftTo),
        isDateRangeError: false,
      ),
    );
  }

  void selectFromDate(DateTime value) {
    emit(
      state.copyWith(
        draftFrom: value,
        canApply: _validDateRange(state.draftPeriod, value, state.draftTo),
        isDateRangeError:
            state.draftTo != null && value.isAfter(state.draftTo!),
      ),
    );
  }

  void selectToDate(DateTime value) {
    emit(
      state.copyWith(
        draftTo: value,
        canApply: _validDateRange(state.draftPeriod, state.draftFrom, value),
        isDateRangeError:
            state.draftFrom != null && state.draftFrom!.isAfter(value),
      ),
    );
  }

  void updateMin(String value) {
    final amount = WalletRules.amount(value);
    final valid = value.isEmpty || amount != null;
    emit(
      state.copyWith(
        draftMin: value,
        draftMinRial: amount,
        draftMinToman: amount == null ? null : amount / 10,
        isMinValid: valid,
        canApply: _validAmounts(
          amount,
          state.draftMaxRial,
          valid,
          state.isMaxValid,
        ),
        isAmountRangeError: !_validAmounts(
          amount,
          state.draftMaxRial,
          valid,
          state.isMaxValid,
        ),
      ),
    );
  }

  void updateMax(String value) {
    final amount = WalletRules.amount(value);
    final valid = value.isEmpty || amount != null;
    emit(
      state.copyWith(
        draftMax: value,
        draftMaxRial: amount,
        draftMaxToman: amount == null ? null : amount / 10,
        isMaxValid: valid,
        canApply: _validAmounts(
          state.draftMinRial,
          amount,
          state.isMinValid,
          valid,
        ),
        isAmountRangeError: !_validAmounts(
          state.draftMinRial,
          amount,
          state.isMinValid,
          valid,
        ),
      ),
    );
  }

  bool _validAmounts(int? min, int? max, bool minValid, bool maxValid) =>
      minValid && maxValid && (min == null || max == null || min <= max);
  bool _validDateRange(
    WalletDatePeriod? period,
    DateTime? from,
    DateTime? to,
  ) =>
      period != WalletDatePeriod.custom ||
      (from != null && to != null && !from.isAfter(to));
  Future<void> applyFilter() async {
    final range = WalletRules.dateRange(
      state.draftPeriod,
      DateTime.now(),
      state.draftFrom,
      state.draftTo,
    );
    final filter = switch (state.filterKind!) {
      WalletFilterKind.types => WalletTransactionFilter(
        types: Set.unmodifiable(state.draftTypes),
        period: state.filter.period,
        from: state.filter.from,
        to: state.filter.to,
        minRial: state.filter.minRial,
        maxRial: state.filter.maxRial,
      ),
      WalletFilterKind.date => WalletTransactionFilter(
        types: state.filter.types,
        period: state.draftPeriod,
        from: range.$1,
        to: range.$2,
        minRial: state.filter.minRial,
        maxRial: state.filter.maxRial,
      ),
      WalletFilterKind.amount => WalletTransactionFilter(
        types: state.filter.types,
        period: state.filter.period,
        from: state.filter.from,
        to: state.filter.to,
        minRial: state.draftMinRial,
        maxRial: state.draftMaxRial,
      ),
    };
    emit(state.copyWith(filter: filter, filterKind: null));
    await fetchTransactions();
  }

  void cancelFilter() {
    emit(state.copyWith(filterKind: null));
  }

  Future<void> clearTypes() async {
    emit(
      state.copyWith(
        filter: WalletTransactionFilter(
          period: state.filter.period,
          from: state.filter.from,
          to: state.filter.to,
          minRial: state.filter.minRial,
          maxRial: state.filter.maxRial,
        ),
      ),
    );
    await fetchTransactions();
  }

  Future<void> clearDate() async {
    emit(
      state.copyWith(
        filter: WalletTransactionFilter(
          types: state.filter.types,
          minRial: state.filter.minRial,
          maxRial: state.filter.maxRial,
        ),
      ),
    );
    await fetchTransactions();
  }

  Future<void> clearAmount() async {
    emit(
      state.copyWith(
        filter: WalletTransactionFilter(
          types: state.filter.types,
          period: state.filter.period,
          from: state.filter.from,
          to: state.filter.to,
        ),
      ),
    );
    await fetchTransactions();
  }
}
