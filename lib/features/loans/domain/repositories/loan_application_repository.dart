import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/loan_application.dart';

abstract interface class LoanApplicationRepository {
  Future<Result<LoanCatalog>> fetchCatalog();
  Future<Result<LoanQuote>> quote(LoanQuoteInput input);
  Stream<Result<List<LoanInquiry>>> inquire(LoanQuote quote);
  Future<Result<LoanGuarantor>> checkGuarantor(
    String nationalId,
    LoanQuote quote,
  );
  Future<Result<LoanCollateral>> checkCollateral(
    LoanQuote quote,
    LoanCollateral collateral,
  );
  Future<Result<LoanDraft>> saveDraft(LoanDraft draft);
  Future<Result<LoanSigningChallenge>> requestSigningOtp(LoanDraft draft);
  Future<Result<LoanRecord>> submit(
    LoanDraft draft,
    LoanSigningChallenge challenge,
    String otp,
  );
  Future<Result<void>> cancel(String draftId);
}
