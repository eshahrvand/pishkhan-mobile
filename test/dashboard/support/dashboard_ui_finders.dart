import 'package:pishkhan_mobile/generated/l10n.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/cards_tab.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/deposits_tab.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/loans_tab.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_all_services_screen.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/home/widgets/dashboard_cards_carousel.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/home/widgets/dashboard_deposits_carousel.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/home/widgets/dashboard_loans_carousel.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_bank_services.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_services_sheet.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_category_heading.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_reso_banner_panel.dart';
export 'package:pishkhan_mobile/shared/assets/app_assets.dart';
export 'package:pishkhan_mobile/generated/l10n.dart';
export 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_service_option.dart';
export 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/widgets/dashboard_card_tile.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/widgets/dashboard_loan_tile.dart';
import 'package:pishkhan_mobile/shared/widgets/app_resalat_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_loan_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';

Finder dashboardButton(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is AppButton &&
      (widget.label == label || widget.semanticLabel == label),
);

Finder dashboardGroup(String title) => find.byWidgetPredicate(
  (widget) => widget is AppServiceGridCard && widget.title == title,
);

Finder dashboardCard(String id) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is DashboardCardTile && widget.card.id == id,
  ),
  matching: find.byType(AppResalatCard),
);

Finder dashboardLoan(String id) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is DashboardLoanTile && widget.loan.id == id,
  ),
  matching: find.byType(AppLoanCard),
);

Finder dashboardCarousel(Type carousel) =>
    find.descendant(of: find.byType(carousel), matching: find.byType(PageView));

Finder dashboardIndicator(Type carousel, int index) => find
    .descendant(
      of: find.byType(carousel),
      matching: find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.selected != null,
      ),
    )
    .at(index);

Finder dashboardImagePosition(String asset) => find
    .ancestor(
      of: find.byWidgetPredicate(
        (widget) => widget is AvpImage && widget.image == asset,
      ),
      matching: find.byType(Positioned),
    )
    .first;

Finder dashboardSemantic(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

Finder dashboardResetButton(String label) => find.descendant(
  of: find
      .ancestor(
        of: find.text(S.current.dashboardResetDescription),
        matching: find.byType(Material),
      )
      .first,
  matching: dashboardButton(label),
);
