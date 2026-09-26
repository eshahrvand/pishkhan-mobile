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

## Usage rules

- Compose these components in screens with feature data and callbacks; do not
  put navigation, API calls, or domain state inside them.
- Keep every new shared component RTL-first and use `avp_ui` tokens and public
  primitives (`AppBadge`, typography, colors, spacing, radius, shadows) where
  available.
- Store app-owned Figma SVGs under `assets/images/<component_name>/` and add
  the folder to this app's `pubspec.yaml`.
- Add a focused widget test in `test/` for each interactive state.
