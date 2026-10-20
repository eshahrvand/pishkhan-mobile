import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/on_site_transfer_cubit.dart';

String transferStepTitle(OnSiteTransferStep step) {
  return switch (step) {
    OnSiteTransferStep.source => S.current.transferSourceStep,
    OnSiteTransferStep.visit => S.current.transferVisitStep,
    OnSiteTransferStep.destinations => S.current.transferDestinationsStep,
    OnSiteTransferStep.confirmation => S.current.transferConfirmationStep,
  };
}

String transferStepSupporting(OnSiteTransferStep step) {
  return switch (step) {
    OnSiteTransferStep.source =>
      '${S.current.certificateNextPrefix} ${S.current.transferVisitStep}',
    OnSiteTransferStep.visit =>
      '${S.current.certificateNextPrefix} ${S.current.transferDestinationsStep}',
    OnSiteTransferStep.destinations =>
      '${S.current.certificateNextPrefix} ${S.current.transferConfirmationStep}',
    OnSiteTransferStep.confirmation => S.current.issuanceEnd,
  };
}
