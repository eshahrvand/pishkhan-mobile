import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/cheque_clearance.dart';

TextStyle chequeLabelStyle(BuildContext context) =>
    AppTypography.bodySmall.copyWith(
      color: context.colors.textSecondary,
      fontWeight: FontWeight.w500,
      height: 18 / 12,
      letterSpacing: 0,
    );
TextStyle chequeValueStyle(BuildContext context) =>
    AppTypography.bodyMedium.copyWith(
      color: context.colors.textPrimary,
      height: 20 / 14,
      letterSpacing: 0,
    );

String chequeReasonLabel(ChequeClearanceReason reason) => switch (reason) {
  ChequeClearanceReason.depositAndBlock =>
    S.current.chequeReasonDepositAndBlock,
  ChequeClearanceReason.olderThanThreeYears =>
    S.current.chequeReasonOlderThanThreeYears,
  ChequeClearanceReason.originalCheque => S.current.chequeReasonOriginal,
  ChequeClearanceReason.partialPaymentCertificate =>
    S.current.chequeReasonPartialPayment,
  ChequeClearanceReason.notarizedConsent => S.current.chequeReasonConsent,
  ChequeClearanceReason.judicialLetter => S.current.chequeReasonJudicial,
};

String chequeDocumentLabel(
  ChequeClearanceDocument document,
) => switch (document) {
  ChequeClearanceDocument.originalCheque => S.current.chequeDocumentOriginal,
  ChequeClearanceDocument.partialPaymentCertificate =>
    S.current.chequeReasonPartialPayment,
  ChequeClearanceDocument.notarizedConsent => S.current.chequeDocumentConsent,
  ChequeClearanceDocument.judicialLetter => S.current.chequeDocumentJudicial,
};
