import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/cheque_cancellation.dart';
import '../cubit/cheque_cancellation_cubit.dart';

String cancellationStepTitle(ChequeCancellationStep step) => switch (step) {
  ChequeCancellationStep.selection => S.current.chequeCancelSelectionStep,
  ChequeCancellationStep.cheques => S.current.chequeCancelChequesStep,
  ChequeCancellationStep.reasons => S.current.chequeCancelReasonsStep,
  ChequeCancellationStep.confirmation => S.current.chequeCancelConfirmationStep,
};
String cancellationNextTitle(ChequeCancellationStep step) => switch (step) {
  ChequeCancellationStep.selection =>
    '${S.current.certificateNextPrefix} ${S.current.chequeCancelChequesStep}',
  ChequeCancellationStep.cheques =>
    '${S.current.certificateNextPrefix} ${S.current.chequeCancelReasonsStep}',
  ChequeCancellationStep.reasons =>
    '${S.current.certificateNextPrefix} ${S.current.chequeCancelConfirmationStep}',
  ChequeCancellationStep.confirmation => S.current.issuanceEnd,
};
String cancellationTypeLabel(CancellationChequeType type) => switch (type) {
  CancellationChequeType.paper => S.current.chequeCancelPaper,
  CancellationChequeType.digital => S.current.chequeCancelDigital,
};
String cancellationReasonLabel(ChequeCancellationReason reason) =>
    switch (reason) {
      ChequeCancellationReason.damagedUnused => S.current.chequeCancelDamaged,
      ChequeCancellationReason.judicialOrder => S.current.chequeCancelJudicial,
    };
