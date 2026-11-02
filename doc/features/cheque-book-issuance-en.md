# Cheque book issuance prototype

Updated: 2026-11-02. See the [cheque module overview](../cheque/development.md)
for all three cheque flows and the distinction between address editing and postal-office lookup.

Entry: dashboard cheque services → Issue cheque book (`cheque-issue`), also available from deposit actions. An incoming deposit number is resolved by Cubit after catalog loading.

One Provider-owned flow covers selection, registry checking, delivery and fee confirmation. Applicant type, available accounts, per-account leaf counts, registration status and fees are repository data. The mock registry check takes two seconds; a real adapter can replace the dependency in DI.

## Trying the five supplied scenarios

The default is an individual with one registered residence. Choose a scenario at launch, without adding debug controls to the banking screens:

```sh
flutter run --dart-define=CHEQUEBOOK_SCENARIO=legal-verified
```

| Value | Scenario |
| --- | --- |
| `legal-verified` | Legal applicant; verified residence; recipient name and national ID required |
| `individual-verified` | Individual; verified residence; delivery-address selector, optional second recipient and bank agent |
| `single-unverified` | One unregistered residence; notice only; acknowledgement returns home |
| `mixed-addresses` | Two residences, one registered; invalid address may be removed; delivery uses registered residences |
| `multiple-unverified` | Two unregistered residences; Next disabled; deleting one leaves the single-address blocking notice |

After changing a dart-define, restart the application. This is compile-time mock configuration, not customer/account identity logic.

The address feature’s editor modal can add a delivery address. Removing a delivery choice only removes it from this flow; registry-residence deletion is a separate repository operation and cannot delete the last residence. No address is marked registered by local editing.

The official registry link opens `https://amlak.mrud.ir` in the Android/iOS browser. Other platforms show an unavailable message if no handler exists. “My addresses” intentionally displays the owner-approved content-unavailable message; profile address management remains outside this feature. Optional bank-agent lookup is also unavailable until its service is supplied.

Fee quotes bind the checked account, leaf count, residency token, delivery details and recipient to a server token. Submission keeps the exact quoted snapshot and an idempotency key across retries. The mock checks ownership, eligible leaf counts, verified residence availability, quote expiry, wallet sufficiency and payload binding. Receipts explicitly identify the simulated operation: no real issuance or debit occurs.

Delivery fields, recipient/agent sections and summary rows reuse the shared components extracted from deposit-certificate code. The address editor, Cubit and State belong to `features/address`; deposit and cheque flows open it through `ServiceRegistry.openAddressEditor`. The common `DeliveryAddress` result remains in Core so callers need no direct import from another feature.

## Phase-9 ownership and feedback

Contract v1.23 applies. The six existing UseCases in `cheque_book_usecase.dart`
end in `UseCase` and are registered in GetIt. `core/di` wires their repository;
Cubit resolves final fields using complete lowerCamelCase UseCase names.
No dependency is forwarded from UI or constructed inside Cubit. Each request
owner uses `async/await` and its own Result switch; returned errors retain the
existing Domain exception boundary.

Registry check and registry deletion keep distinct explicit emits, with shared
pure calculations for registered addresses, review/acknowledgement, initial
delivery selection and continuation. Delivery validation reads stored sibling
flags and the changed input's fresh result. Local delivery removal remains local;
it does not trigger registry deletion. Recipient fields, quote token/binding,
confirmed draft and retry key preserve their existing behavior. Every successful
new quote still creates its existing new key; submission retry reuses that key.

Six independent operation-failure listeners and the typed-effect listener share
`MultiBlocListener`; `BlocBuilder` renders. Latest failure/message is retained,
and does not replay on an unrelated operation or block modal/navigation effects.
System/header Back remains blocked while any request is pending. Existing
residency/quote request IDs continue to reject stale responses.

## Validation

Relevant automated tests live in `test/cheque/cheque_book_*`. Reference screenshots can be exported with:

```sh
CAPTURE_CERTIFICATE_PREVIEWS=1 flutter test test/cheque/cheque_book_screen_test.dart
```

Images are written to `build/previews/certificates/chequebook-*.png` and are not product assets.

The [phase-9 review](../cheque/phase-9-review.md) records current scoped commands
and results. New regression coverage repeats failures for all six operations,
recovers through registry deletion/address saving/quote, and submits the exact
confirmed snapshot successfully after retries.

## Design reference

Figma file `nYQNyZdSs98lwymCpt5Sag`, node prefix `28060:`:
`26436`, `26636` (selection); `26910` (checking); `26716`, `26730`
(legal recipient); `26832`, `26858` (confirmation); `26744`, `26780`
(individual delivery); `26932` (single unverified); `27040`, `27281`
(mixed residences/deletion); `27115`, `27190`, `26986` (multiple unverified).

The production bank/registry/document/payment adapters remain unconnected.
A complete mock UI flow does not imply that actual bank issuance is available.

Shared address editor migration is recorded in [phase 5](../profile/phase-5-review.md). Its
`ServiceRegistry.openAddressEditor` entry/result contract and this flow’s existing
address inputs, cancellation and validation remain unchanged.
