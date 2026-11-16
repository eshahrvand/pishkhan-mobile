import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/card_restriction.dart';

String cardRestrictionTitle(CardRestrictionOperation operation) =>
    switch (operation) {
      CardRestrictionOperation.block => S.current.blockCard,
      CardRestrictionOperation.unblock => S.current.dashboardUnblockCard,
    };

String cardRestrictionIntro(CardRestrictionOperation operation) =>
    switch (operation) {
      CardRestrictionOperation.block => S.current.cardBlockIntro,
      CardRestrictionOperation.unblock => S.current.cardUnblockIntro,
    };

String cardRestrictionReasonLabel(CardRestrictionReason reason) =>
    switch (reason) {
      CardRestrictionReason.lost => S.current.cardRestrictionLost,
      CardRestrictionReason.stolen => S.current.cardRestrictionStolen,
      CardRestrictionReason.depositManagement =>
        S.current.depositRestrictionManagement,
      CardRestrictionReason.found => S.current.cardRestrictionFound,
      CardRestrictionReason.other => S.current.cardRestrictionOther,
    };
