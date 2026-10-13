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

Each flow has one development document. Related card flows share `doc/cards/`.
Visual captures are not stored in `doc`; optional test captures use ignored
`build/previews/` output.

- [Card services](doc/cards/card-services.md)
- [Dashboard cards](doc/cards/my-cards.md)
- [Card issuance](doc/cards/card-issuance.md)
- [Virtual card requests](doc/cards/virtual-card-request.md)
- [Card password services](doc/cards/password-services.md)
- [Login](doc/login/development.md)
- [Dashboard](doc/dashboard/development.md)
- [Deposits](doc/deposits/development.md)
- [Loans](doc/loans/development.md)

General architecture and design-system guidance remain in the top-level `doc`
files. Existing Persian documents are retained unchanged.
