# Wallet transactions and filters

Status: implemented against an in-memory demo adapter; no live wallet API is configured.

- Feature: `lib/features/wallet`; flow: `presentation/transactions`.
- Service ID: `wallet-history`; route: `/wallet/transactions`.
- Boundary: screen-owned Cubit → registered operation UseCase → `WalletRepository`.
- Rules: [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md).

## Design references

- [Frame 28201-88683](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88683&m=dev)
- [Frame 28201-88722](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88722&m=dev)
- [Frame 28201-88766](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88766&m=dev)
- [Frame 28201-88810](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88810&m=dev)
- [Frame 28201-88854](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88854&m=dev)
- [Frame 28201-88948](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88948&m=dev)
- [Frame 28201-88980](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88980&m=dev)
- [Frame 28201-88704](https://www.figma.com/design/nYQNyZdSs98lwymCpt5Sag/Pishkhan-AI-%7C-Mobile?node-id=28201-88704&m=dev)

## Flow and operation ownership

Displays charge, withdrawal, wallet transfer and purchase rows using the existing `AppTransactionCard`. Pull-to-refresh and retry delegate to `fetchTransactions`. Shared rows now grow beyond their 72px baseline for larger accessibility text; they are not clipped at the design height.

| Operation | Owner | Triggers |
|---|---|---|
| Filtered transactions | `fetchTransactions` | Provider entry, refresh, retry, Apply, clear each active chip |

**Owner requirement:** the initial filter contains no selected type, no date period and no amount bounds. Empty type selection means no type restriction; it does not select all checkboxes. Select-all supports unchecked, mixed and checked appearances.

Every sheet edits a draft. Apply composes that one category with the other active categories and then fetches. Cancel, outside dismissal and Back discard the draft. Opening again copies the active filter, not the cancelled selections. Applied chips clear their own category without clearing the others. Only one request owner publishes loading/result. Filter controls are unavailable during a fetch and pull-to-refresh awaits that owner; no speculative request-ID field is added for these serialized interactions.

Date periods: today, the last 7/30/90 calendar days, or an inclusive custom range. The stored bounds are Gregorian dates; the fields and rows display Jalali. The calendar affordances open a Jalali `YYYY/MM/DD` input sheet, using the existing central `JalaliDateParser` (including leap-day validation). No Gregorian picker is presented as Jalali. A calendar grid was not supplied in Figma or present in the installed design system; the explicit date input is composed from existing controls. Cancellation preserves the prior bound, invalid dates disable confirmation, and the range rejects start after end.

Minimum/maximum amounts are optional integer rial bounds. Each edited bound is parsed once; the aggregate reads the stored opposite bound and validity. Reversed or invalid bounds disable Apply. Both amount bounds, types and dates combine with AND; selected types combine with OR.

The sheet closes when Apply starts the transaction fetch. Cancellation only discards the draft, avoiding an extra pop during route reversal. Root navigator delivery, keyboard insets, the empty state and independent category removal are covered by tests. The mock returns the complete filtered in-memory ledger; production paging/export parameters are not invented.

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
