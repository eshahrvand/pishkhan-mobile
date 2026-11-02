# Postal offices

Postal office lookup is an independent feature because cheque clearance and
cancellation both use it. Its public entry point is `showPostalOfficesSheet` from
`features/postal_offices/postal_offices.dart`. It owns postal entities, repository,
lookup use cases, mock adapter, Cubit/State and its sheet/results widgets.

Each opening constructs PostalOfficesCubit directly in BlocProvider.create and
fetches provinces. `core/di` registers `FetchPostalProvincesUseCase` and
`FetchPostalOfficesUseCase`, wiring their `PostalOfficesRepository` dependency.
Cubit resolves final `fetchPostalProvincesUseCase` and
`fetchPostalOfficesUseCase` fields; it neither constructs UseCases nor forwards
the repository. UseCases live in `domain/usecases/lookup_usecase.dart`; Domain
remains independent of GetIt. No Cubit is registered or passed through UI
constructors. Cheque repositories do not own
postal lookup or its fixtures. Province selection resets city/results. The mock
returns two offices for Tehran/north-east and no offices for Isfahan. No live API
has been introduced.

Independent province/office request statuses retain one latest failure/message.
Each operation has its own failure-status listener. Those and the independent
share-effect listener share `MultiBlocListener`; `BlocBuilder` renders the sheet.
Retained failure/message text neither replays feedback nor blocks Share after
a successful retry. Requests use `async/await` and explicit Result switches;
UseCases retain their existing exception-to-`UnexpectedFailure` boundary.
Back and close are
blocked while either request is loading; otherwise Back from results returns to
location selection. Share uses prepared retrieved-address text and a consumed
reusable effect, allowing repeated share attempts without effect IDs. UI owns the
platform share operation and displays availability feedback on unsupported hosts.

The [phase-9 review](../cheque/phase-9-review.md) records the flow/readers,
scoped checks and results. Tests cover independent repeated province/search
failures, success after retry and repeated native share requests with retained
error text; this does not verify a live postal service or device share chooser.
