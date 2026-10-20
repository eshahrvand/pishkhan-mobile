# Cheque cancellation

Service `cheque-cancel`; route `/cheque/cancellation`.
`ChequeCancellationScreen` accepts an optional deposit number and assistant
callback. DI currently selects `MockChequeCancellationRepository`.

## Stages

| Stage | Required interaction | Next action |
| --- | --- | --- |
| 1 | Deposit and paper/digital type | Fetch that account/type list |
| 2 | At least one selected cheque | Open selected-cheques review |
| Review | Inspect/remove entries | Back proceeds to reasons when opened by Next and entries remain |
| 3 | Reason on every entry | Create confirmed snapshot; go to final stage |
| 4 | Instructions and terms acceptance | Submit snapshot |

Header review opens the same sheet without continuation. Outside/system dismissal
stays at selection. Nested delete confirmation commits only on Yes; cancellation
leaves the entry unchanged. Review count and underlying selected borders update
together. Removing all entries leaves Next disabled.

Search normalizes Persian/Arabic digits and number separators, matching cheque
number or Sayad ID. Hidden selections remain selected. Select All covers the
whole fetched list and is hidden during search. Changing account/type clears
previous choices.

Reasons are catalog data: damaged/unused or judicial authority order. Individual
and common-reason sheets have separate titles and Select/Cancel actions. Choosing
an option changes only the draft. Select commits; cancellation/dismissal does not.
A common reason replaces all current reasons; individual overrides remain
possible. Removing the last cheque in stage 3 returns to stage 2. Every selected
entry needs a reason before Next becomes available.

The final stage shows the letter action, printed-letter/cheque delivery
instructions, shared postal-office helper and terms. The owner confirmed that
the official letter and legal content are not ready; their actions show the
existing unavailable message. Demo submission requires consent, with no invented
download or download-completed flag.

Back moves one stage at a time. Leaving the first stage after input or requesting
the assistant requires confirmation. Navigation stays available during requests;
UI loading/availability controls prevent repeated edits/submission. Stage changes
reveal the beginning of content. Successful demo submission opens its explicit
mock receipt; dismissal returns home.

## Data and operation boundary

Domain models are `ChequeCancellationCatalog`, `CancellableCheque`,
`ChequeCancellationEntry`, `ChequeCancellationRequest` and receipt. The request
contains exactly one deposit/type, the selected records/reasons and an idempotency
key. `ChequeCancellationCubit` owns decisions and the confirmed snapshot;
State is plain Freezed `.initial` / `part of` with separate catalog/list/submission
statuses. The screen's Provider creates Cubit; editing modals borrow it.

Fetch/submit use cases convert repository exceptions to the existing
`UnexpectedFailure`. Back/re-entry may overlap a prior list query; only the
newest response can publish its list. Retrying unchanged submission retains its
snapshot/key. Returning to reasons without changing the payload retains its identity;
editing the payload and reconfirming creates a new request identity.

The mock validates account/type membership, actual cheque ownership, duplicate
entries, reason completeness and key conflicts. Identical retries return the same
receipt. Both accounts `.1` and `.2` are offered. Most combinations yield ten
cheques starting at `137/487567`, Sayad `2854678398765490`; account `.2` with digital
type yields an empty list. No real cheque is cancelled or posted.

## Reuse

Public controls, app headers/assistant/exit dialog and blurred service-sheet frame
are reused. Identity rows are shared between cards and review. Circular reason
choices use the original Figma check asset; installed avp_ui has no radio primitive.
Postal search reuses `presentation/shared/postal` as documented in the
[module overview](development.md#shared-postal-office-helper). It does not share
the address editor's State or postal-code validation.

## Figma and checks

File `nYQNyZdSs98lwymCpt5Sag`; node prefix `28060:`:

| State | Nodes |
| --- | --- |
| Deposit/type | `25893` |
| List/search/selected/all | `25944`, `26002`, `26021`, `25973` |
| Review/removal | `26332`, `26405` |
| Reasons/sheets/filled | `26088`, `26105`, `26171`, `26237` |
| Removal/common reason | `26307`, `26138` |
| Final instructions | `26271` |

Tests under `test/cheque`: `cheque_cancellation_cubit_test.dart`,
`cheque_cancellation_repository_test.dart`, `cheque_cancellation_screen_test.dart`.
They exercise selection/search, drafts, common/individual reasons, both removal
locations, empty state, stale list replies, retry snapshots, service routing,
pending Back and 320px enlarged text. Opt-in captures use
`CAPTURE_CERTIFICATE_PREVIEWS=1` and write
`build/previews/certificates/cheque-cancel-*.png`.
