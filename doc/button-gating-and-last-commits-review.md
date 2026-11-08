# Button gating and last-two-commits review — 2026-11-08

## Scope

Reviewed these committed ranges without changing the sibling package:

- App: `3015166` and `66f00d5` (`HEAD~2..HEAD`).
- `../avp_ui`: `05fc04f` and `373928d` (`HEAD~2..HEAD`).

The authoritative UI/Cubit/State contract and both project skills control the
button correction. This review does not certify every untouched application
flow or production/bank integration.

## Findings in app commit 66f00d5

### Accepted owner decision — Root modal without top safe-area padding

Location: `lib/features/address/presentation/editor/screens/address_editor_sheet.dart`,
the `showModalBottomSheet` call at lines 13–19.

On 2026-11-08 the owner confirmed that `useRootNavigator: true` and removal of
`useSafeArea: true` were explicitly requested, including the address editor's
edge-to-edge top on compact/notched viewports. This is accepted behavior and is
withdrawn as a defect. The two parameters remain independent Flutter settings;
their current combination expresses the owner's intended layout and routing.

Reproduction: 375×600 logical pixels, top inset 59, bottom inset 34; open the
actual address editor with `includeContact: true` from a SafeArea caller.
The header starts at y=0, which is now the approved expectation. The former
diagnostic assertion requiring y>=59 was removed. The tracked regression test
`test/address/address_editor_sheet_test.dart` verifies the approved top position,
root-navigator delivery from a nested Navigator, reachable Save control, bottom
inset and dismissal without popping the underlying nested route.

### P2 — The grid ignores the existing stretchItems contract

Location: `lib/shared/widgets/app_service_grid_card.dart`, the unconditional
column-count calculation at lines 131–137.

The new layout no longer reads `stretchItems`, although the public parameter and
its callers remain. Previously a short row with `stretchItems: true` spread
its items across the card. It now reserves three/four slots regardless of the
item count, grouping a two-item row to one side and leaving unused slots.
Restore distinct stretched-row behavior, or make any intentional API/layout
change explicit with its affected consumers.

Reproduction: a centered card constrained to width 343, containing two items,
with `stretchItems: true`. Their horizontal centers are only 79.25 pixels apart;
the preceding revision spreads them 151.5 pixels apart. The regression test
compares item-center spacing, not the intrinsic width of an item.

The grid finding remains open; the modal behavior is owner-approved.
No additional actionable defect was established in app commit `3015166` or the
two package commits. Package typography/toggle changes have matching tests;
this was not a fresh visual comparison against Figma.

## Button correction implemented

The owner approved the button changes on 2026-11-08.

- Migrated 35 direct AppButton callback gates to `isActive`.
- Migrated 10 conditional submit callbacks passed through CardServiceFooter
  and DepositRequestFooter. Both now require a separate `isActive` and a
  non-null submit callback.
- Migrated 26 header gates through AppTopBar/AuthHeader and their underlying
  AppButton. Header enablement is now separate from the action callback.
- Kept operation loading on `isLoading`; secondary Auth controls keep their
  existing no-spinner behavior while disabled by another operation.
- Updated existing tests to observe enablement rather than treating a null
  public callback as the only representation of a disabled button. Existing
  repeat-tap, loading, Back, validation and navigation scenarios remain.
- Updated the contract, both project skills, architecture examples and Login
  API documentation. Shared wrappers must not conceal conditional callbacks
  in `onSubmit`, `onTrailingPressed` or `onMenu`.

Current AppChips and custom controls without an isActive/isLoading API retain
their supported callback gates. The remaining CardServiceStatus callback
conditional chooses Retry versus Home; it does not disable a button.
No Cubit, State, UseCase, repository, DI registration or banking payload changed.

## Verification

Final app checks: **321 passed, 0 failed** across the 32 explicitly selected
files; exit code 0, duration 1 minute 26 seconds. Final static analysis reported
**No issues found**. `git diff --check` passed.
Logs: `/private/tmp/pishkhan-buttons-final-tests.log` and
`/private/tmp/pishkhan-buttons-final-analysis.log`.

