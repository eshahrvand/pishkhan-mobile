# On-site fund transfer request

Implemented in `features/transfers`, independently of `features/cheque`.
The owner-requested on-site service is a scheduled request, rather than a new
instant payment channel. The [UI/Cubit/State contract](../ui-cubit-state-agent-rules-en.md),
including the 2026-10-18 amendments, governs this implementation.

## Entry and structure

- Service ID: `transfer-local` (the existing catalog/drawer and deposit shortcut).
- Route: `/transfers/on-site`, declared centrally in `AppRoutes` and `app_router.dart`.
- `OnSiteTransferRouteArguments` accepts an optional selected deposit number and
  assistant callback. The authenticated return-location whitelist includes the route.
- `OnSiteTransferScreen` directly constructs its Provider-owned Cubit and calls
  `fetchCatalog`. The Cubit resolves the registered repository in a final field.
- One plain Freezed `.initial` State holds all four stages, independent operation
  statuses, editable drafts, committed destinations, file approval and receipt.

## Four stages and Figma references

File: `nYQNyZdSs98lwymCpt5Sag`.

| Stage / surface | Figma nodes | Behavior |
| --- | --- | --- |
| Deposit and transfer date | `28084:17279`, `28084:17316` | Required source and eligible transfer date |
| Visit address and date | `28084:17353`, `28084:17693` | Select/add/delete an address; required visit date |
| Empty destination stage | `28084:17371` | Manual destination or spreadsheet |
| Upload sheet | `28084:17505`, `28084:17538` | System file selection, progress, remove/cancel and Review |
| Manual destination sheet | `28084:17468`, `28084:17610`, `28084:17651` | Amount, SATNA, Iranian IBAN, purpose and optional description |
| One/multiple destinations | `28084:17399`, `28084:17415` | Append destinations, remove individual destinations, preserve committed entries |
| Confirmation and service fee | `28084:17432` | Existing request summary/invoice, consent and simulated submission |

Only SATNA is currently selectable, as requested. The purpose catalog currently
contains salary payment, the supplied design's option. The illustrative internal
transfer card in Figma does not introduce another supported transfer method.
The repository resolves a recipient; the mock explicitly returns a demonstration
recipient instead of claiming to verify a real bank account holder.

## Dates

Dates are entered as Solar Hijri `YYYY/MM/DD`, using the existing digit normalizer
and `JalaliDateParser`. State/request dates are Gregorian UTC date values. The
calendar icon focuses the editable date field: the installed design system has
no approved Jalali picker, and no calendar package or design-system variant was added.

The catalog provides Tehran bank time and public holidays. Transfer dates reject
past days, Fridays and supplied holidays; today is available before 10:00. The
visit date must be a working day between today and the transfer date. Changing
the transfer date clears the dependent visit date. The mock does not provide an
authoritative Iranian public-holiday calendar. Live integration must supply bank
time, holiday/visit availability and final server eligibility.

## Spreadsheet contract

`DocumentPicker` selects an actual document on Android, iOS and web without a
new package. Native hosts use the existing MethodChannel integration approach;
web uses a browser file input. Cancellation leaves the committed request intact.
Selection contents are memory-only, with bounded native/browser reads.

The supplied upload instructions say **XLS, maximum 100 KB**, while the progress
mockup shows an illustrative 16 MB filename. The explicit 100 KB limit is used.
Empty, oversized and non-XLS selections are rejected. XLSX is not advertised.

Per the owner's instruction, **Review approves the uploaded file and immediately
advances to confirmation**. It does not parse a workbook or fabricate destination
rows/totals. The request carries the approved attachment token, alongside any
manual destinations. A future real adapter owns workbook parsing, schema review,
malware checking and durable storage. The current mock retains attachment
metadata only, not document bytes. The sample link shows the existing unavailable
feedback until an authoritative workbook template is supplied.

Uploads and destination lookups have request IDs for actual cancellation/reopen
or replacement overlap. Stale completions cannot close another editor or commit
a dismissed file. No Cubit disposal guards or BaseCubit were introduced.

## Reuse and visual behavior

Reused `AppTopBar`, `AppStepper`, `CertificateSelect`, `CertificateInput`,
`AppAddressCard`, the existing address editor, `AppTransferDestinationCard`,
`AppFileUploadBase`, `AppRequestSummary`, `AppInvoice`, `DepositRequestFooter`,
`AppAssistantButton`, `showAppServiceSheet` and `showFlowExitDialog`.

The existing address section and footer were promoted to `shared/widgets`;
compatibility exports keep existing deposit callers unchanged. Additive parameters
supply feature-specific address labels, footer spacing and localized transfer/file
copy. Full IBANs wrap in this feature's destination cards rather than shrinking
into an unreadable account-number slot. Existing card/gallery defaults remain.
File-upload progress fills from the physical left, as in the supplied frame.

The original upload icon and operation divider were downloaded from Figma and registered in `AppAssets`.
Other icons/artwork reuse matching existing local assets. No screen screenshot
is used as an application asset. Flutter/native status and navigation bars are
outside the screen widget captures.

## Submission and exit

Consent and wallet sufficiency control the final action. Loading is supplied to
`AppButton.isLoading`; Cubit actions do not repeat UI invocation guards. Back is
available during requests, traverses previous stages, and requests confirmation
on the first stage. System Back and the header follow the same Cubit action.

A random flow identity is created during the explicit initial fetch. Returning to
review and retrying an unchanged payload keeps its idempotency key; changing the
payload gets a new revision. The confirmed snapshot is submitted without form
revalidation. The mock checks deposit/attachment ownership, fee binding and
idempotency, and returns an explicitly `DEMO-TRANSFER` receipt. Dismissing the
receipt goes Home and removes the form from navigation history.

**No real funds are transferred and no wallet is charged.** Production still
requires bank authentication/authorization, account ownership, SATNA eligibility
and limits, recipient verification, current tariffs, binding/expiry, secure upload,
atomic fee execution and durable server-side idempotency.

## Verification

- `test/transfers/on_site_transfer_cubit_test.dart`: validation, multiple entries,
  cancellation/stale completions, file approval, retry identity and Back.
- `test/transfers/on_site_transfer_screen_test.dart`: all stages, manual entry,
  native-channel selection/progress, Review, system Back and Arabic/English layouts.
- Shared component, assets, deposit submission and actual central-router tests.
- Existing dashboard navigation regression includes `transfer-local`.

```sh
flutter test test/transfers
flutter analyze
flutter build apk --debug --no-pub
flutter build web --no-pub
```

Optional visual captures: `CAPTURE_CERTIFICATE_PREVIEWS=1 flutter test
 test/transfers/on_site_transfer_screen_test.dart`. PNGs are ignored under
`build/previews/certificates/onsite-*.png`. Widget tests mock the native file
selection result; successful builds are not a claim that the native document
picker or Safari file chooser was exercised on a device. iOS device execution
remains unverified.
