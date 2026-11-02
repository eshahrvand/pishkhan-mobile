# Phase 10 — Integrated Cubit and documentation review

Scope: the owner's ten-phase migration of all 31 current Cubits, integration
boundaries, and final documentation alignment. Contract v1.23 remains authoritative;
this phase adds no new coding rules. Phase 9 was committed in `322db5c` first.
Only related tests may run; a full-application test run still requires a separate
explicit owner request.

## Coverage and operation inventory

The inventory below accounts for every current `*_cubit.dart` and its existing
plain Freezed State. Counts describe awaited dependency-operation owners in Cubit,
not every internal Repository request. For example, surplus closure delegates
its reviewed/retryable fetch-and-submit operation to its existing application
UseCase. Local entry resolution and inbox selection are not fake API operations.

| Phase | Cubit | Request owners | Flow review |
|---|---|---:|---|
| 1 | AuthCubit | 3 | CAPTCHA, OTP challenge/countdown and login; inline guest-phone notice |
| 2 | HomeCubit | 4 | Four retained tabs; selection, favorites, search, independent results/effects |
| 3 | CardFeaturesCubit | 1 | Card catalog, draft filters and category reveal |
| 3 | VirtualCardCubit | 3 | Catalog, overlapping quote and stable submit retry |
| 4 | CardIssuanceCubit | 2 | Catalog, delivery/recipient form and confirmed submission |
| 4 | ChangeCardDepositCubit | 2 | Catalog, source/target binding and submission |
| 4 | ExpiredGiftBalanceCubit | 2 | Catalog, hidden selection/review and transfer request |
| 4 | SecondPasswordCubit | 3 | Catalog, existing request and setup/change/recovery submission |
| 5 | AddressEditorCubit | 0 | Optional entry-address resolution and explicit address validation |
| 5 | AddressesCubit | 4 | List, save, delete and independent per-address reviews |
| 5 | JobInformationCubit | 3 | List, save and deletion; approved team terminology |
| 5 | ChangePhoneCubit | 3 | Settings, OTP and confirmed phone change |
| 5 | NotificationsCubit | 0 | Supplied inbox, read/unread calculations and detail command |
| 6 | DepositListCubit | 1 | Deposits, search, details and prepared service destinations |
| 6 | DepositRestrictionCubit | 2 | Catalog, ordered reasons/consent and submission |
| 6 | CloseSurplusDepositsCubit | 2 | Primary deposits and the flow-owned closure UseCase |
| 6 | ProxyDepositCubit | 2 | Catalog, typed purpose/consent and submission |
| 7 | AverageBalanceCubit | 2 | Catalog and exact confirmed certificate request |
| 7 | FinancialCertificateCubit | 2 | Catalog and conditional certificate/recipient/translation request |
| 7 | AgentCubit | 2 | Deposits, agent drafts and confirmed submission |
| 7 | AgentSettingsCubit | 1 | Catalog, draft filters, selection and details |
| 8 | MobileBankCubit | 2 | Independent activation/recovery record and identity submission |
| 8 | MobileBankGuideCubit | 0 | Actual page selection and typed controller/navigation effects |
| 8 | TransferLimitsCubit | 2 | Catalog, own-field validation and limit submission |
| 8 | MobileBankDeactivationCubit | 2 | Catalog, reason/consent and submission |
| 8 | OnSiteTransferCubit | 4 | Catalog, destination, upload and confirmed transfer |
| 8 | RequestReportsCubit | 2 | Reports/filter drafts and bound cancellation |
| 9 | PostalOfficesCubit | 2 | Provinces, offices and prepared share content |
| 9 | ChequeClearanceCubit | 2 | Catalog, inline not-found distinction and submission |
| 9 | ChequeCancellationCubit | 3 | Catalog, overlapping list and confirmed cancellation |
| 9 | ChequeBookCubit | 6 | Catalog, residency, deletion, save, quote and issuance |

Total: **31 Cubits, 69 request owners, 39 consumed UseCase class types**.
Generic typed and named DI registrations retain their actual distinct bindings.

## Findings before final corrections

- README still described a starter app, directed agents to an unconditional
  full test run, and named architecture Section 12 instead of the authoritative
  UI/Cubit/State contract.
- Main-app integration examples still prescribed mutable State/setState,
  Screen repository arguments, per-tab Cubits and runtime adapter replacement.
  Its virtual-card and synchronous-login examples were also stale.
- The UI skill still contained foreign component/API names, `.then` refresh
  orchestration, build-time analytics and incompatible Consumer/State guidance.
  It needs alignment to the existing contract, without introducing a new style.
- Home's three typed instances of `LoadDashboardItemsUseCase<T>` used abbreviated
  subject names rather than retaining the class name in their field names.
  Correct those references while keeping their generic types and DI bindings.

The source scan found no Cubit `.then`, catchError/try-catch, isClosed, private
GetIt dependency fields, Cubit registrations, handwritten State getters, or
Screen-level Consumers. Remaining local Consumers have actual controller/modal
ownership. The dashboard banner's image-texture notifier is Flutter resource
storage, not a second copy of flow selection/visibility/error State.

