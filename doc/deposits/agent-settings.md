# Agent settings

Code uses `agent_settings` / `AgentSettingsCubit`; the introduction flow uses
`introduce_agent` / `AgentCubit`. Existing public URLs and service IDs below are
retained for compatibility with saved links and service-catalog contracts.

Route: `/deposits/representation-settings`. The dashboard and deposit-list
`deposit-representation-settings` service open this catalog. An optional deposit
number is resolved in Cubit against the fetched catalog, normalizing Persian /
Arabic digits and separators. Unknown entry numbers leave the catalog unfiltered.
The original `/deposits/introduce-representative` route remains available through
Add Agent and the distinct `deposit-representative` service.

## Behavior

- My Agents and Me as Agent share one Provider-owned Cubit.
  Tab changes retain active filters. Only My Agents shows Add.
- Deposit, authorization type and status filters support multiple selections,
  Select All, Apply and Cancel. Outside dismissal and system Back discard drafts.
  Draft changes never affect the visible list until Apply. All groups intersect;
  an empty selection matches nothing. Applying all options removes that group's
  restriction. A selected chip clears only its own group.
- Item actions show details or Cancel Agent. Details use the selected
  immutable record and its actual approvers; header and system Back return to
  the same tab and filters. Cancellation intentionally shows unavailable feedback,
  without changing records, as requested by the owner.
- Add opens the existing introduction flow with the original entry deposit.
  That flow retains its existing submission, receipt and exit behavior.
- Loading disables filter interaction. Failures expose Retry; empty catalogs and
  filter results display an empty-state message. Back remains available during
  fetches. Rebuilding the screen retains its Cubit.

## Ownership and reuse

`AgentSettingsScreen` directly constructs `AgentSettingsCubit`
in `BlocProvider.create` and calls `fetchAgents`. The Cubit resolves its
repository from GetIt and publishes explicit `copyWith` updates. Its State is a
single plain Freezed `.initial` / `part of` class. Repository/use-case exceptions
are converted into the project's existing `UnexpectedFailure` at the boundary.
No Cubit is registered in GetIt; there are no construction helpers, State
preparation/publication wrappers, defensive entry guards or `isClosed` checks.

The Cubit owns filtering, draft selection, entry resolution, modal result
interpretation and effect decisions. Named, filtered UI listeners execute sheet,
navigation and snackbar operations, returning raw modal results after mounted
checks. Sheets borrow the existing Cubit with `BlocProvider.value`.

Existing `AppMyAgentCard`, `AppMeAsAgentCard`,
`AppConfirmerDetailsCard`, `AppTopBar`, `AppBottomSheetHeader`, `AppAssistantButton`,
`CertificateSummaryRow`, deposit sheet layout, public avp_ui chips, checkboxes
and buttons are reused. Optional card appearance parameters express the Figma
instances. Minimum card/row heights allow larger text without changing normal
375px geometry. Original detail-divider and cancellation/add SVGs are local
assets; the cancellation icon uses the instance's error color.

## Integration limits

`MockAgentSettingsRepository` supplies preview records only. No bank
agent lookup or cancellation API is connected. Status comes from the
repository, never from a client calculation against expiry dates. Domain dates
are Gregorian UTC and UI uses the existing Jalali formatter. The existing Add
flow's mock submission does not create catalog records or banking authorities.

Figma sources in file `nYQNyZdSs98lwymCpt5Sag`:
`28060:13926` (my agents), `28060:14193` (delegated),
`28060:14279` / `28060:14328` / `28060:14374` (filter sheets),
`28060:14216` (selected filter), `28060:14420` (actions), and
`28060:14242` (details). Approver green/warning labels preserve the supplied
design's text; the data keeps approval status separately.

## Verification

Behavior tests are in `test/deposits/agent_settings_cubit_test.dart`
and `test/deposits/agent_settings_screen_test.dart`. Router tests include
the new module-prefixed route and post-login whitelist. Related introduction and
shared-card tests cover retained behavior. Optional captures use
`CAPTURE_CERTIFICATE_PREVIEWS=1` and write ignored
`build/previews/certificates/agent-settings-*.png` files.