```sh
flutter test --no-pub \
  test/auth/presentation/flows/login/screens/auth_screen_test.dart \
  test/cards/card_services/card_service_screens_test.dart \
  test/cards/presentation/flows/card_issuance/screens/card_issuance_screen_test.dart \
  test/cards/presentation/flows/password_services/screens/second_password_screen_test.dart \
  test/cards/presentation/flows/virtual_card_request/screens/virtual_card_screen_test.dart \
  test/cheque/cheque_book_screen_test.dart \
  test/cheque/cheque_cancellation_screen_test.dart \
  test/cheque/cheque_clearance_screen_test.dart \
  test/dashboard/presentation/flows/home/screens/dashboard_screen_test.dart \
  test/deposits/agent_screen_test.dart \
  test/deposits/close_surplus_deposits_screen_test.dart \
  test/deposits/deposit_restriction_screen_test.dart \
  test/deposits/proxy_deposit_screen_test.dart \
  test/modern_banking/modern_banking_screen_test.dart \
  test/profile/personal_information_screen_test.dart \
  test/profile/presentation/flows/message_center/screens/notifications_screen_test.dart \
  test/deposits/average_balance_screen_test.dart \
  test/deposits/financial_certificate_screen_test.dart \
  test/deposits/certificate_submission_ui_test.dart \
  test/deposits/deposit_list_screen_test.dart \
  test/deposits/deposit_list_cubit_test.dart \
  test/deposits/phase_6_notifications_test.dart \
  test/transfers/on_site_transfer_screen_test.dart \
  test/requests/request_reports_screen_test.dart \
  test/postal_offices/phase_9_notifications_test.dart \
  test/shared/widgets/app_select_sheet_test.dart \
  test/shared/widgets/app_service_sheet_animation_test.dart \
  test/app_service_grid_card_test.dart \
  test/deposits/agent_settings_screen_test.dart \
  test/cards/presentation/flows/card_features/screens/card_list_screen_test.dart \
  test/flow_exit_contract_test.dart \
  test/flow_exit_navigation_test.dart
flutter analyze --no-pub
git diff --check
```

Package verification, from `../avp_ui`:

```sh
flutter test --no-pub test/widgets/app_select_sheet_test.dart test/widgets/app_select_test.dart test/widgets/app_stepper_test.dart test/widgets/app_toggle_test.dart test/widgets/app_button_test.dart
```

Result: **32 passed**. The package working tree remains unchanged.

Historical diagnostic probes, before the owner's safe-area confirmation, were
separate from the normal regression run:

```sh
flutter test --no-pub .dart_tool/last_commits_review_probe_test.dart
flutter test --no-pub .dart_tool/last_commits_review_baseline_test.dart
```

The historical first run failed twice against current code; the baseline run
using temporary copies from `HEAD~1` passed both scenarios. After confirmation,
the obsolete address-editor assertion was removed from the current diagnostic
file and replaced by the tracked approved-behavior test above. The remaining
grid probe is separate and unchanged in meaning. Diagnostic files live in
ignored `.dart_tool`; historical logs are
`/private/tmp/pishkhan-last-commits-probes.log` and
`/private/tmp/pishkhan-last-commits-baseline.log`.

Earlier runs during migration exposed callback-null assertions, including a
shared-footer assertion. These were updated to the actual enablement contract;
the affected modern-banking file then passed all 10 tests before the final run.

### Owner-confirmed modal follow-up — 2026-11-08

The address-editor test now checks the explicitly approved root-navigator and
edge-to-edge behavior. Application modal code was preserved. Verification:

```sh
flutter test --no-pub test/address test/profile/personal_information_screen_test.dart test/shared/widgets/app_select_sheet_test.dart test/shared/widgets/app_service_sheet_animation_test.dart
flutter analyze --no-pub test/address/address_editor_sheet_test.dart
git diff --check
```

Result: **26 passed, 0 failed**; analysis reported **No issues found**, and the
diff check passed. Logs: `/private/tmp/pishkhan-approved-modal-tests.log` and
`/private/tmp/pishkhan-approved-modal-analysis.log`.

No full-suite command, dependency installation, bank/device execution, package
source change or commit was performed.
