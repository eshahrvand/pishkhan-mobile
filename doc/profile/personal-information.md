# Personal information services

## Entry points and implementation

The dashboard service catalog and drawer open the existing IDs through
`ServiceRegistry`: `identity-phone`, `identity-addresses`, and
`identity-occupation`. Their routes are `/profile/change-phone`,
`/profile/addresses`, and `/profile/occupations`; all three participate in the
existing authenticated return-location allowlist.

The implementations live under `features/profile/presentation/change_phone`,
`addresses`, and `occupations`. Each screen directly creates its own Cubit in
`BlocProvider.create`. Cubits resolve `PersonalInformationRepository` through
GetIt; the router only selects the destination. Freezed State contains plain
values, independent operation statuses and typed effects. UI executes navigation,
modals and feedback; Cubit interprets modal results and owns validation, request
construction and mutations.

## Reuse

- `AppTopBar`, `AppAssistantButton`, `AppAddressCard`, `AppOccupationCard`.
- `CertificateInput` / `CertificateSelect`, the package input controls and digit
  normalizer, `AppInvoice`, and `DepositRequestFooter` for consent/payment UI.
- The existing address editor through `ServiceRegistry.openAddressEditor`.
  Its optional initial address supports edit; optional contact inputs add
  address type and fixed-line telephone. A Cubit-prepared `retainHomeAddress`
  entry constraint prevents changing the last home into a work address and shows
  the notice inside the editor while preserving typed input. Previous callers
  retain their original three-field form. `DeliveryAddress` retains these optional
  contact values. The sheet explicitly applies bottom SafeArea, including when
  its caller already consumed inherited padding, and keeps inputs scrollable above
  the keyboard.
- Existing `PhoneNumberValidator`, `CodeValidator`, and `PostalCodeValidator`.
  Fixed-line telephone uses `TelephoneNumberValidator`.
- Existing service-sheet scrim/blur and handle header. The edit/delete action
  sheet is shared by addresses and occupations. Address deletion reuses
  `AppDeleteAddressSheet`; `AppDecisionSheet` supplies the occupation confirmation
  and the minimum-record notices, including the notice inside the shared editor.

Shared cards accept localized labels, the outlined white appearance from these
frames, and an address review-status slot. Existing defaults remain available to
previous callers. Existing matching assets are reused; six missing SVG assets
are bundled and referenced with `AppConstants.baseImage`.

## Change mobile number

Figma: `28084:25459`, `28084:26557`, `28084:26595` in file
`nYQNyZdSs98lwymCpt5Sag`.

The current phone is read-only. New-phone validation starts on the first typed
digit, normalizes Persian/Arabic digits, rejects the current number and controls
OTP availability. OTP submission requires the returned code length, an unexpired
challenge, consent and sufficient wallet balance. Changing the phone invalidates
its challenge/code. Resend replaces the challenge; the Cubit countdown follows
its expiry timestamp and cancels on close. Time is formatted as minutes/seconds
(`01:00`, rather than the design's `00:60`). Secret values are excluded from
Freezed string output and cleared after success. Inputs disable while pending;
buttons use their loading parameter. Failed identical submissions retain their
idempotency key; changing the payload clears that identity. Successful completion
returns home so the submitted form cannot be revisited with Back.

## Address management

Figma: list `28084:25497`; querying `28084:26394`; valid `28084:26416`;
missing residence registration `28084:26438`; actions `28084:26460`;
minimum home-address notice `28084:26339`.

The list does not automatically inquire about residence registration. An unchecked
home address has the Review action. Clicking it shows querying and then the
returned valid/missing result; a failed inquiry restores Review and displays a
retryable error. Checked states do not expose Review. Work addresses have no
residence row. Each record retains its independent result. Add/edit use the
shared editor; edits preserve the ID and reset the inquiry. Editing a querying
record is disabled. Inquiry controls also disable during save/delete mutations.
Delete first requests confirmation, then removes the chosen address only on
Confirm. Cancel, system Back and outside dismissal preserve the list. A home
address must remain: deleting the last home (even if work addresses remain) shows
the informational sheet instead. Changing the last home into work shows the same
notice over the editor and keeps its type and draft. Parent Cubit and mock
repository also enforce the home-address invariant at save/delete boundaries.

The shared authored address editor remains the add/edit form; the new notice
frame provides the minimum-home rule and notice styling. No separate full add/edit
flow was supplied in the original task.

## Occupation management

Figma: list `28084:25519`; actions `28084:26027`; add `28084:25813`,
`28084:25952`, `28084:25995`; edit `28084:25845`, `28084:25877`, `28084:25909`;
delete confirmation `28084:26083`; minimum-occupation notice `28084:26103`.

The form explicitly contains occupation, description and consent. Editing
restores the selected record. Adding a non-working occupation beside an existing
working occupation (or the inverse) is blocked. Changing an existing occupation
between those groups shows the operator-review notice and allows submitting a
request. Request success returns to the approved list; the list is not optimistically
rewritten before approval, matching the design's up-to-three-hour notice. Delete
uses the edit/delete action sheet followed by the designed confirmation sheet.
Only Confirm removes the chosen record; dismissal and Cancel do not delete.
Attempting to delete the final occupation shows the required-record notice with
an acknowledgement button, and the mock repository independently rejects removing
the final occupation. A genuinely empty server response still renders the empty
message centered in the allocated list area. Both system Back and the top-bar Back request confirmation before abandoning a
form. Pending submission also disables opening another editor from the list.

## Current adapter boundary

DI currently registers `MockPersonalInformationRepository`, consistently with the
other prototype services. Its data persists only within the app session. It does
not call Shahkar, send SMS, query a real residence registry, charge real money,
or submit requests to a banking backend. The demo OTP is `2345` and expires after
60 seconds. The sample fee is 1,300,000 rials and wallet balance is 2,000,000 rials.
Only the mock wallet changes after successful phone submission.

For deterministic UI demonstrations, a postal code ending in `0` produces the
missing-registration state; other postal codes produce valid. Occupation requests
are queued in memory, with the approved list retained until an actual service
can provide approval results. The occupation selector currently supplies the four
options needed by the supplied screens. Terms use the existing unavailable
feedback because no approved terms document or endpoint was supplied.

A live adapter must replace these fixtures with authenticated profile data,
server-owned OTP/residence/occupation rules, authoritative prices and balances,
server idempotency, and the bank's response/error contracts. All adapter errors,
including unexpected exceptions, must be returned as `Err`.

## Verification

Tests cover live validation, normalization, challenge invalidation and expiry,
consent/wallet gating, retry identity, single mock charging, address inquiry and
mutations, editor contact restoration, occupation conflicts/operator review,
queued requests, confirmation/cancellation/outside dismissal, minimum occupation
and home-address invariants, preserved drafts during editor notices, centered
empty-list geometry, fixed 20px lock geometry, routes/Back, bottom navigation
insets, and narrow English/Arabic forms with the keyboard open. Existing shared asset and address tests remain in the suite.

Optional visual captures:

```sh
CAPTURE_CERTIFICATE_PREVIEWS=1 flutter test test/profile
```

Images are generated under ignored `build/previews/certificates/profile-*.png`;
Figma screenshots are reference targets and are not application assets.
