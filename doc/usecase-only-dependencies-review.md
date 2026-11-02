# UseCase-only Cubit dependency migration

The owner explicitly requires Cubit → UseCase → Repository for every
application/data operation. Contract v1.24 withdraws the previous optional-
UseCase exception. Documentation/skills are updated before application code.
Pure local form/selection/calculation actions need no artificial UseCase.

## Inventory and preservation map before implementation

| Cubit | Existing operation(s) to move | Existing consumers / behavior to preserve |
|---|---|---|
| VirtualCard | submit | Confirmed quote, private submitted snapshot, retry key, terminal status/navigation |
| ChangeCardDeposit | changeDeposit | Exact source/target/card/key and existing boundary/receipt |
| ExpiredGiftBalance | transferGiftBalance | Selected cards/destination/key and review/receipt |
| AverageBalance | submitAverageBalance | Same confirmed request instance and retry identity |
| FinancialCertificate | submitFinancialCertificate | Same conditional request, binding and retry identity |
| MobileBank | submitIdentity | Operation-specific activation/recovery payload and receipt |
| TransferLimits | submitTransferLimits | Same parsed amounts/deposit/key and success body |
| MobileBankDeactivation | submitDeactivation | Same selected reason/username/key and receipt |
| OnSiteTransfer | fetchCatalog, resolveDestination, submit | Entry deposit resolution, destination request ID, confirmed snapshot/key; upload already uses a UseCase |
| RequestReports | fetchReports, cancelRequest | Bank-time filtering, selected report/key and modal completion |
| Addresses | fetchAddresses, saveAddress, deleteAddress, reviewAddress | Minimum home/address policy, per-address statuses and concurrent reviews |
| ChangePhone | fetchPhoneSettings, requestPhoneOtp, changePhone | Challenge/countdown/consent/key, secret reset and server result |
| JobInformation | fetchJobInformation, saveJobInformation, deleteJobInformation | Form validation, job conflict/operator review and retry identity |

Scope: 13 Cubits, 23 direct Repository call sites. Keep each existing Cubit
operation's loading, request construction, Result switch and explicit emits;
replace only the dependency call with its registered operation UseCase. Each
UseCase preserves its exact Repository arguments and maps unexpected exceptions
to the existing UnexpectedFailure. Existing Domain boundary functions stay
inside Domain; Cubit no longer supplies Repository callbacks to them.

Review all 31 Cubits after migration, including Repository imports and GetIt
lookups. Keep Repository contracts/adapters in Domain/Data and their DI wiring;
they are removed from Cubit, not from the application architecture.

## Implementation and naming

Added 23 specific stateless UseCases and registered them as factories in core/di.
Each Cubit resolves the complete lowerCamelCase class name in a final field.
Existing Repository lifetimes remain; each factory receives its registered
Repository. Named certificate catalogs and existing upload/catalog UseCases
retain their bindings. Domain has no GetIt or Flutter dependency.

| Grouped UseCase file | Added classes |
|---|---|
| cards/virtual_card_request_usecase.dart | SubmitVirtualCardsUseCase |
| cards/card_services_usecase.dart | SubmitCardDepositChangeUseCase, TransferGiftBalanceUseCase |
| deposits/average_balance_usecase.dart | SubmitAverageBalanceUseCase |
| deposits/financial_certificate_usecase.dart | SubmitFinancialCertificateUseCase |
| modern_banking/mobile_bank_usecase.dart | SubmitMobileBankIdentityUseCase, SubmitTransferLimitsUseCase, SubmitMobileBankDeactivationUseCase |
| transfers/on_site_transfer_usecase.dart | FetchOnSiteTransferCatalogUseCase, ResolveTransferDestinationUseCase, SubmitOnSiteTransferUseCase |
| requests/request_reports_usecase.dart | FetchRequestReportsUseCase, CancelReportedRequestUseCase |
| profile/personal_information_usecase.dart | FetchProfileAddressesUseCase, SaveProfileAddressUseCase, DeleteProfileAddressUseCase, ReviewProfileAddressUseCase, FetchPhoneSettingsUseCase, RequestPhoneChangeOtpUseCase, ChangePhoneUseCase, FetchJobInformationUseCase, SaveJobInformationUseCase, DeleteJobInformationUseCase |

