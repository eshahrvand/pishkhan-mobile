# My Cards — Phase 1 implementation review

[Rendered previews](cards-review/index.html)

| Screen | Figma node | Preview |
| --- | --- | --- |
| Multiple cards | [27902:82561](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82561&m=dev) | [PNG](cards-review/phase1-multi.png) |
| Single card | [27902:82533](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-Mobile?node-id=27902-82533&m=dev) | [PNG](cards-review/phase1-single.png) |

## Reused components

- `AppResalatCard`: existing 335 × 202 single and 316 × 191 multi variants. Refined the gradient, security-field geometry, Medium/DemiBold detail weights, visibility masking, semantic labels and responsive width/text sizing.
- `AppServiceGridCard` and `AppServiceGridItemView`: existing service and quick-access variants. The new optional `stretchItems: false` preserves the 72px micro-service width, 6px gaps, and RTL alignment used by these frames. Existing callers retain their previous defaults.
- `AppTopBar`, `AppPrimaryNavigation`, `AppAssistantButton`, `AppAssistantIcon` and `AppServiceArtworkTile`: extracted the compatible dashboard visuals into shared widgets. Dashboard compatibility names remain available, and its existing notifications, search and customization interactions are retained.
- `AppShadows.bankCard` in `avp_ui`: reproduces the card instance's two shadow layers. The existing general-purpose `md` token remains separate.

All static assets are local and registered in `AppAssets`. The virtual-card artwork was exported from the original quick-access instance because the generated asset reference returned an identity icon. No screenshots are used as UI assets.

## Behavior and integration

The second primary tab now opens `CardsScreen` from `DashboardScreen`.
Single-card data automatically selects the single layout; multiple cards use a snapping RTL carousel with neighboring-card previews and indicators.

Each card keeps its own visibility state. Hidden details mask expiry and CVV2 while retaining the card number and IBAN, matching Figma.
Copy actions preserve the original card number/IBAN and use the system clipboard unless the caller supplies an override.

Actions return `CardActionRequest`, including the selected `BankCard` and action.
The selected card's `canSetSecondPin` determines whether the middle PIN operation is “Set second PIN” (single frame) or “Forgot second PIN” (multi frame).
The more/menu actions have caller callbacks; additional menu/service screens are outside these two supplied frames.

Supply `DashboardScreen.cards`, `onCardActionRequested` and `onCardMorePressed` for integration.
The existing `onServiceRequested` remains a fallback for action IDs.
`CardsScreen` also exposes copy overrides and selected-card/tab/assistant callbacks.
Default data are the Figma examples; fetching real cards and executing bank services belong to the caller.

Tab switching retains dashboard favorites and card state. Back from Cards returns to Dashboard.
Deposits/Loans continue to open their existing service catalogs until their tab designs are implemented.

## Validation

Focused tests check both frame layouts, RTL ordering, carousel selection, per-card visibility, original-value copying, service callbacks, tab switching/back, enlarged text/small screens and empty data.
The dashboard and notification regression tests are included because navigation and header visuals are now shared.

To regenerate previews, set `UPDATE_CARDS_PREVIEWS=1` and run `flutter test test/cards_screen_test.dart`.
Native status/navigation bars are excluded from the PNGs.
