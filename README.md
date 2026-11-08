# Pishkhan Mobile

Flutter application for the Smart Virtual Counter. Feature screens own their
Cubit scopes and resolve UseCases only. Application/data access follows
Cubit → UseCase → Repository; Cubits never import or directly resolve Repository.
Domain contains service contracts and business rules, Data contains
adapters, and `core/di` wires actual dependencies through GetIt. Some flows use
bank integrations and others use documented mock adapters; each flow document
records its current boundary.

## Start a checkout

Resolve the existing dependencies and generate ignored Freezed/API outputs when
needed before building or testing:

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Dependency changes are separate work; the commands above use the checked-in
project configuration. Follow [AGENTS.md](AGENTS.md) before editing feature code.

## Coding reference and verification

The [UI/Cubit/State contract](doc/ui-cubit-state-agent-rules-en.md) is the
mandatory presentation reference. It takes precedence over older examples in
the [architecture](doc/architecture-smart-virtual-counter-v2-en.md) or skills.
Use the project [Cubit skill](.agents/skills/pishkhan-cubit-clean-code/SKILL.md)
and [UI skill](.agents/skills/flutter-widget-ui-style/SKILL.md) with that contract.

Run tests for changed flows and directly related consumers/dependencies. For
example, when changing the cheque/postal flows:

```sh
flutter test test/postal_offices test/cheque
flutter analyze lib/features/postal_offices lib/features/cheque test/postal_offices test/cheque
```

Include the relevant DI/router/service-entry regression files when their shared
boundaries change. A full-application test run requires an explicit owner
request; historical results do not authorize repeating it.

The Cubit migration and UseCase-only follow-up are complete. Current ownership
and operation details live in each flow document below; the coding contract
defines the required rules. Completed migration plans and execution reports
remain available in Git history.

## Flow documentation

- [Login](doc/login/development.md) and [API integration](doc/auth/login-api-integration.md)
- [Dashboard](doc/dashboard/development.md), [cards tab](doc/cards/my-cards.md),
  [deposit services](doc/deposits/development.md) and [loans](doc/loans/development.md)
- [Card services](doc/cards/card-services.md), [issuance](doc/cards/card-issuance.md),
  [virtual requests](doc/cards/virtual-card-request.md),
  [linked deposit](doc/cards/change-card-deposit.md),
  [expired gift balance](doc/cards/expired-gift-balance.md) and
  [password services](doc/cards/password-services.md)
- [Deposit list](doc/deposits/deposit-list.md),
  [average balance](doc/deposits/average-balance.md),
  [financial certificate](doc/deposits/financial-certificate.md),
  [agent introduction](doc/deposits/introduce-agent.md),
  [agent settings](doc/deposits/agent-settings.md),
  [surplus closure](doc/deposits/close-surplus-deposits.md),
  [restriction](doc/deposits/deposit-restriction.md) and
  [deposit mandate](doc/deposits/deposit-mandate.md)
- [Personal information, addresses and jobs](doc/profile/personal-information.md)
- [Modern banking](doc/modern-banking/mobile-bank.md),
  [on-site transfer](doc/transfers/on-site-transfer.md) and
  [request reports](doc/requests/request-reports.md)
- [Postal offices](doc/postal-offices/development.md),
  [cheque overview](doc/cheque/development.md),
  [clearance](doc/cheque-clearance-feature-en.md),
  [cancellation](doc/cheque/cancellation.md) and
  [cheque-book issuance](doc/features/cheque-book-issuance-en.md)

All four dashboard tabs consume one `HomeCubit`/`HomeState`. Optional visual test
captures are ignored under `build/previews/`; screenshots are not stored in doc.