## Corrections and final integration review

- README now points first to the mandatory UI/Cubit/State contract, explains
  dependency/code-generation setup and scoped testing, and links the flow docs
  including cheque/postal and agent introduction.
- Replaced the stale UI skill's foreign examples with a focused checklist of
  the existing contract: actual Provider/DI ownership, explicit forms, local
  Consumer boundaries, status-driven feedback, typed effects, Flutter resource
  ownership, S.current and current avp_ui conventions. No new style rule or
  production abstraction was added.
- Main-app integration examples now forward typed actions instead of mutating
  State/setState. Dashboard and virtual-card examples use the current public
  Screen APIs and DI boundary. The real asynchronous login flow replaces the
  old synchronous example. Package-work examples no longer imply permission to
  edit the sibling package or execute a full consuming-app test suite.
- Home's three generic dependency fields are now
  `loadDashboardItemsUseCaseForCards`, `loadDashboardItemsUseCaseForDeposits` and
  `loadDashboardItemsUseCaseForLoans`. The complete class name remains visible;
  the subject distinguishes the existing typed instances. Only those fields and
  their calls were renamed: no statement order, request, Result switch, emit,
  generic type, registration or listener changed.
- Architecture and coding-contract adoption notes now link current migration
  status. Historical phase counts remain dated evidence. The former v1.7 async
  changelog is explicitly labelled superseded. Contract v1.23's rules are
  unchanged; no new architecture, layer, dependency or widget is introduced.

The integrated source review checked all 31 Cubit/State pairs against the
inventory, final dependency lookup, class/file suffixes, actual DI registrations,
request-owner call sites, explicit Result handling and plain State structure.
There is one owner for each of the 69 requests. Named and generic registrations
retain their existing identities; the surplus-closure UseCase remains a factory
because it owns a flow's pending reviewed request. No Cubit is registered.
Screen/flow entry remains directly Provider-owned; routers only select feature
destinations. RouterSession's access-token-store lookup is the existing router
infrastructure responsibility, not feature dependency forwarding.

Reviewed notification consumers with their actual responsibility: independent
screen operations use focused listeners; remaining Consumers belong to local
carousels, filters, sheets or content scrolling. No message-first effect handler
remains. Auth's two explicit error clears remain for its documented guest-phone
inline notice, not request notification delivery. Real form/snapshot/quote resets
and request-overlap safeguards remain in their existing owners.

## Verification — 2026-11-02

Initial integration check: **25 tests passed** for DI, router and implemented
service navigation. Whole-project static analysis reported no issues. After the
Home field correction, the final related run passed **111 tests**:

```sh
flutter test test/dashboard/presentation test/core/di test/core/router test/dashboard/implemented_services_navigation_test.dart test/dashboard/modern_banking_drawer_test.dart
```

This covers Home and its retained-tab/UI consumers plus the changed dependency
boundary's integration regressions. The 25-test run is a subset, not another 25
distinct tests to add to 111. Prior phases' scoped results remain in their own
reports; they are not presented as a fresh full-suite result.

Final whole-project static analysis:

```sh
flutter analyze
```

Result: **No issues found**. `git diff --check` and edited README/guide/skill/report
relative-link target checks passed. The UI skill's YAML/frontmatter/scaffold was
checked with Ruby YAML. The skill-creator `quick_validate.py` was attempted but
cannot run in the available Python environment because PyYAML is absent; no
dependency was installed for that checker. The fallback parses real YAML and
checks required metadata/name/description and unfinished placeholders.

Final duplication/flow review: this phase changes no request lifecycle or emit.
No new repeated calculation was introduced and no clear was removed. Earlier
phase reports retain their own duplication and clear-removal counts.

No full-application test suite, build, device execution, new dependency or
design-system mutation was performed. Native/bank integration limits remain
those documented per flow. Full-app execution/testing still awaits an explicit
owner request. This scoped verification does not claim a full-suite run.

The owner approved phase 10 and requested its commit, followed by one full-project
test run. The scoped results above precede that separately authorized full run.

Duplication review: 0 new repeated blocks found, 0 required resolution (existing
request owners preserved). Flow review: 0 clears removed.

## Owner-authorized full-project run after phase-10 commit

The owner explicitly requested one complete test run after committing phase 10.
Implementation/documentation was committed in `8521885` before this invocation:

```sh
flutter test
```

Result: **780 passed, 0 failed, 1 skipped**, exit code 0, reported duration
**3 minutes 27 seconds**. The skipped test is
`test/core/security/access_token_store_web_test.dart`, which declares
`skip: !kIsWeb`; this normal Flutter test invocation does not execute its
browser-specific case. The complete suite was invoked once; no retry was needed.
The local run log is `/private/tmp/pishkhan-post-migration-full-tests.log`.

This subsequent run supersedes the earlier pending-full-run status above; it
does not convert this one authorization into permission for future full-suite
runs. All ten planned phases are owner-approved. No further phase is planned.