The new classes forward the exact same typed request/arguments and Result. They
do not revalidate forms, generate keys, calculate eligibility, fetch extra data
or change request order. Their boundary maps unexpected synchronous/asynchronous
exceptions to the existing UnexpectedFailure, keeping Cubit free of catch logic.
Expected Repository Err results pass through unchanged. Former Cubit-side
boundary callbacks were removed from the five affected submit operations;
their exception behavior is now inside each UseCase.

## Documentation-first and final review

Updated the authoritative contract to v1.24, architecture, root AGENTS.md, both
project skills, README and the affected flow documents before code migration.
Removed the optional-UseCase exception and corrected direct-Repository examples.
Historical phase-4/5/7/8/10 reports explicitly mark their earlier decisions as
superseded, rather than presenting them as permission for new code.

Final source review covers all 31 Cubits:

- Zero Repository imports, fields, GetIt lookups or direct Repository calls.
- Every new UseCase has the required class/file suffix and DI registration.
  Consumed UseCase class types increase from 39 to 62; request-owner count stays
  69. Pure local actions and the existing plain Freezed States remain unchanged.
- Each changed operation keeps one awaited call and one Result switch. No
  request/publication helper, defensive guard or extra validation was added.
- The complete emit expressions in all 13 migrated Cubits were compared with
  the prior committed source and are unchanged, including loading, failure,
  success, prepared effects and actual consumer-driven resets. Request keys,
  confirmed snapshots and real request IDs retain their owners.
- No UI rendering, controller/modal lifecycle, routing, repository implementation
  or banking payload was changed. Tests install repository replacements in the
  composition root before constructing the Cubit/UseCase dependency graph.

## Scoped verification

```sh
flutter test test/cards/card_services test/cards/presentation/flows/virtual_card_request test/deposits/average_balance_cubit_test.dart test/deposits/average_balance_screen_test.dart test/deposits/financial_certificate_cubit_test.dart test/deposits/financial_certificate_screen_test.dart test/deposits/certificate_navigation_test.dart test/deposits/certificate_submission_ui_test.dart test/deposits/phase_7_notifications_test.dart test/profile/personal_information_cubit_test.dart test/profile/personal_information_screen_test.dart test/modern_banking test/transfers test/requests test/core/di test/core/router test/dashboard/implemented_services_navigation_test.dart
```

Final result: **234 passed, 0 failed**. Coverage retains form validity, request
payloads/keys, repeated failure, retry-success, typed effects after errors,
overlapping destination/upload/review responses and late modal completion.
Two new boundary regressions verify an unexpected async profile error and sync
report error produce terminal failure and recover through the same request owner.

The initial run passed 231 tests and failed one report-modal test because that
test reset GetIt mid-test without restoring UseCase registrations. Its setup now
restores the composition root before replacing the repository. An initial
analysis warning for a duplicate import was also corrected. Neither fix changes
application behavior.

```sh
flutter analyze lib/features/cards lib/features/deposits lib/features/profile lib/features/modern_banking lib/features/transfers lib/features/requests lib/core/di/injection_container.dart test/cards/card_services test/cards/presentation/flows/virtual_card_request test/deposits test/profile test/modern_banking test/transfers test/requests test/core/di
```

Result: **No issues found**. Final diff checks and skill YAML/frontmatter checks
also passed. No full-application test run, code generation, dependency install,
design-system change or device/bank execution was performed for this follow-up.
The owner's earlier one-time full-suite authorization does not authorize a new
full run here. The owner approved these changes and requested their commit.

Duplication review: 0 new repeated request lifecycles found, 0 required
delegation changes (23 existing owners now invoke specific UseCases).
Flow review: 0 clears removed; all existing emits preserved.
