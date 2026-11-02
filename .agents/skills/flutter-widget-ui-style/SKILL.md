---
name: flutter-widget-ui-style
description: >-
  Apply Pishkhan's approved Flutter presentation conventions when writing,
  editing or reviewing screens, widgets, dialogs, listeners or Provider
  boundaries. Use the project's UI/Cubit/State contract as the authority.
---

# Pishkhan Flutter UI Style

Before planning, writing or reviewing feature UI, read the complete
[UI/Cubit/State contract](../../../doc/ui-cubit-state-agent-rules-en.md).
Its Mandatory Enforcement section, Section 2.3 and relevant detailed rules
control this skill. This checklist summarizes existing rules; it adds no new
patterns, exceptions or permission to rewrite unrelated code. For Cubit/State
work, also read [pishkhan-cubit-clean-code](../pishkhan-cubit-clean-code/SKILL.md).

## Ownership and flow entry

- Construct Cubit directly in the screen/flow's `BlocProvider.create`. Call its
  explicit initial action there only for an actual fetch or entry resolution.
  A constructor preserves supplied/default State; there is no creation helper
  or private Screen/View wrapper. Router selects destinations only.
- GetIt registers data/application dependencies, never Cubit/Bloc. Cubit resolves
  final Repository/UseCase fields; UI, route and child constructors do not
  forward them. UseCase class/file naming and DI wiring follow the contract.
- `Provider.create` owns disposal. Use `BlocProvider.value` to borrow that same
  instance across a real modal boundary; do not construct or close a borrowed
  Cubit there.
- Forward raw input or the actual non-null rendered selection to specific typed
  actions. Cubit/Domain owns validation, filtering, calculations, request
  construction, selection, modal-result interpretation and flow decisions.
- UI owns Flutter controllers/focus/scroll, attachment and disposal. It executes
  prepared effects and returns raw modal/platform results after a mounted check.
  Do not move transferable work into callbacks, listeners or lifecycle hooks.
- No `setState` or parallel notifier for flow selection, visibility or errors.
  Resource-only Flutter objects remain with their actual UI owner.

## Subscription and effect boundaries

Use the contract's Sections 11–12, rather than wrapping every widget in a Bloc:

| Responsibility | Composition |
|---|---|
| Render a coherent changing section | `BlocBuilder` |
| Execute one prepared Flutter effect | Focused `BlocListener` |
| Independent screen/flow listeners | `MultiBlocListener` with `BlocBuilder` rendering |
| Local section owning rendering and its related controller/modal effect | Focused `BlocConsumer` |

Do not keep a second screen-level Consumer under independent listeners. Local
Consumers may retain their actual carousel, scroll or modal ownership.

- Every Listener/Consumer has focused `listenWhen`. Multi-case or substantial
  async handlers are named widget/State methods, referenced beside the predicate.
- Request feedback follows each operation's terminal status transition. A
  retained failure/message is not a notification event. Show that failure's
  prepared text; defined success feedback uses localized success copy.
- Typed effects execute independently of message presence. Consume reusable
  commands before awaiting their Flutter operation. No effect counters or new
  generic effect framework.
- `buildWhen` is optional and must include every value that its section reads.
  Builders perform no requests, analytics or other side effects.
- Read the supplied `state` directly. Do not introduce aliases for its fields.
  A child receiving that selected State must not subscribe again to the same
  data. An independent section may own its own Builder. Preserve existing
  controller/subscription timing during extraction.

## Explicit widget composition

- Use block-bodied build methods, `super.key`, eligible `const` constructors and
  widgets, typed callbacks and explicit authored fields. Keep each field's
  label/value/error/specific action visible together.
- Extract substantial responsibility, actual reuse, lifecycle or a coherent Bloc
  section into a public widget in its own file. Do not use functions returning
  UI trees, private View wrappers, fixed-form schemas, parallel arrays or
  index-based field dispatch.
- Aim for about 200 lines per focused UI file. A cohesive 200–300-line file may
  remain together; review larger files for meaningful boundaries. This is not a
  reason to create a widget/file for every title, spacer or icon.
- Avoid default/manual test keys. Keep a key only for a concrete identity,
  reorder or measurement need under contract Section 18; explain that need.
- Use `const SizedBox` for literal spacing and the existing authored layout,
  theme typography, semantic colors, RTL/digit behavior and `S.current`.
  Display helpers may localize/format already-decided values; business
  calculations do not belong there.
- Reuse the installed public `avp_ui` API and app-shared widgets. Use `AvpImage`
  for displayed images and `AppConstants.baseImage` for app asset paths.
  `Text`, `ScaffoldMessenger`, Flutter layout and modal APIs are permitted by
  the contract; foreign Caltivita APIs are not this project's design system.
  Do not add a package or change the design system without task authorization.

## Forms, dialogs and navigation

- A loading-capable button uses `isLoading` for that operation and one `canX`
  flag for `onPressed`. Other controls use enabled/disabled availability. Do not
  repeat those UI preconditions as Cubit entry guards.
- Preserve independent operation statuses and actual pending-request Back gates.
  Cubit decides previous step, confirmation or exit; UI performs the prepared
  navigation. Keep banking identity, quote binding and stale-response safeguards.
- Use the existing public modal launcher plus public content widget pattern,
  with safe areas and keyboard insets when required. Launchers perform Flutter
  modal work only. A Confirm button may bind the specific Cubit action directly;
  Cancel/dismissal closes without invoking it.
- Await navigation/modal results when the defined flow needs them, check mounted
  and return the raw result to Cubit. Do not prescribe `.then` refresh chains or
  orchestrate the next flow action in UI. Existing router adapters translate
  prepared destination intents into routes.
- Retain supplied loading/empty/error surfaces and meaningful layout boundaries.
  This migration does not require a new shimmer system or new pagination.

## Completion review

Review every changed constructor, Provider, callback, listener, State reader and
extracted widget against the full contract. Tests/analysis do not waive a style
rule. Correct violations; report a concrete conflict rather than inventing an
exception. Run tests only for changed flows and directly related consumers,
plus relevant analysis. Do not run the full suite without explicit owner request.
Report actual commands/results and any unverified integration boundary.
