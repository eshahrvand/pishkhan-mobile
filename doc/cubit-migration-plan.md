# Cubit migration plan

Owner-approved ten-phase plan for the 31 existing Cubits. Recovered from the
owner’s supplied plan on 2026-11-01. The next phase starts only after the owner
reviews and approves the current result. This plan adds no coding rules.

Use the current [UI/Cubit/State contract](ui-cubit-state-agent-rules-en.md),
[architecture](architecture-smart-virtual-counter-v2-en.md) and
[clean-code skill](../.agents/skills/pishkhan-cubit-clean-code/SKILL.md).
Preserve user behavior, step order, requests/payloads, validation, retry identity,
selections, navigation and retained flow data. UseCase class/file suffixes, GetIt
registration and status-driven notifications apply in each authorized phase.
Any proposal outside approved rules requires separate owner approval.

| Phase | Cubits / scope | Flow documents | Status |
|---|---|---|---|
| 1 | AuthCubit | login/development.md; auth/login-api-integration.md | Reviewed; committed in 197b4e5; notification follow-up in 3fb09b1 |
| 2 | HomeCubit and four tabs | dashboard/development.md; cards/my-cards.md; loans/development.md | Reviewed; committed in 645433a; notification follow-up in 3fb09b1 |
| 3 | CardFeaturesCubit; VirtualCardCubit | cards/card-services.md; cards/virtual-card-request.md | Reviewed/approved; 56 focused tests and 750 full-suite tests passed (1 Web-only skip); v1.21 follow-up passed 385 tests; committed in 5092e02 |
| 4 | CardIssuanceCubit; ChangeCardDepositCubit; ExpiredGiftBalanceCubit; SecondPasswordCubit | Corresponding doc/cards/ flow documents | Implemented under v1.21; 200 focused / 754 full-suite tests passed (1 Web-only skip), clean analysis; reviewed/approved; committed in fb0dea1; see cards/phase-4-review.md |
| 5 | AddressEditorCubit; AddressesCubit; JobInformationCubit; ChangePhoneCubit; NotificationsCubit | profile/personal-information.md and address-consumer references | Implemented under v1.22; 86 related tests passed; JobInformation naming follow-up: 57 related tests, clean scoped analysis; committed in 85e74cf; see profile/phase-5-review.md; owner-approved |
| 6 | DepositListCubit; DepositRestrictionCubit; CloseSurplusDepositsCubit; ProxyDepositCubit | deposits/development.md and corresponding flow docs | Implemented under v1.23; 88 phase tests / 126 naming-follow-up tests passed, scoped analysis clean; committed in ab7e274; see deposits/phase-6-review.md; owner-approved |
| 7 | AverageBalanceCubit; FinancialCertificateCubit; AgentCubit; AgentSettingsCubit | Average balance, financial certificate, agent and agent-settings docs | Implemented under v1.23; 102 related tests passed, scoped analysis clean; see deposits/phase-7-review.md; awaiting owner review |
| 8 | MobileBankCubit; MobileBankGuideCubit; TransferLimitsCubit; MobileBankDeactivationCubit; OnSiteTransferCubit; RequestReportsCubit, in this order | modern-banking/mobile-bank.md; transfers/on-site-transfer.md; requests/request-reports.md | Not started |
| 9 | PostalOfficesCubit, then ChequeClearanceCubit; ChequeCancellationCubit; ChequeBookCubit | Postal offices and cheque module/flow docs | Not started |
| 10 | Review all 31 Cubits; integration checks and final documentation alignment | Flow docs, README and outdated guide sections | Not started |

For every phase: inventory operations/triggers; map the user path, readers and
Back behavior; refactor owners and call sites; rewrite current flow documentation;
run relevant behavioral checks and analysis; review duplication and flow-aware
emits; report results and stop for owner review. Record existing problems
separately from migration regressions. Do not invent exceptions when behavior
and a mandatory rule conflict: report the exact location/rules and continue
independent authorized work.

## Approved listener-composition follow-up (phases 1–3)

Contract v1.21 requires independent screen/flow listeners to share
MultiBlocListener with BlocBuilder rendering at that boundary. Login and
Dashboard already comply. Card list and Virtual Card screens are recomposed;
focused local Consumers for controller/modal effects remain at their actual
owner. Preserve all predicates, command consumption, lifecycle and behavior.
The composition follow-up passed 385 relevant tests. See its current verification in
[cards/virtual-card-request.md](cards/virtual-card-request.md#listener-composition-follow-up-verification).

## Owner update — test scope

From phase 5 onward, run changed-flow tests and directly related regression
files only. Full-application testing waits for an explicit owner request; do not
run unscoped `flutter test` automatically. Preserve historical full-suite counts
as dated evidence and report the actual scoped checks for each new phase.
