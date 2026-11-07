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
`LoadDepositsUseCase` validates stable IDs, numbers and owner fields and maps adapter
exceptions to coded failures. `DepositListCubit` uses plain Freezed data and
explicit `emit(state.copyWith(...))` transitions, with no state-preparation
wrapper. The operation uses async/await and a Result switch. Controls gate
invocation; there is no disposal guard or speculative request ID.

The initial list has no status filter and shows deposits of every status.
Account type and status filters combine. Pressing a selected chip clears that
filter; pressing an unselected chip opens the shared `avp_ui`
`showAppSelectSheet` with typed account-kind or status options, matching the
app's other selectors. The operation and account-details panels retain the
shared app service-sheet route.
Dismissing options leaves the previous selection unchanged. Loading, error,
empty catalog and no matching deposits have separate views; errors offer Retry.

Each overflow action opens the operation sheet. Account details opens the
second sheet for that same deposit. The other seven actions prepare a typed `DepositListActionRequest`; the optional
host callback keeps precedence. Without a handler, Statement, Certificate, Block
and Agent settings open their existing service routes with the selected number.
Unconnected actions show the localized unavailable notice. The list itself does
not execute account operations or debit a wallet.

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
referenced with `AppConstants.baseImage`. Exact duplicate info and separator assets reuse the
existing registry. Original dotted leaders and scrim are retained; Flutter's
native backdrop filter supplies the blur unsupported by SVG rendering.

At 375×812, reserve native 24/40px system insets. The list begins at y176;
cards are 343×112 with 10px gaps. The action sheet starts at y240; the details
sheet starts at y308. Modal panels constrain their height and scroll on compact
phones. System bars are owned by the platform, never drawn as app assets.
All new interface copy is in fa/en/ar ARBs, and every locale remains RTL.

## Entry and integration

`AppRoutes.depositList` is `/deposits/list`, protected by the existing auth guard
and included in the validated post-login destination allowlist. The
`deposit-list` service ID opens it through the existing core service registry;
explicit dashboard service callbacks keep precedence. The assistant uses its optional host callback when supplied; otherwise it
returns Home.

Supply `onActionRequested` for host integration when needed. Repository wiring
belongs in GetIt; the screen has no repository argument. Provider owns the Cubit;
normal rebuilds retain it. Bank API definitions, transport mapping, persistent storage and
operation flows beyond the supplied sheets remain adapter/host work.

## Verification

Unit and widget suites live under `test/deposits/`. They cover filter
intersection/clearing, empty/error/retry and invalid contracts,
selected-deposit action context, distinct sheets, authenticated
routing, reference geometry and 320px screens with larger text in fa/en/ar.
Existing router, shared deposit row, dashboard and asset tests are regressions.

Historical test totals are superseded by the scoped execution recorded in
[phase 6 review](phase-6-review.md). Unit/widget tests do not claim production
bank integration.

Optional captures:

```powershell
$env:CAPTURE_DEPOSIT_LIST_PREVIEWS='1'
flutter test test/deposits/deposit_list_screen_test.dart
```

PNG previews go to ignored `build/previews/deposits/`, never `doc/`.

## UI/Cubit contract adoption (2026-10-17)

The production screen no longer accepts a Repository or creates a Mock adapter.
GetIt registers the repository and `LoadDepositsUseCase` dependencies. BlocProvider.create directly
constructs DepositListCubit with no repository argument and owns disposal. The Cubit resolves its registered UseCase in a final field. Cubit owns
filter-menu requests, action/detail requests and prepared service destinations.
The listener returns raw sheet selections; host callbacks retain precedence.

### Dependency and listener clarification (2026-10-17)

The screen/feature-flow widget owns BlocProvider.create, including Home in
DashboardScreen; GoRouter only selects the destination. Cubits resolve existing
Repository/service/UseCase registrations through GetIt fields, without dependency
constructor arguments from UI. Multi-case and substantial async listeners use
named widget/State methods with the existing listenWhen filter.

## Phase 6 notification and style adoption

Under [contract v1.22](../ui-cubit-state-agent-rules-en.md), request errors notify
on each operation's entering-failure transition. Every failure publishes status,
Failure and its prepared message together. Last failure/message remain through
loading, success, input and command changes; message presence is not an event.
Independent failure, typed-effect and receipt subscriptions share
`MultiBlocListener`; rendering uses `BlocBuilder`. Effects never inspect a retained
message before executing. Success uses the existing receipt, without replaying
old failure text. Retry/empty sections, actual validation and loading gates stay.
See [phase 6 review](phase-6-review.md) for operation ownership, preserved resets,
UseCase wiring, integration limits and current scoped checks.
