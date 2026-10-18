# Close surplus deposits

Route: `/deposits/close-surplus-deposits`; service ID: `deposit-close-extras`.
The central router accepts an optional initial deposit number. The Cubit resolves
Persian/Arabic/Latin digits against the fetched eligible primary catalog.

The initial form, selected form and empty result follow Figma nodes
`28060:13952`, `28060:14157` and `28060:14179` in file
`nYQNyZdSs98lwymCpt5Sag`. The owner explicitly requested a disabled bottom
button for an empty surplus list. Positive mock results retain the same screen
shell and reuse `AppDepositList`; no separate positive-list design was supplied.

## Behavior

- Select a primary deposit and accept the terms before requesting a review.
  Changing the primary clears the old review and terms acceptance.
- A nonempty review lists the proposed closure candidates, with the retained
  primary shown above them. Confirm submits exactly that reviewed list.
- Back from review returns to the primary selection. Leaving an edited form
  requests confirmation. Back remains available during requests.
- Catalog errors expose Retry. Review/submission errors remain inline; retrying
  a failed submission keeps the same request and idempotency key.
- The terms document currently displays the existing unavailable message.

## Mock scenarios and integration

`MockSurplusDepositsRepository` is registered as the repository dependency;
Cubits are never registered. Primary `10.1234567.2` returns the designed empty
result. Primaries ending in `.1` and `.3` initially return two surplus deposits
ending in `.4` and `.5`. A successful simulated closure removes these candidates
from subsequent reviews in that repository instance. The receipt explicitly
states that no real deposit or balance changed. Restarting resets mock data.

The repository supplies eligible primaries and reviewed candidates. The client
does not infer banking eligibility from a generic account catalog. The mock
boundary binds a review token to its primary and candidates, rejects altered or
already-closed candidates, and caches identical idempotent requests. A real bank
integration must replace this repository and enforce authorization, eligibility,
atomic balance/associated-item transfers and idempotency on the server.

`CloseSurplusDepositsScreen` creates its Cubit directly in `BlocProvider.create`
and calls the real catalog fetch. Plain Freezed State holds independent catalog,
review and submission statuses. Cubit owns selection, eligibility for controls,
request construction and modal-result interpretation. Named, filtered listeners
execute navigation, dialogs and feedback. Application boundaries convert
unexpected repository exceptions to the existing `UnexpectedFailure`.

Reused components include `CertificateSelect`, `AppCheckbox`, `AppButton`,
`AppTopBar`, `AppAssistantButton`, `AppDepositList` and the existing exit dialog.
The empty-result glyph is the original Figma SVG.

## Verification

`test/deposits/close_surplus_deposits_cubit_test.dart` covers entry resolution,
empty and positive review, errors/retry, effects and mock idempotency safeguards.
`test/deposits/close_surplus_deposits_screen_test.dart` covers the designed states,
actual selection and terms interaction, mock list/receipt, central service entry,
small viewports and larger text in fa/en/ar. Set `CAPTURE_CERTIFICATE_PREVIEWS=1`
to save previews under `build/previews/certificates/surplus-deposits-*.png`.
