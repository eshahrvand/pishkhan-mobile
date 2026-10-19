# Cheque book issuance prototype

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

## Validation

Relevant automated tests live in `test/cheque/cheque_book_*`. Reference screenshots can be exported with:

```sh
CAPTURE_CERTIFICATE_PREVIEWS=1 flutter test test/cheque/cheque_book_screen_test.dart
```

Images are written to `build/previews/certificates/chequebook-*.png` and are not product assets.
