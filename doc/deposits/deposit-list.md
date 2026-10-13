# Standalone deposit list

Implemented on `feature/deposits`, based on `feature/ui-component` at
`6f3d2c1`. The preceding UI branch has PR #1 targeting `feature/dev`.

## Design and naming

All three frames belong to Figma file `nYQNyZdSs98lwymCpt5Sag`:

| Phase | Node | App composition |
| --- | --- | --- |
| Deposit list | `28060:13805` | `DepositListScreen` |
| Deposit operation menu | `28060:15113` | `DepositActionsSheet` |
| Account owner information | `28060:15220` | `DepositAccountDetailsSheet` |

The two sheets have different class, launcher and file names. The account
details sheet retains the authored title “Customer information” and lists the
selected account's owners, national identifiers, roles and shares. Its Back
button closes the sheet and restores the list. System Back and outside dismissal
also close the current sheet.

## Ownership and behavior

The standalone flow lives under `lib/features/deposits/`; dashboard deposit
summaries stay in `features/dashboard`. `ListedDeposit` and `DepositOwner` are
immutable Equatable models. `DepositsRepository` returns typed Result values;
`LoadDeposits` validates stable IDs, numbers and owner fields and maps adapter
exceptions to coded failures. `DepositListCubit` uses plain Freezed data and
explicit `emit(state.copyWith(...))` transitions, with no state-preparation
wrapper. Overlapping loads and completions after disposal are guarded.

The initial list filters for Open status, matching the selected Status chip.
Account type and status filters combine. Pressing a selected chip clears that
filter; pressing an unselected chip opens a package-button option sheet.
Dismissing options leaves the previous selection unchanged. Loading, error,
empty catalog and no matching deposits have separate views; errors offer Retry.

Each overflow action opens the operation sheet. Account details opens the
second sheet for that same deposit. The other seven actions report a typed
`DepositListActionRequest` to an injected host callback. Without a handler,
they show a localized integration-unavailable notice. No banking execution,
block, SMS setting update, transfer or wallet debit is performed.

The three default rows and two account owners are illustrative Figma fixtures;
duplicate display numbers and the sample nine-digit national identifier are
retained as display data, never presented as verified identity. A live adapter
must supply authoritative ownership, eligibility and operation permissions.

## Components, assets and localization

Reuse `AppDepositList`, `AppTopBar`, `AppBottomSheetHeader`,
`AppAssistantButton`, and the public `avp_ui` Chips, Button, Badge and typography.
The shared deposit row adds optional localized label/divider slots and
`alignContentToEdges`; previous defaults remain unchanged. The new list enables
edge alignment and uses the authored blue deposit and rotated overflow icons.

The back icon is exported from the actual overridden instance
`I28060:13806;13867:8754;13867:8738`; the parent context returned base menu
artwork despite displaying the back override. Every new asset is local and
registered in `AppAssets`. Exact duplicate info and separator assets reuse the
existing registry. Original dotted leaders and scrim are retained; Flutter's
native backdrop filter supplies the blur unsupported by SVG rendering.

At 375×812, reserve native 24/40px system insets. The list begins at y176;
cards are 343×112 with 10px gaps. The action sheet starts at y240; the details
sheet starts at y308. Modal panels constrain their height and scroll on compact
phones. System bars are owned by the platform, never drawn as app assets.
All new interface copy is in fa/en/ar ARBs, and every locale remains RTL.

## Entry and integration

`DepositsRoutes.list` is `/deposits/list`, protected by the existing auth guard
and included in the validated post-login destination allowlist. The
`deposit-list` service ID opens it through the existing core service registry;
explicit dashboard service callbacks keep precedence. The assistant returns to
Home and invokes the optional originating prompt callback.

Supply `DepositListScreen.repository` and `onActionRequested` for integration.
Changing the repository replaces the provider scope; normal rebuilds retain
the Cubit. Bank API definitions, transport mapping, persistent storage and
operation flows beyond the supplied sheets remain adapter/host work.

## Verification

Unit and widget suites live under `test/deposits/`. They cover filter
intersection/clearing, empty/error/retry and invalid contracts, stale loads,
disposal, selected-deposit action context, distinct sheets, authenticated
routing, reference geometry and 320px screens with larger text in fa/en/ar.
Existing router, shared deposit row, dashboard and asset tests are regressions.

Final validation: all 292 application tests pass, including nine new deposit
tests. `flutter analyze` reports only the pre-existing `path_not_posix`
warning for the user's Windows `avp_ui` path override in `pubspec.yaml`.
That local dependency override is preserved. No device banking integration or
production execution is claimed by these unit/widget tests.

Optional captures:

```powershell
$env:CAPTURE_DEPOSIT_LIST_PREVIEWS='1'
flutter test test/deposits/deposit_list_screen_test.dart
```

PNG previews go to ignored `build/previews/deposits/`, never `doc/`.
