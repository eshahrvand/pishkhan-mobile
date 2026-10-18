# pishkhan_mobile

A new Flutter project.

## Getting Started

Generate the ignored Freezed files before building or testing a fresh checkout:

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Documentation

The authoritative Cubit/State coding convention is [architecture Section 12](doc/architecture-smart-virtual-counter-v2-en.md#12-state-management-with-cubit). New work and refactors use plain Freezed State fields, direct UI reads and Cubit-owned calculations.

Each flow has one development document. Related card flows share `doc/cards/`.
Visual captures are not stored in `doc`; optional test captures use ignored
`build/previews/` output.

- [Card services](doc/cards/card-services.md)
- [Dashboard cards](doc/cards/my-cards.md)
- [Card issuance](doc/cards/card-issuance.md)
- [Virtual card requests](doc/cards/virtual-card-request.md)
- [Change linked card deposit](doc/cards/change-card-deposit.md)
- [Expired gift card balance](doc/cards/expired-gift-balance.md)
- [Card password services](doc/cards/password-services.md)
- [Login](doc/login/development.md)
- [Dashboard](doc/dashboard/development.md)
- [Deposits](doc/deposits/development.md)
- [Standalone deposit list and account sheets](doc/deposits/deposit-list.md)
- [Statement / average balance request](doc/deposits/average-balance.md)
- [Financial solvency certificate](doc/deposits/financial-certificate.md)
- [Agent settings](doc/deposits/agent-settings.md)
- [Close surplus deposits](doc/deposits/close-surplus-deposits.md)
- [Deposit blocking and unblocking](doc/deposits/deposit-restriction.md)
- [Loans](doc/loans/development.md)

General architecture and design-system guidance remain in the top-level `doc`
files. Existing Persian documents are retained unchanged.

All four dashboard tabs share one `HomeCubit` and plain `HomeState` under
`lib/features/dashboard/presentation/home/cubit/`. See
[current Home state ownership](doc/dashboard/development.md#12-state-management-with-cubit).
