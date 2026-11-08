# Wallet information

Status: implemented against an in-memory demo adapter; no live wallet API is configured.

- Feature: `lib/features/wallet`; flow: `presentation/overview`.
- Service ID: `wallet-info`; route: `/wallet/overview`.
- Boundary: screen-owned Cubit → registered operation UseCase → `WalletRepository`.
- Rules: [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md).

## Design references

- [Frame 28201-88396](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88396&m=dev)

## Flow and operation ownership

Displays the current balance, linked deposit, four operation entries and transaction history. The balance refresh delegates to `fetchWallet`; returning from a child route also delegates to that owner, including cancellation. Each child owns its own Cubit. The overview is not a shared mutable Cubit for the other five flows.

| Operation | Owner | Triggers |
|---|---|---|
| Fetch catalog / wallet | `fetchWallet` | Provider entry, refresh, retry, `applyFlowReturn` |

The screen consumes a typed destination before awaiting navigation and passes the raw route result back to Cubit. Data and failure feedback have independent listeners. A failed refresh can retry without recreating the Provider.

Loading, failure/retry and successful content are rendered explicitly inside each screen’s `BlocBuilder`, following the existing feature-screen style. There is no wallet-specific request-status wrapper.

Existing `AppCreditCardMockup` (wallet, compact), `AppServiceGridCard`, top bar and assistant button are reused. The wallet card on Home also opens this service. The mockup's physical offsets now remain visible at narrow widths while retaining its 343px design geometry.

The Dashboard home balance remains its existing independent dashboard fixture; it is not a subscription to the wallet demo ledger. Within `wallet`, all six flows read the same repository ledger and overview refreshes after returning. Production Home and wallet need a server-backed shared balance contract rather than cross-feature Cubit access.

## Verification

Behavioral coverage is in `test/wallet/wallet_cubit_test.dart` and
`test/wallet/wallet_screen_test.dart`. Run the changed feature only:

```sh
flutter test --no-pub test/wallet
```

The overview document lists the directly related shared regression scope.
All request failures publish the operation status, Failure and prepared message
together. Old failure text is retained across loading/success and never suppresses
an independent navigation or share effect. Buttons pass operation loading through
`isLoading` and enablement through `isActive`, with directly bound callbacks.

Related regressions for routing, DI, Dashboard wallet entry and the reused card
components:

```sh
flutter test --no-pub test/wallet test/core/di test/core/router test/core/config/image_assets_test.dart test/dashboard/implemented_services_navigation_test.dart test/dashboard/presentation/flows/home/screens/dashboard_review_test.dart test/app_requested_cards_test.dart test/app_profile_activity_cards_test.dart
```

Optional visual captures: `CAPTURE_WALLET_PREVIEWS=1 flutter test --no-pub test/wallet/wallet_screen_test.dart`.
Images are ignored under `build/previews/wallet/`; no extra review/report MDs are created.
The six documents retain each flow's design, operation ownership and integration boundary.

Verified 2026-11-08: the scoped regression command above passed **89 tests**.
`flutter analyze --no-pub lib/features/wallet lib/core/di/injection_container.dart lib/core/router lib/core/flow/service_registry.dart lib/core/presentation/mappers/request_error_message_mapper.dart lib/shared/widgets/app_credit_card_mockup.dart lib/shared/widgets/app_transaction_card.dart lib/features/dashboard/presentation/home/widgets/dashboard_home_panel.dart test/wallet test/core/router/app_router_test.dart` reported **No issues found**.
The wallet-only suite includes input validation, OTP expiry/retry, lost-response
idempotency, stale recipient results, linked-deposit refresh, composed filters,
cancelled drafts, Jalali leap dates, platform sharing and loading/back gates.
Cubit duplication review: each request has one await/result-switch owner in its
own flow. Charge/withdraw eligibility and amount-range predicates are shared
pure calculations. Independent flows retain explicit emits. Flow review found no
blanket failure/message clears; OTP resets, draft resets and command consumption
all have visible consumers.
