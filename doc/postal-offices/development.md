# Postal offices

Postal office lookup is an independent feature because cheque clearance and
cancellation both use it. Its public entry point is `showPostalOfficesSheet` from
`features/postal_offices/postal_offices.dart`. It owns postal entities, repository,
lookup use cases, mock adapter, Cubit/State and its sheet/results widgets.

Each opening constructs PostalOfficesCubit directly in BlocProvider.create and
fetches provinces. Cubit resolves PostalOfficesRepository through GetIt; no Cubit
is registered or passed through UI constructors. Cheque repositories do not own
postal lookup or its fixtures. Province selection resets city/results. The mock
returns two offices for Tehran/north-east and no offices for Isfahan. No live API
has been introduced.

Independent province/office request statuses retain one latest failure/message.
The listener displays failure messages on status transitions. Back and close are
blocked while either request is loading; otherwise Back from results returns to
location selection. Share uses prepared retrieved-address text and a consumed
reusable effect, allowing repeated share attempts without effect IDs. UI owns the
platform share operation and displays availability feedback on unsupported hosts.
