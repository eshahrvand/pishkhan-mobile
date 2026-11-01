# Phase 5 — Address editor and profile review

Implemented under [contract v1.22](../ui-cubit-state-agent-rules-en.md), the
[clean-code skill](../../.agents/skills/pishkhan-cubit-clean-code/SKILL.md) and
[current flow document](personal-information.md). Phase 4 was committed in
`fb0dea1` before starting this phase. Phase 6 has not started.

## Operation ownership

| Cubit | Operation / owner | Actual trigger |
|---|---|---|
| Addresses | fetch / `fetchAddresses` | Provider entry, existing retry |
| Addresses | save / `applyAddressEditor` | Raw optional editor result; Cubit applies the home-address invariant |
| Addresses | delete / `submitDeletion` | Confirmation button with the selected record |
| Addresses | residence inquiry / `submitAddressReview` | Review for the rendered home-address record |
| Job information | fetch / `fetchJobInformation` | Provider entry, existing retry |
| Job information | submit / `submitJobInformation` | Valid authored form with consent |
| Job information | delete / `submitDeletion` | Confirmation button with the selected record |
| Change phone | settings / `fetchSettings` | Provider entry, existing retry |
| Change phone | challenge / `submitOtpRequest` | Request/resend button |
| Change phone | submit / `submitPhoneChange` | Valid code, consent and wallet gate |

Each operation retains one loading emit, dependency call, await and Result switch.
No request is copied into trigger methods. Existing request arguments and retry
identity remain unchanged. `PersonalInformationRepository` is already registered
and resolved in final Cubit fields. No existing UseCase needs renaming/wiring in
these flows; no speculative UseCase layer, Cubit registration or dependency
constructor forwarding was introduced. Adapter exceptions already become `Err`.

`AddressEditorCubit` resolves optional initial address data, validates only the
edited field and produces `DeliveryAddress`; it has no request. A new form keeps
the initial snapshot without a default re-emit. `NotificationsCubit` resolves its
incoming inbox, groups read/unread messages, marks messages read and prepares
detail navigation; it has no API operation or dependency.

## Flow and reader review

| Step | Readers and next action | Retained data / reset reason |
|---|---|---|
| Address list | List reads addresses, mutation statuses and each review status; review/add/edit/delete remain independent | Each inquiry changes its own status; response updates only the unchanged address snapshot. Other records retain results |
| Address editor | Inputs read prefill/draft and stored validity; Save returns address, Cancel returns null | Draft survives minimum-home notice; last home cannot become work. New-address action clears selection/constraint for this actual new form |
| Address confirmation | Prepared selected record and localized labels; Confirm submits, dismissal does nothing | Only accepted modal result mutates data; editing preserves ID and resets residence inquiry through the existing repository |
| Phone form | Inputs, challenge, countdown, consent, wallet and submit/resend gates | Editing phone invalidates challenge/code/time/key; changing payload invalidates retry identity. Resend resets code for the new challenge |
| Phone result | Failure allows retry; success shows existing acknowledgement and then returns home | Timer cancellation and successful OTP secret purge remain. Success disables duplicate submit while acknowledgement is visible |
| Job information list/form | Approved list, selected record, kind, description, consent, conflict/operator-review flags | New/edit actions deliberately reset form consent/errors/key/status. Draft survives terms and exit cancellation; successful request does not rewrite approved jobs |
| Job information result | Queued acknowledgement, then original approved list | Success disables duplicate submit; deletion changes only the confirmed record |
| Inbox/detail | Header reads unread emptiness; list owns messages subscription; prepared detail navigates | Read status persists on Back, onChanged receives an immutable snapshot, actual external inbox replacement remains supported. Detail command is consumed once |

**Owner-approved behavior correction:** the old address screen allowed Back
while an inquiry was loading. The owner explicitly chose Section 20.2: both
system and top-bar Back now wait until *all* entries in `reviewStatuses` leave
loading. Fetch/save/delete gates remain. There is no redundant Cubit loading
guard or new request identity. Other route, modal, draft and request behavior is
preserved.

## Notification and composition review

Every failure publishes its operation status, Failure and prepared message
atomically. Fifty-one blanket null assignments were removed: addresses 15,
phone 16, jobs 20. These count individual `failure`/`message` assignments,
not emit blocks. No other data/secret/form resets were removed.

