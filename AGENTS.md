# Mandatory Project Instructions

## UI, Cubit, State, DI and Provider Work

Before planning, writing or reviewing application feature code involving UI,
Cubit/State, dependency access, Providers, routing boundaries, listeners,
consumers, widgets or dialogs, read the complete
[UI/Cubit/State contract](doc/ui-cubit-state-agent-rules-en.md).
Apply its Mandatory Enforcement section, Section 2.3 and the relevant detailed
rules and review checklists. A skill or historical code example does not replace
this required read. Within project style guidance, this owner-approved contract
takes precedence over older skills, architecture examples and existing code.

The contract is mandatory. Do not reinterpret a prohibition as a preference,
rename/wrap a forbidden pattern, or create exceptions for convenience, tests,
fewer lines, deadlines or architectural preference. Only an explicit owner
instruction changing the specific rule amends it; an ordinary coding request
does not imply a waiver. Higher-priority instructions and explicit user direction
remain controlling.

Core boundaries that must remain visible during implementation:

- GetIt registers actual data/application dependencies, never Cubit/Bloc.
  Cubits resolve required dependencies in their own fields; UI/router and Cubit
  construction do not forward Repository/service/UseCase arguments.
  UseCase class names end in `UseCase`; their snake_case Dart filenames end in
  `_usecase.dart` (for example `home_usecase.dart`). Register each used UseCase in GetIt;
  Cubit resolves it into a final field and invokes that instance. Cubit must not
  construct a UseCase or pass a Repository/service into its constructor. Wire
  UseCase constructor dependencies in `core/di`; keep Domain free of GetIt.
- Screen/feature-flow widgets construct Cubit directly in BlocProvider.create
  and call the explicit initial action there. GoRouter only selects destinations.
  No creation helper, private Screen/View wrapper or constructor emit/load.
- Preserve the current plain Freezed State.initial/part-of structure and
  independent operation statuses. State contains data, not handwritten logic.
- All transferable decisions, calculations, validation, request construction
  and modal-result interpretation belong in Cubit/Domain, never UI helpers,
  callbacks, listeners, lifecycle hooks or router adapters.
- Use explicit actions and emit(state.copyWith(...)); no generic field dispatch
  or State preparation/publication intermediaries.
  Shared request operations have one owner with delegation. Repeated fields
  alone do not make independent events one operation; keep their explicit emits
  and share pure calculations/predicates (owner clarification, 2026-11-01).
- Request feedback follows per-operation terminal status transitions. Each failure
  publishes its status, failure and prepared message together; retained error text
  is not an event. Typed effects execute independently of message presence. Do not
  routinely clear failure/message on loading, success or commands; preserve actual
  consumer/reset needs. Migrate listeners before removing their legacy clears.
- Builder renders; Listener executes prepared Flutter effects; Consumer is for
  a section needing both. Multi-case/substantial listener bodies use named UI
  methods with focused listenWhen. No requests or analytics in build.
- Use explicit authored forms, typed callbacks, super.key, eligible const,
  S.current and the existing design system. Extract substantial responsibilities
  into public widgets in their own files; do not fragment trivial UI pieces.
- UI owns Flutter controllers/focus/scroll and their disposal; flow selection,
  visibility and errors remain in State. Do not evade this with setState or
  parallel notifiers. Preserve relevant async and banking safeguards.

Before completion, review all code introduced or modified by the task against
the full contract, correct violations and run relevant checks. Passing tests or
analysis does not waive a style rule. Never claim complete compliance with a
known violation. If implementation is genuinely blocked, report the exact
conflict and leave that dependent change unimplemented; continue independent
authorized work without implementing a forbidden workaround.

Apply these requirements within the authorized task. They do not authorize
unrelated rewrites, dependency installation or design-system changes.

## Test Execution Scope

Owner instruction, 2026-11-01: run tests only for changed flows and directly
related consumers/dependencies. Select relevant regression files when a shared
change affects them. Do not run an unscoped `flutter test` or the complete
application suite unless the owner explicitly requests it. Historical full-suite
results are not permission to repeat that run. Report the actual scoped command
and result; keep required code/style reviews and relevant analysis.
