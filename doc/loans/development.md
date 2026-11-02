# Dashboard Loans development and review

Reviewed: 2026-11-01 — Cubit migration, phase 2.

LoansTab is a dashboard summary, not a standalone loan-request feature. It shares
HomeCubit/HomeState with Home, Cards and Deposits. The
[UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md) is authoritative;
[Dashboard development](../dashboard/development.md) records operation ownership,
flow readers, DI and phase validation.

## Ownership and integration

DashboardScreen owns the single BlocProvider, directly creates HomeCubit and
calls fetchDashboard. LoansTab takes only super.key. Screen/tab constructors do
not accept repositories, loan callbacks or dependency replacement parameters.
GetIt registers dependencies, never Cubits.

DI wires `LoadDashboardItemsUseCase<BankLoan>` to the existing dashboard loan
repository through the registered bundle. HomeCubit resolves that UseCase in a
final field; fetchLoans owns its loading emit, await and Result switch. It does
not construct a UseCase or pass a Repository. MockDashboardLoansRepository and
DashboardMockData still supply data; no loan API or payment is connected.

## User path and State

| Event | Behavior retained |
| --- | --- |
| Initial entry / retry | fetchLoans sets loansStatus loading before the Future; previous list/selection/actions are invalidated for the loading view. |
| Successful response | Reconcile prior selection by stable ID, otherwise first remaining item; update list, selected entity/index and action lists together. |
| Reorder / selected removal | Preserve a surviving selected loan; removal falls back to first item; empty input has no selected loan or operations. |
| Select carousel item | Pass the rendered BankLoan to selectLoan; Cubit records it and its index. |
| Operation / quick action | Cubit constructs LoanActionRequest from selected BankLoan; listener executes the prepared intent through the existing navigation adapter. |
| Copy / details | Copy effect carries the original loan number; details effect carries that BankLoan. Existing unavailable details feedback remains. |
| Failure / retry | Publish loansStatus failure, shared failure and prepared message; a status-transition listener notifies. Retry calls the same owner. |
| Switch tab / Back | Selection survives tab changes; Back returns to Dashboard. Pending requests gate Back in UI. |

Loan selection/index and availability use pure calculations shared with the other
banking tabs. Each action publishes its own explicit State changes. UI controls
whether an action can be invoked; no repeated Cubit guards, request-ID counters,
closed checks or generic State publisher are added.

The carousel owns its PageController, synchronization and safe post-frame
attachment behavior. These Flutter resources remain outside Cubit/State.

## Rendering and reference frames

| Frame | Figma node | Native card size |
| --- | --- | --- |
| Single loan | `27902:82623` | 335 × 236 |
| Multiple loans | `27902:82592` | 316 × 236 |

Reference file: nYQNyZdSs98lwymCpt5Sag. The existing RTL snapping carousel,
neighbor previews, indicators, four operation items and two quick actions are
retained. AppLoanCard, AppArrowButton, avp_ui AppProgressIndicator, AppTopBar,
service grids/artwork, assistant and primary navigation remain the shared visuals.
App-owned artwork uses AppConstants.baseImage; UI localization uses S.current.

BankLoan retains numeric paid/total counts. Its existing progress and installment
label derive from those counts; zero totals return zero progress. Fixtures use
40% for single and 30%/70%/90% for multiple loans. This refactor changes no amounts,
counts, formatting or progress policy. Live money/date mapping remains dependent
on a confirmed bank contract.

Historical shadow/header/arrow/navigation and large-text differences remain in
[Dashboard Section 13.6](../dashboard/development.md#136-loans--shared-component-comparison-and-retained-differences).
They were not corrected or freshly compared to Figma in this Cubit phase.

## Verification

Tests under test/dashboard/presentation/flows/banking_overview and the Home Cubit
suites cover retained selection, reorder/removal, empty/error/retry, immutable
snapshots, concurrent operations, context in action effects, copy/details,
carousel behavior, Back, small screens and text scale. Numeric progress tests
remain under test/dashboard/domain/entities. Dashboard development records the
commands/results; historical 119-app/102-package totals are not current claims.
