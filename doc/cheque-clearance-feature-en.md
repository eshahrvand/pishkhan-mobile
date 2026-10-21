# Cheque record clearance

Updated: 2026-10-19. See the [cheque module overview](cheque/development.md) for
issuance, cancellation, shared postal ownership and current integration limits.

Entry: **Cheque → Clear cheque record**, service ID `cheque-clear`, route
`/cheque/clearance`. The route participates in the existing authentication and
post-login return rules.

The screen fetches its deposit/reason catalog through
`ChequeClearanceRepository`. The registered implementation is a session-only
mock. No real cheque status, deposit balance or blocked amount is changed.

## Testing the demo

| Deposit | Known cheque numbers |
|---|---|
| `10.1234567.2` | `123/123456`, `123/123459` |
| `10.1234567.1` | `123/123457`, `123/123458` |

Persian and Arabic digits are normalized by the package input. Other syntactically
valid cheque numbers return `cheque.not-found` on submission, displayed under the
number field. Changing the deposit clears its dependent cheque number.

All six reasons are available:

- Deposit funds and block the amount; record older than three years: no post.
- Original cheque; partial non-payment certificate: the corresponding document
  and postal delivery instructions.
- Notarized consent: original consent, conditions and sample actions.
- Judicial letter: required letter number and original judicial letter.

Changing the reason clears the letter number and terms acceptance. A completed
request needs consent. Submission locks editing; transient retries retain their
idempotency key. A repeated successful key returns the same mock receipt;
reusing it with different request data returns an idempotency conflict.

Postal search is owned by the independently scoped `ChequePostalCubit` under
`features/cheque/presentation/shared/postal`, reused by cancellation and clearance.
Each opening constructs its own Provider-owned instance and fetches provinces
through the existing catalog repository; the request form retains its own State. Select Tehran and the north-east
postal district for the two Figma sample addresses; Isfahan has an empty result
fixture. Changing province clears the city. Back from results returns to the
search form. Reopening starts a fresh postal scope with no old city or result selection.
Sharing opens the Android/iOS system chooser with the retrieved addresses; it
never sends automatically. Unsupported hosts show an availability message.

The official terms, consent conditions and sample document are not available.
As explicitly agreed with the owner, those actions currently show “This content
is not ready yet.” No legal document or download is fabricated.

## Implementation boundaries

- Domain entities and repository contract contain no Flutter imports.
- GetIt registers the repository; the screen constructs and owns its Cubit.
- Cubit owns request decisions, validation outcomes, document requirements,
  consent and request effects. The separate postal Cubit owns its modal steps,
  search and prepared share content.
- UI owns rendering, modal/navigation/platform operations and focus.
- The form and postal province/city fields use package selectors with app-owned
  avp_ui option bottom sheets; postal lookup retains the two supplied bottom-sheet
  states. Placeholder text and chevrons use the Figma gray400
  treatment; selected values use the primary text treatment.

Figma file: `nYQNyZdSs98lwymCpt5Sag`, nodes `28060:25866`, `27372`, `28052`,
`28090`, `27410`, `27596`, `27657`, `27743`, `27839`, `27937`, `27471`, `27534`
(all with the `28060:` prefix).

The delivery-address editor and postal-code validation remain in the separate
`features/address` feature; the postal helper only finds authorized post offices.

Tests: `test/cheque/cheque_clearance_cubit_test.dart` and
`test/cheque/cheque_clearance_screen_test.dart`.
