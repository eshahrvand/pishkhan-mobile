import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/loan_application.dart';
import '../repositories/loan_application_repository.dart';

class FetchLoanCatalogUseCase {
  const FetchLoanCatalogUseCase(this.repository);
  final LoanApplicationRepository repository;
  Future<Result<LoanCatalog>> call() async {
    try {
      return await repository.fetchCatalog();
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class QuoteLoanUseCase {
  const QuoteLoanUseCase(this.repository);
  final LoanApplicationRepository repository;
  Future<Result<LoanQuote>> call(LoanQuoteInput input) async {
    try {
      return await repository.quote(input);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class FetchLoanInquiriesUseCase {
  const FetchLoanInquiriesUseCase(this.repository);
  final LoanApplicationRepository repository;
  Stream<Result<List<LoanInquiry>>> call(LoanQuote quote) async* {
    try {
      yield* repository.inquire(quote);
    } catch (_) {
      yield const Err(UnexpectedFailure());
    }
  }
}

class CheckLoanGuarantorUseCase {
  const CheckLoanGuarantorUseCase(this.repository);
  final LoanApplicationRepository repository;
  Future<Result<LoanGuarantor>> call(String nationalId, LoanQuote quote) async {
    try {
      return await repository.checkGuarantor(nationalId, quote);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class CheckLoanCollateralUseCase {
  const CheckLoanCollateralUseCase(this.repository);
  final LoanApplicationRepository repository;
  Future<Result<LoanCollateral>> call(
    LoanQuote quote,
    LoanCollateral collateral,
  ) async {
    try {
      return await repository.checkCollateral(quote, collateral);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SaveLoanDraftUseCase {
  const SaveLoanDraftUseCase(this.repository);
  final LoanApplicationRepository repository;
  Future<Result<LoanDraft>> call(LoanDraft draft) async {
    try {
      return await repository.saveDraft(draft);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class RequestLoanSigningOtpUseCase {
  const RequestLoanSigningOtpUseCase(this.repository);
  final LoanApplicationRepository repository;
  Future<Result<LoanSigningChallenge>> call(LoanDraft draft) async {
    try {
      return await repository.requestSigningOtp(draft);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class SubmitLoanApplicationUseCase {
  const SubmitLoanApplicationUseCase(this.repository);
  final LoanApplicationRepository repository;
  Future<Result<LoanRecord>> call(
    LoanDraft draft,
    LoanSigningChallenge challenge,
    String otp,
  ) async {
    try {
      return await repository.submit(draft, challenge, otp);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}

class CancelLoanApplicationUseCase {
  const CancelLoanApplicationUseCase(this.repository);
  final LoanApplicationRepository repository;
  Future<Result<void>> call(String draftId) async {
    try {
      return await repository.cancel(draftId);
    } catch (_) {
      return const Err(UnexpectedFailure());
    }
  }
}
