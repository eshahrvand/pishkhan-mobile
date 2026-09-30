# Shared component / Figma mapping

This document maps app-owned shared Flutter components to their source Figma
components. These widgets live in this repository under `lib/shared/widgets/`;
they do not change the public API of `avp_ui`.

| Figma component | Figma node | Flutter component | Flutter source | Supported variants / notes |
| --- | --- | --- | --- | --- |
| Drawer menu | `16345:98596`, `16345:98461` | `AppDrawer` | `lib/shared/widgets/app_drawer.dart` | Open/closed, selected/unselected item, expandable sub-items, controlled state. |
| Invoice | `16662:53720` | `AppInvoice`, `AppInvoiceLine` | `lib/shared/widgets/app_invoice.dart` | Open/closed detail list and sufficient/insufficient wallet status. |
| Cards / SingleCard / HomeCard | `16634:22500` | `AppServiceGridCard`, `AppServiceGridItem` | `lib/shared/widgets/app_service_grid_card.dart` | `service` and `quick` visual variants; data, icon, and action are supplied by the caller. |
| WalletCard | `13953:13960` | `AppWalletCard` | `lib/shared/widgets/app_wallet_card.dart` | `mobile` and `desktop` layouts. |
| DepositList | `15973:77374` | `AppDepositList` | `lib/shared/widgets/app_deposit_list.dart` | Configurable deposit title, number, status badge, and more action. |
| CardsList | `15962:66343` | `AppCardsList` | `lib/shared/widgets/app_cards_list.dart` | `resalat`, `gift`, `virtual`, `coupon`, and `family` card types. |
| ResalatCard | `13910:3347` | `AppResalatCard` | `lib/shared/widgets/app_resalat_card.dart` | Single/multi, show/hide, selected/unselected, copy and more actions. |
| DepositCard | `13906:3913` | `AppDepositCard` | `lib/shared/widgets/app_deposit_card.dart` | Single/multi, selected/unselected, optional logo, and copy actions. |
| LoanCard | `13918:3460` | `AppLoanCard` | `lib/shared/widgets/app_loan_card.dart` | Single/multi layout, progress, copy, and arrow actions. |
| Arrow | `13954:8942` | `AppArrowButton` | `lib/shared/widgets/app_arrow_button.dart` | Left/right 48px arrow plus the 28px compact card usage. |
| Bottom sheet header | `15769:17067` | `AppBottomSheetHeader` | `lib/shared/widgets/app_bottom_sheet_header.dart` | Header and handle-only variants with configurable actions and icons. |
| Delete address sheet | `16634:46458` | `AppDeleteAddressSheet` | `lib/shared/widgets/app_delete_address_sheet.dart` | Address confirmation content with destructive and cancel actions. |
| Confirmers details card | `16256:124134` | `AppConfirmerDetailsCard` | `lib/shared/widgets/app_confirmer_details_card.dart` | Approved and waiting status variants. |
| Me as representative card | `15826:97055` | `AppMeAsRepresentativeCard` | `lib/shared/widgets/app_representative_cards.dart` | Active and expired states with representation details. |
| My representative card | `15826:96343` | `AppMyRepresentativeCard` | `lib/shared/widgets/app_representative_cards.dart` | Active, waiting, and expired states with representative details. |
| Credit card mockup | `15884:6299` | `AppCreditCardMockup` | `lib/shared/widgets/app_credit_card_mockup.dart` | Mobile, web, phone, active/inactive, and wallet variants. |
| File upload base | `15907:44055` | `AppFileUploadBase` | `lib/shared/widgets/app_file_upload_base.dart` | Empty, uploading, and uploaded states. |
| Transfer destination card | `16293:181820` | `AppTransferDestinationCard` | `lib/shared/widgets/app_transfer_destination_card.dart` | Internal, Satna, and Paya transfer details. |
| Address card | `15939:10358` | `AppAddressCard` | `lib/shared/widgets/app_address_card.dart` | Home and Work address variants. |
| Occupation card | `15936:32739` | `AppOccupationCard` | `lib/shared/widgets/app_occupation_card.dart` | Occupation title and description with a configurable more action. |
| Request report card | `15934:32160` | `AppRequestReportCard` | `lib/shared/widgets/app_request_report_card.dart` | Optional details row, date, status badge, and more action. |
| Transaction card | `15924:41539` | `AppTransactionCard` | `lib/shared/widgets/app_transaction_card.dart` | Discharge, charge, transfer, and shopping variants. |

## Usage rules

- Compose these components in screens with feature data and callbacks; do not
  put navigation, API calls, or domain state inside them.
- Keep every new shared component RTL-first and use `avp_ui` tokens and public
  primitives (`AppBadge`, typography, colors, spacing, radius, shadows) where
  available.
- Store every app-owned SVG/PNG directly under the flat `assets/images/`
  directory, which is registered once in this app's `pubspec.yaml`.
- Reuse an existing file only when its binary content is identical. Give true
  shared assets a semantic name; prefix unique assets with their feature or
  component name to prevent collisions.
- Add every path to `AppAssets` and reference that registry (or a thin
  feature-scoped alias) from Dart code. Do not hard-code asset paths in UI
  widgets.
- Add a focused widget test in `test/` for each interactive state.

## Dashboard composition (updated design)

The dashboard uses the frames `27850:10690`, `27850:10768`, `27850:10872`,
`27850:11009`, `27850:11147`, and `27850:11293` in the Mobile Figma file.
`AppServiceGridCard` accepts a `footer` and `itemSpacing`; its public
`AppServiceGridItemView` is reused for the shortcut editor and service catalog.
The dashboard owns the Reso artwork, transactional shortcut state (at most four
unique services), reset confirmation, and searchable category sheet.

`DashboardScreen.initialFavorites` supplies saved service IDs and
`onFavoritesChanged` reports confirmed or reset selections. The screen keeps
these selections for its lifetime; durable storage belongs to its caller.
`onServiceRequested` and `onPromptSubmitted` connect the UI to service and
assistant flows. Category navigation opens the corresponding service sheet.

The replaced dashboard banners, category sections, latest-request preview, and
welcome/timer card have been removed along with their unused assets.
