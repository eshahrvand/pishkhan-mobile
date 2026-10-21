# Deposits: implemented flows and integration

Updated: 2026-10-19. This is the entry document for the deposit module. It describes
implemented application flows and mock adapters. Bank APIs, real account operations,
document issuance and payments remain integration work.

The mandatory [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md),
including its owner amendments, governs new and modified presentation code.

## Services and navigation

| Service | ID | Route | Detailed contract |
| --- | --- | --- | --- |
| My deposits | `deposit-list` | `/deposits/list` | [Deposit list](deposit-list.md) |
| Statement / average balance | `deposit-statement` | `/deposits/average-balance` | [Average balance](average-balance.md) |
| Financial certificate | `deposit-certificate` | `/deposits/financial-certificate` | [Financial certificate](financial-certificate.md) |
| Introduce agent | `deposit-representative` | `/deposits/introduce-representative` | [Introduce agent](introduce-agent.md) |
| Agent settings | `deposit-representation-settings` | `/deposits/representation-settings` | [Agent settings](agent-settings.md) |
| Block / unblock | `deposit-block`, `deposit-unblock` | `/deposits/block`, `/deposits/unblock` | [Restrictions](deposit-restriction.md) |
| Close surplus deposits | `deposit-close-extras` | `/deposits/close-surplus-deposits` | [Surplus deposits](close-surplus-deposits.md) |
| Proxy deposit | `deposit-proxy` | `/deposits/proxy` | [Proxy deposit](proxy-deposit.md) |

Paths and typed arguments live in `core/router`; `ServiceRegistry.openCardService`
dispatches existing IDs. Supported deposit actions forward the selected account
number; the destination Cubit resolves it against the fetched service catalog.
Cheque services belong to [the cheque module](../cheque/development.md), including
when opened from a deposit. A visible catalog icon alone does not mean its service
is implemented.

## Ownership

The retained Deposits tab, `BankDeposit` summaries and dashboard action mapping
belong to `features/dashboard`. All four dashboard tabs share the `HomeCubit`
owned by `DashboardScreen`. Standalone services and their domain/data code belong
to `features/deposits`. The single card and RTL multi-account carousel retain
selected-account context. Cheque visibility follows account capability data.
The opening-date label is right-aligned with the number and IBAN labels in both
card variants.

Each standalone screen directly constructs its Cubit in `BlocProvider.create`
and calls its required initial fetch. GetIt registers actual dependencies, never
Cubits. Cubit resolves its repository in a field; UI/router do not forward data
dependencies through constructors. State remains one plain Freezed `.initial`
data class with independent operation statuses. Cubit owns decisions, validation
outcomes, dependent selections, request construction and modal-result interpretation;
UI renders and executes prepared Flutter effects.

## Current behavior

- Deposit list: search/filter, account and owner details, supported service actions.
- Average balance: account/conditions, delivery, confirmation/fees. Dates remain
  optional until the approved calendar picker is available.
- Financial certificate: five stages, including recipient/currency and Latin
  identity before delivery and fee confirmation.
- Agent introduction: a local pending list followed by final submission. Settings:
  two relationship tabs, draft filters and details; cancellation still shows
  unavailable feedback.
- Block/unblock: operation-specific eligibility, previous blocking information,
  consent and wallet/fee requirements.
- Proxy deposit: company/subject/account dependencies and service-provided broker
  and amount; changing a selection resets dependent data and consent.
- Surplus closure: more than one deposit shows the primary selector; zero or one
  shows the empty result. All other accounts automatically become surplus.
  There is no experimental intermediate candidate-list page.

Current DI selects mock repositories. Their in-memory changes are local to each
adapter: surplus closure does not mutate the independent dashboard or generic
list fixture. Production consistency must come from bank data.

## Address feature and component reuse

`features/address/presentation/editor` owns the address form, Cubit and State.
Average balance, financial certificates and cheque-book delivery call
`ServiceRegistry.openAddressEditor`; their own Cubits interpret the raw result.
Core `DeliveryAddress` is the common result type; `CertificateAddress` remains a
compatibility alias. Callers do not import another feature's internal editor.

The editor collects an address. It does not implement persistent profile address
management or registry verification. Local delivery changes last for the flow's
lifetime unless a repository explicitly persists them.

Existing selectors, fields, recipient/agent sections, summary, invoice, cards,
headers, assistant, exit dialog and blurred sheet frame are reused. Common
certificate visuals live in `lib/shared/widgets`; stateful address editing stays
in its own feature. All interactive selects keep their field visuals and open
the shared avp_ui selection bottom sheet through AppSelect’s package-owned default behavior. The
shared CertificateSelect supplies this behavior to deposit flows, profile/address
forms, transfers and modern banking.

## Integration limits

Catalogs provide eligibility, options and tariffs. Confirmed payloads retain their
identity across retries. Mock boundaries check service-specific ownership,
quote/review binding and idempotency. Real authorization, atomic account/payment
execution and durable deduplication remain server responsibilities. Receipts
explicitly identify simulated operations.

Official terms, agent enquiries, persistent profile address management, real
certificates and delivery remain unavailable where the detailed flow document
says so. Missing content shows availability feedback rather than a fabricated
legal document or bank success.

## Verification

Tests are under `test/deposits`, `test/address`, shared-card and router suites:

```sh
flutter test test/deposits test/address test/app_financial_cards_test.dart test/core/router/app_router_test.dart
flutter analyze
```

Screen tests optionally export previews with `CAPTURE_CERTIFICATE_PREVIEWS=1` to
ignored `build/previews/`. Test counts are not frozen here; use the execution
report. The [dashboard document](../dashboard/development.md) retains its design
audit and accepted dashboard-specific differences.
