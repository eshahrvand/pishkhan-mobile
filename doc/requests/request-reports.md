# Request reports

The independent `features/requests` module implements request history and
cancellation. Entry: `/requests/reports`, through the existing `requests-list`
service in the dashboard catalog and the drawer's Requests item.

## Behavior

- Fetch reports on entry; pull down to refresh while retaining the committed
  filters and identifier search.
- Search by payment/request identifier, including Persian and Arabic digits.
- Combine multiple request types, multiple statuses and a date period.
- Search the request-type options without losing selections outside the search.
- Select all options or deliberately select none. An empty selection shows no
  matching requests; it never silently selects everything.
- Each filter sheet edits a draft. Apply commits it; Cancel, system Back and
  outside dismissal discard it.
- Filter chips follow the existing Agent Settings behavior: inactive chips show
  the gray down-chevron and open their sheet; active chips use the existing
  selected appearance with a white cross. Tapping an active chip clears only
  that filter, preserving the other filters and identifier search. There is no
  separate Clear filters button.
- Date presets: today, the latest seven days, thirty days or ninety days,
  including today. Boundaries use the bank's Iran business date, UTC+03:30,
  independently of the device timezone. Tapping the active date chip clears the
  date restriction; the sheet contains only the four supplied date presets.
- Custom-date inputs and the calendar are deliberately omitted at the owner's
  request until the calendar component is available.
- The card's More control opens the details sheet. Only `awaitingApproval`
  displays Back and Cancel request buttons, including the first pending card.
  Other statuses show neither button and remain dismissible with Back/outside tap.
- Cancel request closes details and opens a separate confirmation over the list.
  Dismissing confirmation sends no cancellation. Confirm submits once while the
  button is loading. Failure retains the request for retry; success replaces its
  status with Cancelled and recalculates the active filtered list.

## Ownership and integration

- `RequestReportsScreen` directly constructs `RequestReportsCubit` in its
  Provider and explicitly starts `fetchReports`.
- GetIt registers only `RequestReportsRepository`. The Cubit resolves it in a
  final field. Provider owns the Cubit; sheets borrow it with `BlocProvider.value`.
- State is a plain Freezed `.initial` factory, part of the Cubit library, with
  independent fetch/cancellation statuses. Generated Freezed output follows the
  repository's existing ignore/build-runner policy.
- The Cubit owns drafts, filtering, cancellation eligibility, selected reports,
  stable cancellation identity and prepared modal/navigation effects. Widgets
  own Flutter rendering and modal execution; dismissal results return to Cubit.
- `MockRequestReportsRepository` supplies demonstration records and retains mock
  cancellations for its DI lifetime. It does not cancel real bank requests or
  aggregate the separate service mocks' submissions.
- The repository contract returns UTC timestamps, a server/bank time and typed
  `Result` values. The mock converts exceptions to the existing
  `UnexpectedFailure`. A live adapter must authorize customer ownership and the
  current pending status, enforce idempotency, and supply the consolidated
  customer report catalog. Cancellation uses `cancel:<trackingId>` across retries.
- Refresh/detail selection is gated while cancellation is pending, including
  after the user dismisses the confirmation. Route Back remains available.
- Resuming suspended banking flows is not part of these supplied frames.

## Shared UI and Figma

Reuses `AppRequestReportCard`, `AppTopBar`, `AppAssistantButton`,
`AppBottomSheetHeader`, `showAppServiceSheet`, `AppChips`, `AppTextField`,
`AppCheckbox`, `AppBadge` and `AppButton`. The report card adds an optional
`statusCorner`; its existing default is preserved and reports select pill badges.
The type list scrolls independently above fixed Apply/Cancel controls.

The shared package has no circular radio primitive; date choices follow the
existing cheque reason selector with theme tokens and the existing Figma check.
The design's search, chevron and dashed separator downloads were byte-identical
to `cardFeaturesSearch`, `depositFeatureChevron` and `cardFeaturesSeparator`.
No new assets or package dependencies are required.

Figma file: `nYQNyZdSs98lwymCpt5Sag`.
Frames: list `28084:20446`, type `28084:20464`, date `28084:20527`,
status `28084:20571`, details `28084:20612`, pending actions `28084:20647`,
confirmation `28084:20687`. The owner's pending-action correction overrides
the missing buttons in the first details frame. All dates and Clear filters
are not additional controls: removal belongs to each active chip.
Cancelled remains a filterable status because successful cancellation produces it.

The status filter retains the Figma labels “Awaiting review” and “System error”;
the cards/details use “Awaiting approval” and “Processing error” as authored.

## Follow-up design audit

The complete list, type/date/status sheets, pending/non-pending details and
cancellation confirmation were reviewed again after the active-chip feedback.
The audit removed the unrequested clear button and All dates option, aligned
active-chip interaction/icons with Agent Settings, separated contextual status
labels, aligned text line height/spacing with the supplied frames, and reserved
the report card's 20px More-icon target while its SVG is loading. Chip
shadows retain their viewport clearance from the preceding spacing fix.

## Verification

`test/requests` covers combined filtering, drafts, type search, bank midnight
boundaries, failure/retry, cancellation identity, pending-only actions, report
replacement, dashboard navigation and narrow English/Arabic layouts.
It also verifies clearing each active chip independently, preserving search and
other filters, keyboard-safe filter actions, duplicate cancellation taps, and
that completing a dismissed cancellation cannot close a subsequently opened
filter sheet.

Visual captures can be reproduced using:

```sh
CAPTURE_CERTIFICATE_PREVIEWS=1 flutter test test/requests
```

Captures are ignored artifacts under `build/previews/certificates/reports-*.png`.