Each screen groups focused failure listeners separately from its typed-effect
listener in `MultiBlocListener`, with `BlocBuilder` rendering. Address inquiries
observe entering failure per address ID, so one old failure cannot replay on a
different review result. Effect handlers do not branch on the retained message.
Phone/job acknowledgements display their own localized success messages
through a public shared dialog widget with the existing layout and dismissal.
The editor separates notice execution from modal completion; inbox separates
detail navigation from parent inbox-change delivery. Controller ownership,
subscription predicates and modal-result interpretation remain at their existing
boundaries. The redundant nested address-footer builder was removed; it reads the
same current screen snapshot.

## Duplication review

Eight repeated calculations/predicates were consolidated into pure helpers:
address completeness; saved-address ID match; inquiry-result list update; phone
submit eligibility; phone resend eligibility; job submit eligibility;
job group difference; inbox partitioning (read/unread filters as one
calculation group). Explicit emits for independent events remain. The ten request
lifecycles already had distinct owners and retain them; no publication helpers,
State logic, counters, disposal guards or default reinitialization were added.

## Scoped verification

Baseline before migration: `flutter test test/address test/profile` — 35 passed.
Final commands/results are recorded below after verification. Full-application
tests are not run under the owner's scoped-test instruction.

```sh
flutter test test/address test/profile test/deposits/average_balance_screen_test.dart test/deposits/financial_certificate_screen_test.dart test/cheque/cheque_book_screen_test.dart test/transfers/on_site_transfer_screen_test.dart
flutter analyze lib/features/address lib/features/profile test/address test/profile
```

Results: **86 tests passed**, scoped analysis **no issues**; `git diff --check`
passed. The four additional files exercise direct shared-editor consumers;
no later-phase Cubit was rewritten. Existing SVG renderer warnings about
`foreignObject`/`filter` remain and did not fail the checks.

New behavioral coverage verifies that both Back paths stay blocked through two
concurrent inquiries and become available after the final completion; address
commands still open after an error without replaying it; phone and job
identical failures notify again, terms effects still execute, and retry-success
shows the success acknowledgement without an old failure notification. Job information
retry identity and the unchanged approved list are asserted. The old retry test
now asserts retention of the latest failure/message rather than legacy nulling.
Existing tests cover validation, expiry, charging, address-editor cancellation and
minimum-home notices, inbox detail/read status and external inbox replacement.

Duplication review: 8 repeated calculation groups found, 8 resolved. Flow review:
51 blanket failure/message clears removed; real form, challenge, secret and
interaction resets preserved. Phase 5 awaits owner review before phase 6.

## Owner-requested naming update — JobInformation

The owner prefers the team's familiar `job` vocabulary. Renamed the feature to
`JobInformationCubit` / `JobInformationState` / `JobInformationScreen`, under
`presentation/job_information`; domain types, repository actions, widgets,
localization keys, imports, router constant and dashboard enum reference the same
name. Generated localization and Freezed output were rebuilt. Existing route URL,
service ID, asset references, widget keys, error codes, retry-key prefix and all
translated text retain their values. No new behavior or architectural rule was
introduced. The previous phase-5 implementation changes remain intact.

Verification for this naming update:

```sh
flutter test test/profile test/app_profile_activity_cards_test.dart test/core/router/app_router_test.dart test/dashboard/implemented_services_navigation_test.dart test/dashboard/presentation/flows/home/cubit/home_service_picker_test.dart test/app_service_grid_card_test.dart
flutter analyze lib/features/profile lib/features/dashboard/presentation/shared/dashboard_services.dart lib/shared/widgets/app_job_information_card.dart lib/shared/widgets/app_job_information_card_detail_row.dart lib/core/router lib/core/flow/service_registry.dart test/profile test/app_profile_activity_cards_test.dart test/core/router/app_router_test.dart
```

**57 related tests passed; analysis found no issues; diff check passed.**
Comparison against the pre-rename working files confirms the same application
code token structure after name/import substitution and identical literal
values in all 19 affected non-generated application files. All three ARB files
preserve their translation and placeholder payloads; only message keys change.
The initial build-filter run removed other cached generated outputs; rebuilding
those outputs restored compilation before these successful final checks.
Duplication review: 0 new repeated blocks introduced. Flow review: 0 additional
clears removed by the naming-only update.
