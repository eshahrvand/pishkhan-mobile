# UI, Cubit and State Coding Contract for the Team and Agents

**Project:** Smart Virtual Counter — `pishkhan_mobile`  
**Version:** 1.12 — Counter-free interactions and explicit feature ownership<br>
**Date:** 2026-10-25<br>
**Scope:** Presentation coding style, State management and readability rules  
**Status:** Authoritative coding contract. Historical examples do not override the mandatory ownership rules or the owner amendments below. Implementation status is recorded in the feature documentation.

This document turns the project owner's requirements and supplied examples into explicit rules. A team member opening a screen should be able to see how the UI is built, how State is read and how Cubit is called, without navigating through multiple wrappers and files to understand a simple form.

“Required” and “prohibited” in this document are owner-approved style instructions. Only sections explicitly marked “recommendation” or “pending review” remain unapproved; those labels never weaken a mandatory rule elsewhere. The approved principles consolidated in Section 2.3 are mandatory, not recommendations. This document does not authorize agents to change code automatically or automatically rewrite the [architecture document](architecture-smart-virtual-counter-v2-en.md) or the [current UI skill](../.agents/skills/flutter-widget-ui-style/SKILL.md). When styles conflict, the owner's explicit instructions recorded here take precedence over older examples. Boundaries and open decisions are recorded in Section 25.

**Interpretation rule:** An agent must not infer permission to introduce new abstractions, wrappers, parallel State or exceptions to prohibitions from “readability,” “cleaner code,” “extensibility” or possible future needs. Do not evade a prohibition by renaming the same pattern. Do not turn “allowed” into “mandatory for every screen.” If the required behavior truly cannot be implemented under this contract, report the specific issue rather than inventing a replacement rule.

**Mandatory owner update, 2026-10-17:** Any behavior, calculation or decision that
can be implemented in Cubit without Flutter UI resources **must be implemented
in Cubit** (with reusable business rules in Domain). Keeping it in a UI function,
callback, listener, builder or lifecycle hook is prohibited. Small size, a private
method name, navigation involvement or “only UI coordination” is not an exception.
Section 3.5 is the mandatory decision gate and overrides older permissive examples.
This instruction requires compliance in requested work; it does not authorize an
unsolicited refactor of the entire application.

**Owner amendment — UI-owned interaction gating:** UI owns whether a control
can invoke an action: use loading, enabled/disabled state and conditional controls.
Cubit actions MUST NOT repeat these preconditions with entry guards for
`editable`, `canContinue`, `canSubmit`, submission loading/success, known option
membership, an already-open draft, or data supplied by a rendered control.
Use non-null parameters for actual selected values and bind confirmation buttons
directly to specific actions. Do not move the same redundant check into a helper,
listener or generic wrapper. This supersedes the earlier requirement for defensive
Cubit submission/edit guards throughout this document and architecture Section 12.

Actual behavior remains explicit: form validation, choosing a step/action, Apply versus Cancel and optional entry-data resolution are calculations/flow decisions. Server authorization/idempotency remains at its existing boundary. There is no async disposal check of any kind (owner decision 2026-10-18; Section 8.3). A modal may directly bind its Confirm button to a Cubit
action; Cancel and dismissal simply close it without invoking that action.

## Mandatory Owner Amendment, 2026-10-18: Minimal Cubit Rules (override every example below)

The owner found that agents produce Cubits full of defensive guards, repeated
validation, default-State re-emits and speculative methods. The rules below
**override any example, snippet or older sentence in this document or in the
architecture document that appears to say otherwise.** They apply to code
introduced or modified by an authorized task; they do not authorize an
unsolicited rewrite of untouched code.

1. **No `isClosed`, anywhere.** Not in synchronous actions, not at the start of
   an async method, not in `.then`, Timer or stream callbacks, not in UI
   `finally` blocks. No `BaseCubit`, `safeEmit` or overridden `emit` (Section 8.3).
2. **No defensive guards in actions.** An action contains no `if (...) return;`
   on: a null/empty argument, a nullable State field that the UI flow guarantees
   (read it with `!`), `canSubmit`/`canContinue`,
   loading/success status, option membership, or an already-validated field.
   The only permitted early return is a real request-ID check (rule 11).
3. **Arguments from a rendered control are non-null.** Pass the rendered object
   (the card, the deposit) or a non-null value. Do not pass a bare/nullable ID
   that the Cubit must find again and then null-check.
4. **Validate once.** `updateX` runs **only X's own validator**, once, and stores
   `isXValid` and `isXError` together with the new value. An aggregate flag
   (`canRequestOtp`, `canSubmitLogin`) combines the current field's fresh result
   with the **stored** `isYValid` flags of the other fields. Never re-run another
   field's validator, never re-validate in `submit`, and use cases do not repeat
   checks the form already performed (Sections 6.2, 6.4).
5. **Emit only what the action changes.** Do not set a field to its default or
   its current value (`failure: null`, `status: initial`, `canSubmit: false`)
   unless this action is the one that must clear it.
6. **No initial action without a real fetch.** If a feature has nothing to fetch
   or resolve, the Provider is just `create: (_) => XCubit()`. An initial action
   never re-emits the default State.
7. **No dead code.** Every Cubit method and every State field has a caller/reader
   in the same change or an identifiable service contract (Section 5.5). Do not
   add "just in case" methods, pass-through helpers or duplicate State
   (`selectedId` **and** `selectedCard`).
8. **Buttons use `isLoading:`; `onPressed` checks one flag.** Pass the operation
   status to the button's loading parameter
   (`isLoading: state.xStatus == RequestStatus.loading`); the button ignores taps
   while loading. Write `onPressed: state.canX ? ... : null`. Do not add
   `!= loading` or `!= success` to `onPressed`: loading is covered by `isLoading`,
   and the success emit sets `canX: false`. A control without a loading parameter
   (for example a text field's `enabled:`) uses the status check instead.
9. **Naming.** Actions use the verb vocabulary and State fields use the naming
   scheme in Section 6.6. No `get*`, `set*`, `load`, `handle*`, `process*`, `init*`.
10. **Target level of simplicity.** One `emit` per user event; direct `state.x!`
    reads for fields the UI flow guarantees; a returned `.then` chain for async
    work; no guards. Not part of the target style: `catchError` in Cubit, nested
    `.then` pyramids, `dynamic` setters, and storage or connectivity calls
    inside the Cubit.
11. **Request ID only for real overlap.** Add `if (requestId != _requestId) return;`
    at the top of one callback **only** when two responses of the same operation
    can be in flight and the older one must lose (search-as-you-type, switching
    category/tab while loading). Not by default, never combined with `isClosed`.

**Accepted consequence of rule 1 (owner-approved):** the Cubit is released from
memory with its screen. If an HTTP response arrives after the screen has been
closed, the `emit` in its callback throws a `StateError` that appears in logs or
crash reporting as an uncaught async error; the user sees nothing. Agents MUST
NOT add a guard to avoid it, and MUST NOT report its absence as a defect.

## Mandatory Owner Amendment, 2026-10-25: Counter-Free Interactions and Ownership

The owner explicitly removed effect sequence counters from the project.
This supersedes every older example or requirement for effectId/navigationId
below. Do not replace them with another counter, timestamp, random ID or identity
wrapper. Keep real record IDs and request IDs for genuine response overlap. This also
removes old UI sequence aliases such as scrollId, stepRevealId, detailRequestId,
saveId, minimumHomeNoticeId, addressSavedId and draftSavedId: observe actual step,
terminal request status, saved data or an explicitly consumed command instead.

- Request failures publish the shared latest failure and prepared message.
  Focused listenWhen predicates compare each operation's previous/current status
  and react when it enters failure. A loading emit clears the previous message.
  Do not create a message effect or a message counter for request failures.
- Sheets, dialogs, share and navigation react to actual changes in their typed
  effect/destination fields. Listeners ignore null/consumed commands. The flow
  receives an explicit interaction-consumption event when UI accepts a reusable
  command, clearing that command before the Flutter operation is awaited. This
  permits another identical interaction after dismissal without event IDs and
  avoids clearing a newer command after an asynchronous modal result.
- Consumption is a real flow action with an explicit copyWith, not a generic
  State-publication wrapper. Exit intents that authorize PopScope remain set
  until navigation disposes the flow; never clear them before the authorized pop.
  Raw modal results still return to the existing specific Cubit action.
- Every new UI command clears an old display message, so a navigation/sheet event
  cannot replay a previous request-error notification. Concurrent requests retain
  independent statuses and each entering-failure transition is observed.
- Cubits do not live under shared. A reusable service used by multiple flows has
  its own feature/flow folder. Logic used only by a parent service belongs to its
  owning flow rather than an incidental shared Cubit. Postal office lookup is
  used by clearance and cancellation and therefore owns features/postal_offices.
- App-owned image paths are written directly with AppConstants.baseImage from
  core/config/constant.dart. The actual prefix is assets/images/. Do not restore
  AppAssets or feature alias registries. Package-owned design-system assets stay
  in their package.
- The reusable pure Presentation failure-message mapper lives in
  core/presentation/mappers/request_error_message_mapper.dart, not shared or
  Domain/Data. Feature-specific Login messages may retain their existing helper.

## Mandatory Owner Amendment: Project-Wide Request Messages and Loading

The owner explicitly requested adoption across all existing Cubits and confirmed
that system and in-screen Back must be blocked during any pending request.
This amendment supersedes the former Login-only scope and the ordinary-flow
Back exception in Section 20.2, plus conflicting operation-Failure naming and
Presentation message rules in Sections 3, 6.6, 8.4, 13.0 and 21.6.

- Keep independent operation statuses. Request-driven States hold one latest
  `Failure? failure` and one prepared `String? message`; do not add messageId.
- Cubit emits the latest failure and a message prepared by a pure Presentation
  switch helper; listeners observe entering-failure status transitions.
  Repeated identical failures must notify again. Concurrent operation responses
  keep their own statuses and each failure delivers its own message snapshot.
- Reuse actual operation/effect State changes. Do not introduce generic State-publication wrappers,
  a separate message counter or a parallel notifier. Clear failure/message when
  starting a request without publishing a message effect. Other effects must not
  replay an old message. UI listeners only display prepared text, and remove
  duplicate inline API-error notifications while retaining retry/empty sections,
  actual field validation and meaningful business outcomes.
- All request-driven flows gate system and in-screen Back while any of their
  operations is loading. The UI owns this gate; do not add Cubit action guards.
  Keep cancellation/exit confirmation behavior after loading finishes.
- Loading-capable buttons use `isLoading`; `onPressed` uses one eligibility flag
  where present. Relevant concurrent pending operations may contribute to the
  loading parameter. Controls without loading support use enabled/callback gates.
- Cubits without requests receive no ceremonial status, failure or message
  fields. Unconnected Login guest actions keep their existing behavior; this
  migration does not fabricate API calls or turn unavailable actions into requests.

### Historical Login-Specific Details (retained where applicable)

The owner explicitly approved the following changes for the existing **Login
API flow only**. Unconnected services, including guest change-phone, retain
their previous unavailable behavior and are outside the new message path.
The project-wide amendment above now extends the shared failure/message and
loading behavior to other request-driven features. Other Minimal Cubit Rules
remain unchanged.

1. Keep independent CAPTCHA, OTP-request and verification statuses, but retain
   **one shared `Failure? failure`**: the latest failure of the Login flow.
   Starting a new request clears the previous failure and prepared message.
   Separate `<operation>Failure` fields are not required in Login.
2. Add `String? message` to the plain Freezed State, without a separate message
   counter. On each API failure notification, Cubit explicitly emits the failure,
   prepared message in the same copyWith. The Listener observes entering-failure
   status transitions. The message is a display payload, not a
   second technical error code. Do not add messageId to State.
3. A focused pure function such as `getAuthErrorMessage(Failure failure)` in
   `presentation/login/cubit/auth_error_messages.dart` maps known error codes
   through a switch to owner-approved Persian text, with a generic fallback.
   Cubit calls it inside the failure emit. It returns only String; it never
   creates/publishes State or uses Flutter resources. Explicit Persian error
   literals in this helper and prepared error messages in Login State are
   approved. Ordinary labels and field-validation text still use S.current;
   no localization dependency or text is introduced in Domain/Data.
4. The existing BlocListener filters operation-status transitions and actual
   changes in pending interaction fields. Its named handler displays the prepared
   message for request failures. It does not map codes, translate the message or
   render a second inline copy of the same API error. Loading between attempts
   permits repeated identical failures without a sequence counter.
   Clearing message or unrelated State updates must not replay the effect. No
   separate message Listener/counter or new handling for unconnected services.
5. Keep `Future<Result<T>>` at the Repository boundary and the returned `.then`
   plus Success/Err switch in Cubit. HTTP 200 does not establish bank success.
   Data maps `status: -1, message: WRONG_CAPTCHA` to
   `Err(DataFailure('auth.wrong_captcha'))`; raw server messages are not displayed.
   Unknown business rejection retains the generic failure/fallback. Do not turn
   ordinary bank rejection into a DioException or add catchError to Cubit.
6. **Back is unavailable while any Login request is loading**, including CAPTCHA,
   OTP request and verification. UI gates system/in-screen Back consistently;
   Cubit does not duplicate the gate with defensive action-entry checks. This
   policy now applies to every request-driven flow under the amendment above.
7. The OTP resend button uses `isLoading` for pending verification and only
   `canResendOtp` in onPressed. It does not introduce a fictitious resend endpoint
   or status: resend still returns to identity and fetches a fresh CAPTCHA.
8. Keep the CAPTCHA image and its SessionId together in LoginCaptcha. Do not
   duplicate sessionId in AuthState. Cubit constructs the request with
   `state.captchaImage!.sessionId` after UI eligibility guarantees a fetched pair.
   Clearing/replacing the model clears/replaces the pair atomically; no fallback
   identifier or redundant null guard is added.

## Owner-Approved Network Diagnostics

The owner explicitly requested complete terminal visibility for outgoing and
incoming API data. The shared bank Dio logging interceptor may print full URLs,
headers and bodies, including credentials, OTP/CAPTCHA and banking/identity data,
without masking or length truncation. The owner explicitly enabled Release
terminal diagnostics for troubleshooting on 2026-10-25. The shared
`AppConstants.apiLoggingEnabled` switch is controlled by `API_LOGS` and currently
defaults to true in all build modes; use `--dart-define=API_LOGS=false` to disable
it. The factory and interceptor use the same switch. All shared-client requests
and failures, including local interceptor rejections, use these diagnostics.
This is an explicit temporary extension of the previous Debug-only scope.
Cubit/State logging remains unchanged. The owner separately authorized removing
the unconfigured-pinning Release request blocker for current team review builds;
ordinary HTTPS certificate validation remains enabled. See architecture §9.4. Live upload/response streams are not consumed
by the formatter; multipart logs contain fields and file metadata.

## Mandatory Enforcement for Every Agent

This is the single authoritative project style contract for UI, Cubit, State,
Provider composition and their dependency boundaries. Read it before planning,
writing or reviewing affected code. The root [AGENTS.md](../AGENTS.md) makes this
an entry requirement for agents; reading a skill or a historical example does
not replace reading this contract.

**MUST** and **MUST NOT** are binding. “Prefer”, “default” or “usually” in an
older example MUST NOT be used to bypass a mandatory rule. Explicitly allowed
cases define the rule's scope; they are not permission to invent new exceptions.
Only an explicit owner instruction changing the specific rule can amend it.
An ordinary implementation request does not implicitly authorize a deviation.

Agents MUST NOT:

- Substitute their own architecture or coding preferences for this contract.
- Treat existing noncompliant code, a framework convention, a skill example,
  convenience in tests, speed, fewer lines or future extensibility as permission
  to violate a rule.
- Rename, wrap or relocate a prohibited pattern to make it appear compliant.
- Shift flow logic into a callback, lifecycle hook, UI helper, listener handler,
  notifier, mapper or router adapter instead of its required owner.
- Mark work complete with a known violation in code introduced or changed by
  that work, or describe partial compliance as full compliance.

Before implementation, assign every behavior to Cubit/Domain or the specific
Flutter-only UI operation that requires it. After implementation, review every
changed constructor, Provider, callback, listener, State field and extracted
widget against this contract and correct violations before completion. Relevant
analysis/tests verify behavior; passing them does not waive a style rule.

If a specific requirement cannot be implemented within the contract, report the
concrete conflict and leave that dependent change unimplemented; continue other
independent authorized work. Do not implement a forbidden workaround while
waiting, silently relax the rule, or request routine permission to bypass it.

These requirements apply to all code introduced or modified within the user's
authorized task. They do not authorize unrelated project-wide rewrites or imply
that untouched historical code has already been brought into compliance.

## Contents

1. Requirements and main decisions
2. What does the reference example establish?
3. Responsibilities of UI, Cubit and State
4. File structure and naming
5. State contract
6. Cubit contract and field-update methods
7. Calculations and dependent fields
8. Async operations, failures and stale responses
9. BlocProvider inside the screen
10. Direct State use in UI
11. buildWhen and listenWhen
12. Subscription boundaries and passing State to children
13. Widget-tree coding style
14. Splitting screens and public widgets
15. Display conditions and title/text helpers
16. Filtering, selection and lists
17. Dialogs and bottom sheets
18. Keys and UI tests
19. Controllers, focus, timers and lifecycle
20. Multi-step flows and Back
21. Shared design, RTL and localization
22. Review of current project examples
23. Common mistakes and proposed corrections
24. Agent instructions and review checklists
25. Differences from existing documentation and adoption path

## 1. Requirements and Main Decisions

| Topic | Approved rule |
|---|---|
| Creating the screen Cubit | Construct Cubit directly inside `BlocProvider(create: ...)`; never register or resolve Cubit through GetIt; no `_createCubit`/`_buildCubit` wrapper or extra Screen/View |
| Initial action | Only when the feature has a real fetch or entry resolution; otherwise `create: (_) => XCubit()`; never re-emit the default State |
| `isClosed` / BaseCubit | Prohibited everywhere; no `safeEmit`, no overridden `emit` (Section 8.3) |
| Validation | Each input action validates only its own field, once; aggregates read stored `isXValid` flags (Section 6.4) |
| Repository ownership | Register Repository/service/API dependencies in GetIt; Cubit resolves its own dependencies in fields; no dependency parameters in UI or Cubit construction |
| Resolving Cubit | `context.read<MyCubit>()` using a context below the Provider |
| State | One plain Freezed data class, without handwritten getters or logic |
| Initial value | A readable `State.initial(...)` constructor; only one factory |
| Rendering | Read `state.field` directly in widget arguments |
| Loading | Compare `state.submissionStatus == RequestStatus.loading` directly |
| Transferable logic | Every decision/calculation independent of Flutter UI resources belongs in Cubit/Domain, including interaction orchestration and request construction |
| Display-state changes | Even password visibility and section expansion belong in Cubit/State; routine `setState` use is prohibited |
| Fixed forms | Explicit fields like the owner's example; parallel arrays and index-based dispatch are prohibited |
| Text depending on multiple steps | A named UI function returning `String` |
| Side effects | Cubit decides and publishes typed effect data; UI listener executes Flutter effects and returns results to Cubit |
| UI rebuilding | `BlocBuilder` around a meaningful changing section; no mandatory builder for each widget |
| Repeated side effects | `BlocListener` with precise `listenWhen` |
| Splitting UI | Usually around 150–200 lines or when a section is actually reused |
| Extracted widgets | A public, clearly named class in its own file |
| Extra wrappers | Prohibited, especially `_ScreenView` introduced only to sit below a Provider |
| UI-building functions | `_content`, `_body` and `_footer` methods returning widget trees are prohibited |
| Keys | Default: do not add them; use only for a specific behavioral need, explained near the code |
| Unfamiliar widgets | Check the public `avp_ui` API first; do not invent abstractions on the agent's initiative |
| Change scope | No broad refactoring, package changes or dependency installation without an explicit request |

Readability is not measured solely by fewer lines. A few clear repeated lines are more acceptable than a generic mechanism with multiple callbacks and obscure data types.

## 2. What Does the Reference Example Establish?

### 2.1 Accepted Patterns from the Example

- Specific methods such as `updatePhoneNumber`, `updateOtp` and `submitOtpRequest`.
- Explicit, traceable `emit(state.copyWith(...))` calls.
- State containing field values, request statuses and action eligibility.
- Provider creation inside the screen, followed by Listener and Scaffold.
- Direct State reads in arguments, without converting State into another ViewModel.
- `buildWhen` and `listenWhen` at the consumption point.
- Widgets familiar to the team and the existing design-system package.
- Extracting a form, OTP section or substantial flow section, without splitting titles, spacing and icons into independent files.

### 2.2 Patterns Not to Copy Verbatim from the Other Application

The supplied style example is a style reference; it does not define this project's network, storage or security contracts.

| Reference pattern | Decision for this project |
|---|---|
| Dependency lookup | Resolve registered Repository/service/UseCase inside Cubit fields; never in UI or router |
| `S.current` | Approved direct localization access; implementation belongs to a separate task |
| A shared enum containing `otpSubmitting` and `authLoading` | Independent operations use independent statuses with the existing `RequestStatus` |
| Two emits for an input and button eligibility | Prefer one emit for a complete, consistent snapshot |
| `void ... async` | Awaitable operations use `Future<void>` and the project's returned `.then` style (Section 8.1) |
| `isClosed` check after await | Not used anywhere in this project (owner decision 2026-10-18); the Cubit is released with its screen (Section 8.3) |
| Controllers in StatelessWidget and static focus nodes | A StatefulWidget owns the lifecycle and disposes resources |
| Printing OTPs or PINs | Prohibited; sensitive data must not enter logs |
| Storing raw passwords or a fallback such as `0000` | Do not incorporate this into the project's contract |
| Updating UI after a callback using old State | Read the action result or fresh State value |
| OTP examples using lengths 4, 6 and a `> 4` check | Determine the permitted length from the service contract and use it consistently |

These differences do not change the team's preferred style; they prevent lifecycle and behavioral defects from spreading.

**Latest owner clarification, 2026-10-17 — supersedes the earlier Cubit factory
registration guidance:** GetIt is the registry for data/application dependencies,
such as Repository interfaces, REST API clients, services and actual UseCases.
DAOs may be registered if the project actually uses them. The supplied other-app
locator is a pattern reference, not permission to copy its packages or add layers.

**Cubit and Bloc must never be registered in GetIt**, through `registerFactory`,
`registerFactoryParam`, singleton, lazy singleton or any equivalent mechanism.
Do not resolve a Cubit using `getIt<MyCubit>()`/`sl<MyCubit>()`. This rule applies
to screen Cubits, flow Cubits and Cubits used inside sheets or sections.

Create each new Cubit directly inside the owning `BlocProvider.create` callback.
That Provider owns its lifetime and closes it when the screen/flow scope is
removed. Ordinary rebuilds preserve that instance. If several screens share a
flow, place one Provider at their actual common flow boundary; do not create one
Cubit per child. `BlocProvider.value` only exposes an existing instance to a
modal or another consumer; it never creates a replacement.

**Latest owner clarification — supersedes Provider-side injection and the older
constructor-injection examples:** Repository, REST/service and actual UseCase
dependencies are resolved inside Cubit fields through the existing GetIt instance.
Do not pass them to Cubit constructors, screen constructors, route arguments or
child widgets. UI and router do not resolve or call data dependencies.

```dart
class CardFeaturesCubit extends Cubit<CardFeaturesState> {
  CardFeaturesCubit({
    CardFeaturesState initialState = const CardFeaturesState.initial(),
    this.initialCategory,
  }) : super(initialState);

  final repository = getIt<CardsRepository>();
  final CardCategory? initialCategory;
}

// Inside CardListScreen.build:
BlocProvider<CardFeaturesCubit>(
  create: (_) => CardFeaturesCubit(initialCategory: initialCategory)..fetchCards(),
  child: ...,
)
```

GetIt still never registers Cubit/Bloc. Only dependencies are registered at
startup. Reading a registered dependency in a field does not authorize loading,
emitting, starting timers or computing derived State during construction.

Screen-owned Providers belong at the top of their screen/flow widget. Keep
GoRouter responsible for destination selection and typed navigation inputs;
do not put screen Cubit creation or dependency wiring into route builders.
Tabs under Home share the single HomeCubit owned by DashboardScreen. For an
actual multi-screen flow, put the shared Provider in its feature-owned flow
widget rather than the central router. Do not duplicate that Cubit in children.

Do not add `_create`, `_createCubit`, `_buildCubit` or equivalent production
construction helpers. Keep the constructor and initial action visible in create.

**Listener readability:** when a listener has a multi-case effect switch or a
substantial async body, extract it to a named method such as `_handleEffect`
on the owning widget/State and use `listener: _handleEffect`. Keep listenWhen
next to the listener. This method only executes Flutter effects and forwards raw
results to Cubit; transferable business decisions still belong to Cubit. Small
single-effect listeners may remain inline. No generic dispatcher or extra UI
wrapper is required just to extract a listener method.

### 2.3 Consolidated Mandatory Principles

The owner approved the architecture, dependency, lifecycle, action, subscription
and UI coding principles reviewed from the external reference project (former reference Sections
**2, 3, 4, 6, 7 and 8**). Their complete normative meaning is recorded here.
The temporary English and Persian review documents have been removed. This
contract is self-contained; agents MUST NOT depend on those drafts or reinterpret
source implementation exceptions as target rules.

| Area | Mandatory rule | Prohibited interpretation |
| --- | --- | --- |
| Architecture | One screen/feature-flow owns its Provider; its actual shared steps consume the same Cubit. UI renders State and sends specific actions. Domain retains reusable business rules. | Extra Cubits per child, UI flow coordinators, request-building callbacks or unnecessary new layers |
| GetIt | Register only actual Repository, service/API, DAO or UseCase dependencies. Resolve required dependencies in Cubit fields. Immutable dependency references MUST use final unless replacement is an actual authorized behavior. | Cubit/Bloc registration of any lifetime; resolving Cubit from GetIt; dependency arguments in UI or Cubit constructors; UI/router data lookups |
| Construction | Construct Cubit directly in screen/feature-flow BlocProvider.create and invoke an explicit initial action there only when the feature has a real fetch or entry resolution. Keep its supplied/default initial State unchanged during construction. | Route-owned screen Cubit, _createCubit helpers, hidden construction wrappers, constructor emit/load/timer/derived-State initialization |
| Lifetime | Provider.create owns closing. Existing flow consumers read the shared instance. Provider.value only exposes an existing instance across a real boundary such as a modal. | New Cubit in value, manually closing a borrowed Cubit or duplicate construction on ordinary rebuilds |
| Actions | Specific typed actions own transferable calculations, validation, request construction and flow decisions. Write emit(state.copyWith(...)) in the action. Publish dependent values consistently. | Generic string/index field dispatch, State publication intermediaries, UI reconstruction of requests or hidden State getters |
| Async | Operations that callers can await return Future<void> through a returned `.then` chain (no async/await, no catchError in Cubit); handle Result with a switch inside `.then`; no isClosed anywhere; a request-id check only for a real overlapping-response case; UI controls interaction availability; keep server idempotency. | Copying nested void Future chains, any isClosed check, catchError for expected failures, or defensive guards that repeat what UI/validation already guarantees |
| Rendering | BlocBuilder renders a cohesive changing section. A child receiving the parent's selected State MUST NOT add a duplicate subscription to the same data. Rendering MUST NOT start requests. | Load/submit/analytics in build, ceremonial builder per Text/Icon, duplicate nested builders or business rules hidden in buildWhen |
| Effects | BlocListener executes prepared Flutter effects. BlocConsumer is used when the same section needs both rendering and a side effect. MultiBlocListener groups actually independent effects. | Flow decisions in listeners, mandatory Consumer/MultiBlocListener everywhere or a new generic effect framework without a concrete need |
| Listener methods | Every multi-case effect switch and substantial async listener body MUST be a named widget/State method referenced by listener. Keep its focused listenWhen adjacent. | An inline multi-case listener or moving eligibility/request/navigation-intent decisions into the named UI method |
| UI structure | Use explicit widget composition and block-bodied build methods. Fixed forms show each field's label, value, error and specific action together. | Widget-tree helper methods, private Screen/View wrappers, schema/array/map/record renderers for fixed forms or compression hiding responsibilities |
| Widget boundaries | Extract substantial responsibilities or actual reuse into public, meaningfully named widgets in their own files. Preserve their subscription/resource boundaries. | A new widget/file for every title, spacer or icon; arbitrary fragmentation; treating source line counts as a mandatory exact limit |
| Style | Use PascalCase classes, snake_case files, camelCase methods, super.key, const where eligible, typed callbacks, S.current and the target project's theme/design-system conventions. | Function?/dynamic for known callback/input types, copying visual tokens/APIs/assets from the reference project or inventing unavailable package components |
| Modals/resources | A modal launcher only invokes the Flutter modal API with prepared inputs and a public content widget. Handle safe area and keyboard insets where required. UI owns and disposes controllers/focus/scroll. | Flow/request logic in launchers, moving Flutter resources into State/Cubit, duplicate selection in setState/notifiers or a fresh modal Cubit replacing an existing shared flow |

**Existing State structure MUST be preserved:** one plain Freezed State with
`.initial`, its current `part of` organization, the existing RequestStatus enum,
meaningful nullability and useful non-null defaults. Do not rename/restructure
State to imitate the source or introduce its dynamic edit buffer, nullable
statuses or local selection copies. Preserve independent statuses for actual
independent operations; do not add ceremonial fields to operations that do not
exist. This preserves structure, not a guarantee of every historical update.

**Dependency setup in tests:** install controlled dependency registrations
before constructing Cubit, then close test-owned Cubits and reset the test
locator afterward. Replacing a registration does not replace an instance already
retained in a Cubit field. Tests MUST NOT add production repository constructor
overrides, register Cubits or introduce production Cubit factories for convenience.
This does not require tests for every trivial edit or runtime dependency-replacement
APIs throughout the application.

The remaining source review topics were explanatory or unapproved. They create
no additional requirements or migration permission. No source-specific health,
subscription, network, naming or implementation behavior overrides these rules.

## 3. Responsibilities of UI, Cubit and State

### 3.1 State: Data and Status Owned by the Flow

State stores:

- Input values;
- Received data;
- The current step;
- Independent request statuses;
- Selection, filtering and calculation results needed by UI;
- Field errors and Failure;
- Receipts and operation outcomes;
- Mutable display state such as `isPasswordVisible` and `isSummaryExpanded`;
- Meaningful operational data, such as a confirmed request snapshot, when the flow contract requires it.

State **does not perform** calculations, validation, localization, navigation, repository access or widget construction.

### 3.2 Cubit: Decisions and State Changes

Cubit is responsible for:

- Validation through validators and use cases;
- Determining `canSubmit`, `canContinue` and eligibility;
- Changing steps and retaining or clearing dependent data;
- Filtering data, resolving selections and calculating totals;
- Calling use cases/repositories;
- Publishing availability/loading data for UI gating;
- Managing timers owned by the flow;
- Building action/service requests and preserving the selected record context;
- Choosing available operations, footer actions, destination intents and back/exit behavior;
- Deciding when an action sheet, details view, confirmation or category reveal is needed;
- Interpreting sheet/dialog results and deciding the next action.

Business logic reused by multiple consumers remains in Domain. “Move logic into Cubit” does not mean moving all banking rules from UseCase into Cubit. Cubit coordinates form behavior.

### 3.3 UI: Layout, Rendering and Flutter Interaction

UI is responsible for:

- Building the widget tree;
- Choosing localized text, colors and spacing (Login request errors arrive as prepared messages under the scoped owner amendment);
- Owning and disposing Flutter focus, scroll and controller resources;
- Executing the dialog, sheet, snackbar, navigation or host callback requested by Cubit;
- Returning raw interaction results to Cubit without interpreting flow behavior;
- Calling Cubit actions in response to user interaction.

“UI owns rendering” does not permit storing display booleans in a Flutter State class and changing them with `setState`. Those values live in Freezed State, and their actions live in Cubit. Controllers, focus and scroll are Flutter resources with a UI owner and explicit lifecycle; do not move these resources into data State.

### 3.4 Where Logic Belongs

| Example | Location |
|---|---|
| Is the mobile number valid? | Pure validator; form outcome in Cubit |
| Does the total fee exceed the balance? | Cubit/Domain; result in State |
| Which cards match the search? | Cubit |
| What is the next step? | Cubit |
| What is the Persian title of the current step? | UI display helper |
| What color is error text? | UI and design token |
| Scroll to the top after a step change | Cubit decides the reveal intent; UI listener executes the scroll |
| Close a sheet | UI |
| Show or hide the password? | State field and Cubit action; UI renders the value |
| Display a password-mismatch error? | Validation and error field in Cubit/State; focus-loss event from UI |
| Store and retrieve tokens | Authentication infrastructure, outside widgets |
| Track a screen or click | A defined side-effect location; never a repeatedly executed build |

### 3.5 Mandatory Gate: No Transferable Logic in UI

**Required for every new or edited UI function and callback:** examine each
statement, not just the function's name. If it can execute using plain values,
State and injected dependencies without `BuildContext`, widgets, controllers,
render objects or Flutter lifecycle APIs, it belongs in Cubit/Domain. Split mixed
functions: move their decisions to Cubit and leave only the necessary Flutter
operation in UI. Adding an unused context parameter does not make logic UI-owned.

This rule applies equally to public/private methods, inline closures, extracted
widgets, `BlocBuilder`, `BlocListener`, modal launchers and lifecycle hooks.
Moving `_request` into `onPressed` or a listener is not compliance.

**Prohibited in UI:**

- Constructing `CardFeatureRequest`, submit payloads or other flow requests;
- Resolving a record, filtering/searching data, normalizing input for business
  decisions, validating, calculating fees or deciding eligibility;
- Mapping the selected category to `footerAction`, choosing which service to
  start, or interpreting a chosen action to decide the next screen/sheet;
- Deciding whether Back changes a step, requests confirmation or exits;
- Chaining flow actions after awaiting a modal, such as “details opens details,
  otherwise submit/navigate,” instead of returning the result to Cubit;
- Deciding which category should be revealed or when a flow-driven focus/scroll
  should occur. UI only resolves the supplied target against actual layout.

**Required interaction path:**

1. UI forwards the event and the necessary raw input to a specific Cubit action. Pass the rendered object (e.g. the card) or a non-null value, not a bare ID that the Cubit must look up again and null-check.
2. Cubit validates the event, resolves data, updates dependent State fields and
   constructs any request. It publishes a typed effect when Flutter work is needed.
3. `BlocBuilder` renders State directly. `BlocListener` with precise `listenWhen`
   executes an already-decided effect. It must not repeat the action/category
   rules or reconstruct the request.
4. After a modal or platform operation, UI checks lifecycle safety and returns
   the result to a Cubit action, unless the modal directly binds its confirmed
   button to the specific action. Cubit decides the continuation.

Effects contain plain immutable data, meaningful targets and prepared payloads;
never callbacks, `BuildContext`, widgets or controllers. Reusable interactions
are explicitly consumed back to null and observed through previous/current
State comparisons; sequence counters are prohibited. A single effect field is for ordered interactions; if effects
can overlap, design their delivery so an earlier result cannot replace newer
flow decisions. Keep UI interaction gating. There is no disposal/stale-response guard (Section 8.3).

A listener may switch on **effect type** to execute the requested Flutter API.
It must not switch on the user's action/category to determine a service. The
existing router translates destination intents/service IDs into concrete routes;
Cubit never calls `context.push`, `ScaffoldMessenger` or a modal API. Host callback
presence may be checked by the UI adapter, but its payload and intended operation
must already be supplied by Cubit.

**Narrow UI-only work remains:** widget construction; localization and display
formatting of an already-decided value; theme/layout/viewport measurements;
controller attachment, disposal and synchronization from State; `mounted` and
`hasClients` guards; and execution of focus, scroll, navigation or modal APIs.
An existing display helper may localize an enum or format an amount, but must not
decide the operation or calculate that amount. Do not move `S.current` or Flutter
resources into Cubit to satisfy this rule.

A tiny adapter that only invokes a Flutter API is allowed. An adapter that also
contains transferable logic is prohibited regardless of its length. Do not add
wrappers, artificial effects for static decoration, or dependencies merely to
make the code resemble this pattern. During review, identify the exact Flutter
operation that requires each remaining UI helper; “readability” is insufficient.

## 4. File Structure and Naming

Proposed structure for one service:

```text
lib/features/auth/
  domain/
    repositories/
    usecases/
  data/
    repositories/
  presentation/
    login/
      cubit/
        auth_cubit.dart
        auth_state.dart
        auth_cubit.freezed.dart        # generated
      screens/
        auth_screen.dart
      widgets/
        login_form_widget.dart
        otp_widget.dart
```

Service directory names follow the architecture. Generated files are not edited manually.

### 4.1 Class and Method Names

```dart
class AuthScreen extends StatefulWidget { ... }
class LoginFormWidget extends StatelessWidget { ... }
class OtpWidget extends StatefulWidget { ... }

void updatePhoneNumber(String value) { ... }
void updateNationalId(String value) { ... }
void updateOtp(String value) { ... }
Future<void> submitOtpRequest() { ... }
Future<void> submitLogin() { ... }
```

An action name must explain its behavior. Names such as `process`, `handle`, `apply` or `update` without identifying the subject are insufficient.

Declare fields separately and readably:

```dart
final String? initialDepositNumber;
final VoidCallback? onAssistantPressed;
final ValueChanged<CertificateReceipt>? onCompleted;
```

Combining several unrelated fields into one compact declaration is not this contract's default style.

## 5. State Contract

### 5.1 One Plain State, One Factory

To match the owner's example, the initial constructor is named `initial`. This is only the name of a data constructor; State is not split into `loading/success/error` unions.

```dart
// auth_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

// AuthCubit is defined in this same file.
```

```dart
// auth_state.dart
part of 'auth_cubit.dart';

enum AuthStep {
  identity,
  otp,
}

@Freezed(toStringOverride: false)
abstract class AuthState with _$AuthState {
  const factory AuthState.initial({
    @Default(AuthStep.identity) AuthStep step,
    @Default(RequestStatus.initial) RequestStatus otpRequestStatus,
    @Default(RequestStatus.initial) RequestStatus loginStatus,
    @Default('') String phoneNumber,
    @Default('') String nationalId,
    @Default('') String otp,
    @Default(false) bool isPhoneNumberValid,
    @Default(false) bool isNationalIdValid,
    @Default(false) bool isPhoneNumberError,
    @Default(false) bool isNationalIdError,
    @Default(false) bool isOtpError,
    @Default(false) bool canRequestOtp,
    @Default(false) bool canSubmitLogin,
    @Default(0) int remainingSeconds,
    Failure? otpRequestFailure,
    Failure? loginFailure,
  }) = _AuthState;
}
```

Examples illustrate the proposed pattern; they are not ready-to-replace project files. Domain imports, use cases and localization keys must match the actual service. `AuthState` and `AuthCubit` in these examples are teaching definitions and have not been added to the application.

**Owner review after the reference comparison:** the current State structure is
retained. The reference uses an unnamed State factory and a separate State
library; those organizational differences do not require a migration here.
Do not copy nullable statuses or a dynamic edit buffer merely for source parity.

### 5.2 Prohibited: Handwritten Getters and Logic in State

```dart
// Prohibited
const AuthState._();

bool get isLoading => loginStatus == RequestStatus.loading;

bool get canSubmit => otp.length == 4 && remainingSeconds > 0;

List<ListedCard> get visibleCards => cards.where(...).toList();
```

Instead of an `isLoading` getter, UI compares the status directly. `canSubmitLogin` and `visibleCards` are data calculated in Cubit and stored as fields.

Generated accessors, `copyWith` and Freezed equality are infrastructure; this prohibition does not apply to them.

### 5.3 Defaults and Nullability

```dart
@Default(false) bool termsAccepted,
@Default(0) int totalRial,
@Default(<ListedCard>[]) List<ListedCard> cards,
ServiceBankCard? selectedCard,
Failure? failure,
```

- Use a non-null default for a known value.
- `null` is meaningful for “not selected yet.”
- `bool?` is prohibited for ordinary yes/no state.
- Do not conceal an unknown monetary value with a fabricated zero; use `int?` or an explicit data status when needed.
- Lists and models inside State must be immutable and have appropriate equality.

### 5.4 Independent Status for Each Operation

```dart
@Default(RequestStatus.initial) RequestStatus catalogStatus,
@Default(RequestStatus.initial) RequestStatus quoteStatus,
@Default(RequestStatus.initial) RequestStatus submissionStatus,
```

Do not combine these statuses into a large enum such as `quoteLoading / submitLoading / quoteSuccess / submitSuccess`. `step` and business outcomes are distinct from the request lifecycle.

### 5.5 Current Fields, Future Service Contracts and Unjustified Fields

Every field needs an identifiable use or responsibility. **Direct UI consumption is not a prerequisite for every field.** Fields needed for real-service integration, retries or the operation lifecycle may remain even when the current UI does not read them. The operation, contract or specific reason must be identifiable.

```dart
// Allowed when the submission operation and its future integration are defined.
@Default(RequestStatus.initial) RequestStatus submissionStatus,

// Allowed when the flow must retain the exact confirmed snapshot for submission/retry.
IssuanceRequest? confirmedRequest,
```

- Do not remove a field that has an identifiable operational purpose (retry snapshot, service contract) merely because the UI does not read it. A field with no purpose and no reader is dead code and MUST NOT be added (owner amendment, rule 7). Do not add ceremonial status fields to every Cubit because “they might be needed later.”
- A tab-selection State without async operations does not need RequestStatus merely because a template includes it.
- Calculated results, display state or errors needed by UI must be read from State. Missing consumption may be a UI defect to investigate, rather than a reason to automatically delete the field.

### 5.6 A Request Model Is Different from Form State

`CardIssuanceState` represents flow state. `IssuanceRequest` is a submission data model that **may be a field inside State**. Do not confuse the two.

```dart
// UI consumption of form State
value: state.draft.depositId,
isLoading: state.submissionStatus == RequestStatus.loading,

// Operational consumption inside a Cubit action
final request = state.confirmedRequest;
```

There is no blanket rule to move every request out of State. A confirmed, retryable snapshot may remain in State; a temporary request may also be constructed from State data during submit. Preserve the existing flow contract. Do not interpret this document as permission to relocate request models or rewrite UI. `confirmedRequest` in the example is an explanatory name, not an instruction to rename the current field.

## 6. Cubit Contract and Field-Update Methods

### 6.1 Readable Constructor and Cubit-Owned Dependency Lookup

```dart
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    AuthState initialState = const AuthState.initial(),
  }) : super(initialState);

  final requestOtpUseCase = getIt<RequestOtpUseCase>();
  final submitLoginUseCase = getIt<SubmitLoginUseCase>();

  Timer? _timer;
}
```

`initialState` remains for compatibility with the project's contract and tests. Ordinary UI need not pass the default State every time. A real entry parameter such as `initialDepositNumber` is different from a complete State snapshot.

Adopt the plain State structure, explicit methods and Cubit-local GetIt lookup style from the reference, using only this project’s registered dependencies.

### 6.1.1 Constructors Preserve Initial State

**Owner requirement:** a Cubit constructor only retains entry parameters and the supplied State; dependency
fields resolve registered instances from GetIt. It does not derive State from those
dependencies. Pass the supplied State unchanged to `super(initialState)`. With no
custom State, use its `const State.initial()` default. Do not `emit`, call a load
or initialization action, start timers, filter records, calculate derived fields
or construct flow requests in a constructor. Do not hide this work in an
initializer/helper or a replacement State passed to `super`.

When — and only when — the feature has a real fetch or entry-parameter resolution, the provider explicitly calls that action, for example:

```dart
create: (_) => CardFeaturesCubit(
    initialCategory: initialCategory,
  )..fetchCards(),
```

That action resolves entry parameters, calculates dependent fields and publishes
State. Construction alone must preserve exactly the caller's initial snapshot.

### 6.2 Small, Specific Actions

This example assumes normalized numeric input and UI controls that are disabled during a request.

```dart
void updatePhoneNumber(String value) {
  final isValid = PhoneNumberValidator.isValid(value);

  emit(
    state.copyWith(
      phoneNumber: value,
      isPhoneNumberValid: isValid,
      isPhoneNumberError: value.isNotEmpty && !isValid,
      canRequestOtp: isValid && state.isNationalIdValid,
    ),
  );
}
```

`updatePhoneNumber` runs **only the phone validator**, once. The national ID is read
from its stored `isNationalIdValid` flag; its validator is never re-run here. There is
no helper that re-validates every field on every change.

### 6.3 One User Change, One Consistent Snapshot

```dart
// Preferred
emit(
  state.copyWith(
    otp: value,
    isOtpError: false,
    canSubmitLogin: CodeValidator.isValid(value, length: 4) &&
        state.remainingSeconds > 0,
  ),
);
```

```dart
// Do not make this the default for an input and its dependent result.
emit(state.copyWith(otp: value));
emit(state.copyWith(canSubmitLogin: checkButtonEnable()));
```

Multiple emits are necessary for `loading → success`, not for displaying momentarily inconsistent data. Two emits in the owner's example do not authorize incomplete snapshots in every action.

### 6.4 Absolute Prohibition on State Construction and Publication Intermediaries

```dart
// Prohibited
@override
void emit(AuthState next) {
  super.emit(AuthRules.prepare(next));
}
```

```dart
// Prohibited; a private name does not create an exception.
void updatePhoneNumber(String value) {
  emit(_prepareState(state.copyWith(phoneNumber: value)));
}
```

Each action must clearly show which fields it changes. **Agents must not create intermediaries for `emit`, State preparation or automatic State publication.** Private/public visibility, a small function or use within one flow does not change this prohibition.

All these names are prohibited when they serve that responsibility:

```dart
emit(_prepareState(...));
emit(calculateNextState(...));
emit(AuthRules.prepare(...));
_updateState(...);       // Hidden calculations + emit
emitPreparedState(...);
publishState(...);
```

Renaming, extensions, mixins, BaseCubit or overriding `emit` are not ways around the rule. Write `emit(state.copyWith(...))` explicitly inside the action.

**A pure calculation helper is different.** A function such as `calculateSelectedCardsTotal(...)` may return a `bool` or amount; it must not construct State, emit, mutate inputs implicitly or connect UI to a rules facade. Create one only when two or more actions use the same calculation.

```dart
// Allowed: one specific calculation, without constructing State or emitting.
int calculateSelectedCardsTotal(List<ListedCard> cards) {
  return cards.fold<int>(0, (total, card) => total + card.balanceRial);
}

// Action with explicit changes; validates only its own field, once.
void updateNationalId(String value) {
  final isValid = NationalCodeValidator.isValid(value);

  emit(
    state.copyWith(
      nationalId: value,
      isNationalIdValid: isValid,
      isNationalIdError: value.isNotEmpty && !isValid,
      canRequestOtp: isValid && state.isPhoneNumberValid,
    ),
  );
}
```

This snippet illustrates the action-body style. The UI disables editing while pending or after success; the Cubit does not repeat that interaction gate.

### 6.5 Validation in the Owner's Style: Specific Field, Central Function

In the owner's reference, `updatePhoneNumber(value)` calls `validatePhoneNumber(value)`, and `updateNationalId(value)` calls `isNationalIDValid(value)`. The reference does not use `validateField('phone')` or generic String-based dispatch. This same style is the project's contract.

```dart
// Prohibited for a fixed form
void validateField(String field) {
  switch (field) {
    case 'nationalId':
      // ...
    case 'phone':
      // ...
  }
}
```

```dart
// Allowed: a specific action + the project's existing central validator
void validateNationalId() {
  emit(state.copyWith(isNationalIdError: !state.isNationalIdValid));
}

void validatePhoneNumber() {
  emit(state.copyWith(isPhoneNumberError: !state.isPhoneNumberValid));
}
```

```dart
AppTextField(
  value: state.nationalId,
  normalizeDigits: true,
  maxLength: 10,
  errorText: state.isNationalIdError ? S.current.authInvalidNationalId : null,
  onChanged: (value) {
    context.read<AuthCubit>().updateNationalId(value);
  },
  onFocusLost: () {
    context.read<AuthCubit>().validateNationalId();
  },
),
```

The validator's name differs between the reference and the current project; do not build a second algorithm. The current project's national-ID authority is `NationalCodeValidator.isValid`. If the owner selects another function as the final authority, consumers use that function rather than parallel regex/checksum implementations in UI and Cubit.

**Owner clarification: live validation starts with the first entered digit in the login national-ID and mobile-number fields, including the shared change-phone input.** Every `onChanged` event calls its field-specific Cubit action, which checks the shared validator once and emits the fresh value, its `isXValid` flag and its error flag together. Focus-loss validation reads the stored `isXValid` flag; it does not run the validator again. Any nonempty invalid value, including incomplete input, immediately shows the existing red error text. Do not wait for the full length, focus loss, a debounce or submit. A valid value immediately clears the error. An untouched empty field has no typing error; required-field errors on focus loss or submit remain supported. UI reads the error flag directly through its existing BlocBuilder, and no error is stored with `setState`. This explicit clarification takes precedence over the older reference snippet that delayed national-ID errors until ten digits.

String field identifiers in server error contracts are a separate concern. Do not infer automatic changes to server fieldErrors contracts from the prohibition on String-based dispatch in fixed forms.

### 6.6 Action Names, Method Focus and Internal Helpers

**Owner clarification, 2026-10-17:** Cubit code must make the operation clear
from its name and keep its responsibilities easy to follow. Apply these rules
alongside Sections 6.4 and 8; shorter methods never justify hidden State updates
or removal of required async safeguards.

**Documentation boundary:** [architecture Sections 12.2–12.7](architecture-smart-virtual-counter-v2-en.md#12-state-management-with-cubit)
define ownership, stable dependencies, production APIs and operation lifetime;
[architecture Section 16.3](architecture-smart-virtual-counter-v2-en.md#163-cubit-testing)
defines behavioral testing boundaries. This section specifies how to express
those decisions in code. The approved before/after examples are in Section 6.7.

- Name an action with a verb and its subject: `fetchCards`, `updateSearchQuery`,
  `requestCardActions`, `selectCardAction` or `resetDraftFilter`.
  Avoid a bare `get`, `set`, `load`, `process`, `handle`, `setDraft` or `requestMore` when the
  reader must open the body to discover the data or interaction involved.
  Earlier snippets using `load()` illustrate initialization placement, not a
  requirement to use that name. This clarification does not authorize a global rename.
- Distinguish fetching data, updating input, requesting a Flutter effect and
  handling a returned modal result. Names should describe those differences.
  A result-handler name should identify the sheet/action whose result it accepts.
- **Action verb vocabulary (preferred verbs):** `fetchX` (reads data and publishes loading/success/failure), `updateX` (stores a value the user typed), `selectX` (stores a choice), `toggleX` (flips a display flag), `validateX` (focus-loss validation), `submitX` (sends the final or an OTP request), `requestX` (publishes an effect asking UI to run a Flutter API), `applyX` / `cancelX` / `resetX` / `openX` (draft and sheet flows). Do not use `get`, `set`, `load`, `handle`, `process`, `init` or `on` as the verb.
- **State field naming:** one status per operation named `<operation>Status`, with one shared latest `failure` and prepared `message` under the project-wide amendment; eligibility flags `canX`; display flags `isX`; validator outcomes `isXValid`; shown errors `isXError`; data fields are plain nouns (`cards`, `visibleCards`, `phoneNumber`). Store the selected object once (`selectedCard`), not an ID plus the object. Do not use generic names (`value`, `data`, `item`, `flag`, `temp`) or a `request`-prefixed status (`requestProfileStatus`).
- Each action represents one coherent event or operation. Loading, success and
  failure publication belong to the same fetch operation; do not split them
  into `emitLoading`, `handleSuccess`, `publishCards` or similar State-publication
  helpers just to shorten the method.
- Review a long method for repeated calculations, nested decisions, repeated
  searches and unrelated behaviors. There is no fixed line-count limit for a
  Cubit action. An explicit `copyWith` with several dependent fields can be
  clearer than several small methods that hide those fields.
- Extract repeated or substantial calculations into private, specifically named
  pure helpers. A helper returns a value such as a selected card, sorted deposit
  numbers, filtered cards, an action or a service ID. It must not return a State,
  emit, mutate Cubit fields or become a second rules facade (Section 6.4).
  Different real actions may call each other when that expresses the flow;
  generic publication helpers remain prohibited.
- Keep implementation helpers private unless a real external consumer needs
  them. Apply architecture Section 12.7 when deciding whether a public setter or
  dependency-replacement action represents actual product behavior; tests alone
  do not establish that requirement.
- Name internal dependencies by purpose (for example `loadCardsUseCase`, not `_loader`).
  Immutable dependency references use `final`; `late` does not justify mutability.
- There is no `isClosed` check anywhere (Section 8.3), and no `safeEmit`, overridden `emit` or BaseCubit. Do not repeat UI-guaranteed preconditions. Keep actual validation and flow choices explicit.
- Apply architecture Section 16.3 when changing tests: tests never justify a disposal guard.

### 6.7 Approved Before/After Coding Examples

These comparisons establish implementation style, not a report that application
Dart has already been changed. **Before** shows the reviewed pattern; **after**
shows the approved form. Keep the current plain State and typed effects.
The complete [CardFeaturesCubit comparison](../reports/2026-10-17-card-features-cubit-style-review.md)
also covers `fetchCards`, its returned `.then` chain, service-action separation
and call-site updates. The report supplies worked examples; this contract and
the architecture document contain the rules. Future work does not need to
depend on the historical report to understand the standard.

#### 6.7.1 Name the Interaction and Remove Synchronous Lifecycle Noise

Before:

```dart
void requestMore(String cardId) {
  if (isClosed) return;
  final card = state.visibleCards
      .where((card) => card.id == cardId)
      .firstOrNull;
  if (card == null) return;
  emit(
    state.copyWith(
      selectedCard: card,
      effect: CardActionsRequested(card),
    ),
  );
}
```

After:

```dart
void requestCardActions(ListedCard card) {
  emit(
    state.copyWith(
      selectedCard: card,
      effect: CardActionsRequested(card),
    ),
  );
}

ListedCard? _findCardById(List<ListedCard> cards, String? cardId) {
  return cards.where((card) => card.id == cardId).firstOrNull;
}
```

The name describes the requested effect. The rendered card can be passed as
a required record; do not look it up again only to reject a missing record. The private lookup is justified by actual reuse in selection/reload;
do not extract every short expression mechanically. No `isClosed` check is added anywhere.

#### 6.7.2 Keep a Specific State Change Visible in Its Action

Before:

```dart
void setDraft(CardFilter value) {
  if (state.draftFilter != null) emit(state.copyWith(draftFilter: value));
}

void clearDraftFilter() {
  setDraft(const CardFilter());
}
```

After:

```dart
void resetDraftFilter() {
  emit(
    state.copyWith(
      draftFilter: const CardFilter(),
    ),
  );
}
```

The specific action shows its entire update; the visible filter sheet supplies
the active draft, so an open-draft entry guard is unnecessary.
It does not change the committed filter or visible cards before Apply. Existing
consumers of the generic setter must be reviewed and updated before deleting it.

#### 6.7.3 Extract a Reused Calculation, Not a State Snapshot

Before: the following calculation is repeated inside the `copyWith` arguments
of both the fetch and category-selection actions:

```dart
footerAction: switch (category) {
  CardCategory.gift => CardFeatureAction.expiredGiftBalance,
  CardCategory.virtual => CardFeatureAction.requestVirtual,
  _ => null,
},
```

After: both actions read the result directly in their own `copyWith`:

```dart
footerAction: _getCategoryFooterAction(category),
```

The private pure helper is:

```dart
CardFeatureAction? _getCategoryFooterAction(CardCategory category) {
  return switch (category) {
    CardCategory.gift => CardFeatureAction.expiredGiftBalance,
    CardCategory.virtual => CardFeatureAction.requestVirtual,
    _ => null,
  };
}
```

The helper returns one decision. It never returns `CardFeaturesState`, updates
fields or emits. Loading/result/failure remain in the named fetch operation;
Section 8.1 supplies the canonical returned-Future pattern (no guard).

These examples introduce no fixed method-length limit. Renaming `load` to
`fetchCards` must also update Provider initialization, retry and tests; it must
not move initialization into the constructor or add a construction wrapper.

## 7. Calculations and Dependent Fields

### 7.1 Calculate Totals in Cubit

```dart
void selectCards(Set<String> selectedIds) {
  final selectedCards = state.cards
      .where((card) => selectedIds.contains(card.id))
      .toList();
  final totalRial = selectedCards.fold<int>(
    0,
    (total, card) => total + card.balanceRial,
  );

  emit(
    state.copyWith(
      selectedIds: selectedCards.map((card) => card.id).toSet(),
      selectedCards: selectedCards,
      totalRial: totalRial,
      termsAccepted: false,
      canContinue: selectedCards.isNotEmpty,
      canSubmit: false,
      failure: null,
    ),
  );
}
```

These local variables inside **Cubit** are allowed: they are part of a calculation. The alias prohibition applies to repackaging State inside UI builders.

### 7.2 Inputs and Results Must Change Together

For each derived field, identify all its inputs:

| Field | Inputs | Actions that must update it |
|---|---|---|
| `canRequestOtp` | Mobile number, national ID | Changes to either field, reset |
| `canSubmitLogin` | OTP, remaining time | OTP change, tick, expiry, reset |
| `visibleCards` | List, query, category, filter | Load, search, category change, applying filters |
| `totalRial` | Selections, amounts | Selection/removal, new load |
| `canSubmit` | Form data, terms acceptance, eligibility | All relevant changes |

Adding a boolean to State is insufficient; every dependent action must keep it correct. During review, change an input and verify that its dependent output changes with it.

### 7.3 What Does Not Need a New Field?

Do not create a new boolean for every small comparison:

```dart
// Preferred: the request status is explicit.
isLoading: state.submissionStatus == RequestStatus.loading,
```

```dart
// Unnecessary if it merely aliases the same enum.
@Default(false) bool isSubmissionLoading,
```

`canSubmit` is a combined form-behavior decision; `isSubmissionLoading` usually duplicates a status.

## 8. Async Operations, Failures and Stale Responses

### 8.1 Readable Loading Pattern: `.then` Without `catchError`

**Owner decision, 2026-10-17:** the project's baseline async style in Cubit is a
returned `.then(...)` chain. Cubit does **not** use `async/await`, `try/catch` or
`catchError` for operations that return `Result`. `Err` is a value, not an
exception, so the failure branch is the `case Err` of the `switch` inside `.then`.

This example uses the actual `CardServicesRepository` and `LoadCardServiceCatalog` contracts. The proposed State contains `catalogStatus`, `catalog` and `catalogFailure`.

```dart
Future<void> fetchCatalog() {
  emit(
    state.copyWith(
      catalogStatus: RequestStatus.loading,
      catalogFailure: null,
    ),
  );

  return LoadCardServiceCatalog(repository)().then((result) {
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.success,
            catalog: data,
            catalogFailure: null,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            catalogStatus: RequestStatus.failure,
            catalogFailure: failure,
          ),
        );
    }
  });
}
```

Required shape:

- The method is not marked `async` and contains no `await`.
- The chain is **returned**. Without `return`, the method completes immediately and callers lose the result.
- There is no guard of any kind in the callback: no `isClosed`, no request ID (Section 8.3).
- Heavy or branching calculations are moved to pure helpers (Section 6.4) so the callback body is only `emit` calls.
- Do not add an early completed Future merely to repeat UI loading/eligibility gates.

**Boundary guarantee (required):** because Cubit has no `catchError`, the
Repository/UseCase boundary must convert **every** exception, including
unexpected ones such as mapper or parse errors, into `Err`. Do not compensate in
Cubit with `try/catch` or `catchError`. If a dependency cannot yet guarantee
this, fix it in `data/` (the layer that owns `DioException` handling); if that is
outside the authorized task, report the concrete gap instead of adding a Cubit
workaround. Without this guarantee an unexpected exception would leave the
operation status at `loading` indefinitely.

> **Pending architecture decision:** the failure hierarchy in architecture
> Section 11.2 has no type for an unexpected exception. Mapping those exceptions
> needs an approved Failure type (for example an `UnexpectedFailure` with a
> generic user message and logged code). Agents must not add one on their own;
> this requires an explicit owner decision and an architecture update.

### 8.2 Submission: UI Owns Invocation Availability

```dart
Future<void> submit() {
  final request = createSubmissionRequest();

  emit(
    state.copyWith(
      submissionStatus: RequestStatus.loading,
      submissionFailure: null,
    ),
  );

  return submitUseCase(request).then((result) {
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.success,
            receipt: data,
            canSubmit: false,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            submissionStatus: RequestStatus.failure,
            submissionFailure: failure,
          ),
        );
    }
  });
}
```

`createSubmissionRequest` illustrates a specific request-construction function in Cubit, not a UI calculation function. The snippet assumes editing/reset controls are disabled during submission.

The UI button uses `isLoading` and its enabled state. Submission trusts that
interaction contract; it publishes loading and starts its operation without a
duplicate status or eligibility guard. Async completion has no disposal check (Section 8.3).

### 8.3 Mandatory Async Rules

- Awaitable operations return `Future<void>`; do not write `void async`.
- Baseline style is `return useCase(...).then((result) { ... })`. Do not use `async/await` in Cubit actions that return `Result`.
- Scope: this style applies to Cubit actions. UI-side modal launchers and effect handlers that must await a Flutter API keep `async/await` and the `context.mounted` guard (Section 19.6); they are Flutter-only adapters, not flow logic.
- Do not add `catchError`, `try/catch` or `onError` in Cubit for expected failures. `Err` is handled by the `switch` inside `.then` (Section 8.1).
- Set the status to loading before starting the Future.
- **No `isClosed`, anywhere (owner decision 2026-10-18).** Do not write `isClosed` in a synchronous action, at the start of an async method, in a `.then` callback, in a Timer/stream callback or in a UI `finally`. Do not hide it in `safeEmit`, an overridden `emit` or a BaseCubit (none exists in this project). The Cubit is owned by the screen's `BlocProvider` and is released from memory when the screen leaves the tree.
  - **Accepted consequence (owner-approved):** a response that arrives after the screen closed makes its `emit` throw a `StateError`, which shows up as an uncaught async error in logs/crash reporting and changes nothing visible. Agents MUST NOT add a guard to avoid it.
  - Cubit-owned timers and subscriptions are still cancelled in `close()` (Section 19.5).
- A request ID is added **only** where two responses of the same operation can genuinely be in flight and the older one must lose (search-as-you-type, switching category/tab while loading). It is a single `if (requestId != _requestId) return;` at the top of that one callback. Never add one by default.
- Where a request ID exists, a stale response must not overwrite a newer selection.
- Disable relevant UI controls during pending operations; do not repeat that gate in Cubit actions.
- Retrying the same banking request preserves the same idempotency key.
- Changing the payload after failure refreshes request identity according to the service contract.
- Client idempotency does not replace the server guarantee.
- Keep the `.then` callback free of anything that can throw (see the boundary guarantee in Section 8.1); calculations belong in pure helpers.

### 8.4 Error Message Ownership

Request-driven features follow the project-wide amendment: a pure Presentation
switch helper prepares Persian error text; Cubit emits the shared failure and
message together with the operation failure status. A focused UI Listener compares
previous/current status and only displays the prepared message. There is no
message effect or sequence counter. Preserve retry sections and field errors, without a second inline
copy of the API notification. Ordinary labels/validation text use S.current.
Domain/Data never produce display text, and UI never inspects DioException or DTOs.

## 9. BlocProvider Inside the Screen

### 9.1 The Team's Baseline Screen Structure

Write the screen with a block body. Provider is inside this same `build`, and the remainder of the tree is directly visible:

```dart
class AverageBalanceScreen extends StatefulWidget {
  const AverageBalanceScreen({
    super.key,
    this.initialDepositNumber,
    this.onCompleted,
  });

  final String? initialDepositNumber;
  final ValueChanged<CertificateReceipt>? onCompleted;

  @override
  State<AverageBalanceScreen> createState() {
    return _AverageBalanceScreenState();
  }
}

class _AverageBalanceScreenState extends State<AverageBalanceScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AverageBalanceCubit>(
      create: (_) => AverageBalanceCubit(
        initialDepositNumber: widget.initialDepositNumber,
      )..load(),
      child: BlocListener<AverageBalanceCubit, AverageBalanceState>(
        listenWhen: (previous, current) {
          return previous.submissionStatus != current.submissionStatus;
        },
        listener: (context, state) {
          if (state.submissionStatus == RequestStatus.success &&
              state.receipt != null) {
            widget.onCompleted?.call(state.receipt!);
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const AverageBalanceConditions(),
                const Spacer(),
                BlocBuilder<AverageBalanceCubit, AverageBalanceState>(
                  buildWhen: (previous, current) {
                    return previous.step != current.step ||
                        previous.canContinue != current.canContinue ||
                        previous.submissionStatus != current.submissionStatus;
                  },
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppButton(
                        label: getAverageBalanceButtonTitle(state.step),
                        isLoading:
                            state.submissionStatus == RequestStatus.loading,
                        onPressed: state.canContinue
                            ? () {
                                context.read<AverageBalanceCubit>().continueFlow();
                              }
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

This is a **screen-structure** example. `continueFlow` and the title helper are proposed by this document. `AverageBalanceConditions` is an independent form section that reads the State it needs through its own builder. This is not a complete multi-step screen implementation.

Register only the dependency in GetIt, using the project's existing interface
and adapter. For this prototype, the registration can select the existing mock:

```dart
// In configureDependencies: dependencies only, no Cubit registration.
getIt.registerLazySingleton<DepositCertificatesRepository>(
  MockDepositCertificatesRepository.new,
);
```

The screen's Provider constructs `AverageBalanceCubit` directly. The Cubit
resolves its Repository internally through GetIt; the screen has no repository
field, lookup or constructor argument. Real entry inputs such as
`initialDepositNumber` still go directly to Cubit. A dependency-free Cubit is
created in exactly the same way: `create: (_) => AuthCubit()`.

Registered UseCases may be resolved in Cubit fields when actually needed; do
not add layers just because the reference app registers them. Tests register
controlled dependencies before constructing Cubit or mounting its screen and
reset the locator afterward. Test helpers may install a dependency around direct
construction; production Cubit creation stays inline in BlocProvider.create.

If the screen has no controllers or lifecycle needs, the same structure is valid in a `StatelessWidget`. Being a StatefulWidget is not a technical prerequisite for Provider. Do not add an empty Flutter State class merely to imitate the example's appearance.

### 9.2 Structure This Team Does Not Prefer

```dart
// Do not add this extra layering to a simple screen in this project.
Widget build(BuildContext context) => BlocProvider(
  key: ValueKey((repository, initialDepositNumber)),
  create: (_) => AverageBalanceCubit(...)..load(),
  child: _AverageBalanceView(...),
);

class _AverageBalanceView extends StatelessWidget { ... }
```

This pattern is not inherently a Flutter error. This contract objects to the extra private wrapper, scattered screen code and implicit reset through a Key. Do not describe it as a “broken Provider” or “the reason Cubit is recreated on every build.”

### 9.3 Provider Owns Cubit

With `BlocProvider(create: ...)`, Provider owns the instance and closes it. `BlocProvider.value` exposes an existing instance and does not close it automatically. Lazy creation is also explained by the API. [Official BlocProvider reference](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocProvider-class.html)

Project rules:

- Construct Cubit directly in `BlocProvider.create` for every new screen/flow scope.
- Keep construction (and the initial action, when the feature needs one) visible in that callback:

  ```dart
  create: (_) => CardFeaturesCubit(
    initialCategory: initialCategory,
  )..fetchCards(),
  ```

- Register only actual Repository, service/API and application dependencies in
  GetIt. No Cubit/Bloc registrations of any lifetime and no `getIt<MyCubit>()`.
- Do not add `_create`, `_createCubit`, `createFlowCubit`, `_buildCubit`, method
  tear-offs or equivalent wrappers to hide Cubit construction/initialization.
  An inline `create` block is allowed for necessary layout scheduling; it must
  still construct Cubit there, not delegate construction to a custom helper.
- Resolve Repository/service/UseCase in Cubit fields from GetIt. No data dependency
  arguments in Cubit creation, screen constructors, router inputs or child props.
- The screen/feature-flow widget owns the Provider. The central router only
  chooses a destination; it never wraps a screen in a Cubit Provider.
- Tests override dependency registrations before construction/mount and reset
  GetIt afterward. No Cubit registrations, repository constructor overrides or
  test-only production factories.
- Do not construct a flow Cubit again in `initState`, a builder or a listener.
- A shared multi-screen flow has one Provider at its common scope; child screens
  reuse it instead of making additional Cubits or resolving them through GetIt.
- Do not manually `close` a Cubit owned by `create`.
- Do not add `bloc: _cubit` when the correct Provider is already an ancestor.
- Use `BlocProvider.value` only for an actual existing instance, such as continuing
  the same flow in a sheet. It does not take ownership of that instance.
- Constructing `Cubit()` inside the `value` argument is prohibited.

### 9.4 Ordinary Rebuilds Differ from Fresh Flow Entry

Rebuilding a widget with the same type, position and Provider element identity does not itself recreate Cubit. Changing a Key or removing the subtree may dispose the previous instance; do not conceal resets this way.

A new route and fresh scope suffice for a new service entry. If runtime repository replacement is a separately authorized requirement, handle it explicitly at the DI/flow boundary; do not introduce Repository props into the screen API. Do not add generic `didUpdateWidget` and `changeRepository` handling to every screen by default. If a new entry or account change in the same scope must reset data, make that behavior explicit, testable and action-specific.

### 9.5 Context Below the Provider

This common mistake is prohibited:

```dart
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => AuthCubit(...),
    child: AppButton(
      onPressed: () {
        // This context belongs above the Provider.
        context.read<AuthCubit>().submitOtpRequest();
      },
    ),
  );
}
```

The context supplied to `BlocBuilder` and `BlocListener` callbacks is below the Provider; use it. If an action is in a static section outside a builder, `Builder` is allowed specifically to obtain the correct context:

```dart
return BlocProvider(
  create: (_) => AuthCubit(...),
  child: Builder(
    builder: (context) {
      return Scaffold(
        body: AppButton(
          label: S.current.dashboardRetry,
          onPressed: () {
            context.read<AuthCubit>().submitOtpRequest();
          },
        ),
      );
    },
  ),
);
```

This use of `Builder` solves a context need; it is not a replacement for every `BlocBuilder` or a decorative wrapper.

## 10. Direct State Use in UI

### 10.1 Preferred

```dart
AppButton(
  label: S.current.issuanceSubmit,
  isLoading: state.submissionStatus == RequestStatus.loading,
  onPressed: state.canSubmit
      ? () {
          context.read<ChangeCardDepositCubit>().submit();
        }
      : null,
),
```

```dart
AppTextField(
  value: state.phoneNumber,
  errorText: state.isPhoneNumberError
      ? S.current.authPhoneInvalid
      : null,
  onChanged: (value) {
    context.read<AuthCubit>().updatePhoneNumber(value);
  },
),
```

`authPhoneInvalid` is an illustrative localization key here. Actual implementation must use an existing/approved ARB key.

### 10.2 Prohibited: Aliases for State Fields

```dart
builder: (context, state) {
  final loading = state.submissionStatus == RequestStatus.loading;
  final form = state.draft;
  final cards = state.visibleCards;
  final canSubmit = state.canSubmit;
  final buttonState = FormButtonViewModel(...);

  return AppButton(
    isLoading: loading,
    onPressed: canSubmit ? ... : null,
  );
}
```

Write simple expressions directly. Calculate lengthy business decisions in Cubit. Use a named UI helper for lengthy display-text selection. A local variable is not the default solution for any of these.

### 10.3 Local Variables Are Not Absolutely Prohibited

These are allowed:

- `screenSize` for layout constraints, when actually used;
- The result of `await showModalBottomSheet` inside a callback;
- Request payloads or results inside Cubit;
- Snapshots used to handle stale responses;
- Calculation locals inside a named display helper;
- Operational objects such as controllers with a lifecycle owner.

`final cubit = context.read<MyCubit>()` inside a builder is not a technical error, but the team's proposed style calls actions directly as `context.read<MyCubit>().action()`. Do not introduce multiple aliases for State and Cubit.

### 10.4 Read the Supplied `state` Inside Builders

```dart
// Preferred
selected: state.category == category,
```

```dart
// Not preferred: mixing the rendered snapshot with the live instance state
selected: context.read<CardFeaturesCubit>().state.category == category,
```

`context.read` calls actions; it is not a rendering subscription. Reading `cubit.state` in a callback after an action is allowed when a fresh value is needed. The lifecycle section explains the distinction.

## 11. buildWhen and listenWhen

### 11.1 Baseline Rule

- Every Listener has `listenWhen` tied to its own side effect.
- Every builder in forms with multiple operations or a timer has explicit `buildWhen`.
- The predicate covers all fields consumed by that subtree.
- Use `previous` and `current` for comparisons; names such as `a/b` or `s1/s2` are not the team's default.
- Do not hide the predicate behind an obscure generic function.

`buildWhen` filters State-triggered rebuilds; it is not a business-behavior guard or a guarantee that “this builder never runs.” Interaction gating belongs to the controls; do not repeat it in Cubit. [Official BlocBuilder reference](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocBuilder-class.html)

### 11.2 Complete Button Subscription Example

```dart
BlocBuilder<AuthCubit, AuthState>(
  buildWhen: (previous, current) {
    return previous.loginStatus != current.loginStatus ||
        previous.canSubmitLogin != current.canSubmitLogin;
  },
  builder: (context, state) {
    return AppButton(
      label: S.current.issuanceSubmit,
      isLoading: state.loginStatus == RequestStatus.loading,
      onPressed: state.canSubmitLogin
          ? () {
              context.read<AuthCubit>().submitLogin();
            }
          : null,
    );
  },
),
```

This builder is not sensitive to timer ticks unless a tick changes `canSubmitLogin`. That behavior is required when an OTP expires.

### 11.3 Failure and Success Listener Example

```dart
BlocListener<AuthCubit, AuthState>(
  listenWhen: (previous, current) {
    return previous.loginStatus != current.loginStatus;
  },
  listener: (context, state) {
    if (state.loginStatus == RequestStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.dashboardLoadError),
        ),
      );
    }

    if (state.loginStatus == RequestStatus.success) {
      onAuthenticated?.call();
    }
  },
  child: ...,
),
```

Listener is appropriate for navigation, dialogs and messages. It does not invoke its callback for initial state on attachment; a pre-existing state requires a separate design. [Official BlocListener reference](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocListener-class.html)

For two consecutive failures, the action must go through `failure → loading → failure`. If a special design produces a new event without changing status, status comparison alone is insufficient; an identifier for that operation's result is needed. Do not introduce a generic event system without a real need.

### 11.4 MultiBlocListener for Independent Effects

```dart
MultiBlocListener(
  listeners: [
    BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return previous.otpRequestStatus != current.otpRequestStatus;
      },
      listener: (context, state) {
        if (state.otpRequestStatus == RequestStatus.failure) {
          // Display this operation's failure message.
        }
      },
    ),
    BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return previous.loginStatus != current.loginStatus;
      },
      listener: (context, state) {
        if (state.loginStatus == RequestStatus.success) {
          onAuthenticated?.call();
        }
      },
    ),
  ],
  child: ...,
),
```

One Listener is sufficient for one simple effect. Do not add MultiBlocListener just to mimic the example. Empty or placeholder listeners are prohibited in final code.

### 11.5 A Dangerous buildWhen Mistake

```dart
// Incomplete
buildWhen: (previous, current) {
  return previous.status != current.status;
},
builder: (context, state) {
  return Text('${state.remainingSeconds}');
},
```

The subtree reads time, but its predicate is not sensitive to time changes. The UI may lag behind. The correct predicate compares `remainingSeconds`.

If `buildWhen` needs 15–20 fields, review the subtree boundary first. Do not convert State into a record or another object just to shorten it. Top-level screen `BlocConsumer`/`BlocBuilder` widgets and main cohesive content areas that display the entire state MUST NOT have exhaustive multi-field `buildWhen` predicates that compare every field. BlocBuilder defaults to rebuilding whenever state changes (`previous != current`), which Freezed handles by value equality. Exhaustive `buildWhen` predicates listing 15–30 fields are prohibited bloat. Reserve `buildWhen` for isolated leaf components or sub-widgets that only depend on 1–3 specific fields.

### 11.6 Choose Builder, Listener or Consumer by Responsibility

- Use BlocBuilder when the section only needs State-driven rendering.
- Use BlocListener when it only needs to execute a Flutter side effect.
- Use BlocConsumer when the same section meaningfully needs both, such as a
  submission button that displays loading and whose result closes its sheet.
- Use MultiBlocListener for genuinely independent side effects, not as a
  compulsory screen template. It does not create additional Cubits.

A substantial async listener or a multi-case effect switch belongs in a named
widget/State method such as `_handleEffect`, referenced directly by listener.
Keep listenWhen beside that reference. The method executes already-decided
Flutter effects and forwards raw results to Cubit; extracting a method does
not permit eligibility, request construction or flow decisions in UI.

The reference project's unfiltered/nested builders and inline long listeners are observations,
not overrides of this project's filters and named-handler preference. A status
transition may identify an operation result; repeated same-status effects need
an appropriate identity when necessary. Do not remove existing reliable effect
delivery or impose a new generic effect framework solely to imitate the source.

## 12. Subscription Boundaries and Passing State to Children

Two explicit models are allowed; combining them without reason is prohibited.

**Main builder-placement rule:** Identify the section that actually depends on State. Place the builder around that meaningful responsibility. “As low as possible” does not mean one builder for every Text, Icon and input. If only the list changes, do not include fixed headers and footers in its subscription. Several related inputs or controls may share one form builder. When small builders become numerous and scattered, a higher-level builder is acceptable to preserve readability.

| Screen situation | Preferred choice | Prohibited interpretation |
|---|---|---|
| Only the list changes | A builder inside Expanded around the list and its loading state | A whole-screen builder merely out of habit |
| Two or more related form fields | One builder around the form with suitable buildWhen | Mandatory individual builders for every input and error text |
| A frequently ticking timer and an independently updating form | Separate the timer subscription within its meaningful section | Multiple files just for each timer number and icon |
| Several sections read shared data and builders have become numerous | One higher-level builder with direct State reads | Insisting on fragmentation to minimize rebuilds at any cost |

buildWhen supports readability and filters changes; it does not guarantee a fixed section will never rebuild. The goal is to avoid unnecessary subscriptions to flow changes, not to fight every natural Flutter rebuild.

### 12.1 An Independent Section Owns Its Builder

The parent does not read State for this same section:

```dart
Column(
  children: [
    const LoginFormWidget(),
    const OtpWidget(),
  ],
),
```

`LoginFormWidget` may own a builder for phone/national-ID fields, while `OtpWidget` owns one for OTP and timer data. This is the familiar model in the owner's example.

### 12.2 The Parent Reads State and the Child Consumes It

```dart
BlocBuilder<CardIssuanceCubit, CardIssuanceState>(
  buildWhen: (previous, current) {
    return previous.draft != current.draft ||
        previous.deposit != current.deposit ||
        previous.totalRial != current.totalRial;
  },
  builder: (context, state) {
    return IssuanceSummaryWidget(state: state);
  },
),
```

```dart
// widgets/issuance_summary_widget.dart
class IssuanceSummaryWidget extends StatelessWidget {
  const IssuanceSummaryWidget({
    super.key,
    required this.state,
  });

  final CardIssuanceState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(state.deposit?.number ?? ''),
        Text(CurrencyFormatter.format(state.totalRial)),
      ],
    );
  }
}
```

`CurrencyFormatter.format` exists in the current package API and formats a value for display; the amount is calculated in Cubit. A flow-specific widget may receive the complete State. An `avp_ui` primitive must not depend on application State; it receives only general data and callbacks.

### 12.3 Necessary Nesting Differs from Duplicate Nesting

A parent builder reading only `step` to choose a form and a child form builder reading its inputs may be necessary. These subscriptions have different responsibilities.

If the parent already reads and passes all the child's data, the child must not subscribe again to that same data.

`BlocSelector` is valid in the library, but `BlocBuilder + buildWhen` is this team's default. Do not introduce tuple/record selectors, multiple field projections or parallel State structures without need. Under this contract, selectors require a specific need and an explainable reason.

### 12.4 Example: Only the List Depends on State

```dart
// This section is below the screen's BlocProvider.
Column(
  children: [
    Text(S.current.dashboardCardsList),
    const SizedBox(height: 16),
    Expanded(
      child: BlocBuilder<CardFeaturesCubit, CardFeaturesState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.visibleCards != current.visibleCards;
        },
        builder: (context, state) {
          if (state.status == RequestStatus.initial ||
              state.status == RequestStatus.loading) {
            return Center(child: Text(S.current.dashboardLoading));
          }

          if (state.status == RequestStatus.failure) {
            return Center(
              child: AppButton(
                label: S.current.dashboardRetry,
                onPressed: () {
                  context.read<CardFeaturesCubit>().load();
                },
              ),
            );
          }

          return ListView.builder(
            itemCount: state.visibleCards.length,
            itemBuilder: (context, index) {
              return AppCardsList(
                cardNumber: state.visibleCards[index].number,
                linkedDeposit: state.visibleCards[index].linkedDeposit,
              );
            },
          );
        },
      ),
    ),
    const SizedBox(height: 16),
    Text(S.current.cardFeatureDetails),
  ],
),
```

This example illustrates only the subscription boundary. The actual screen preserves its empty/no-results states and row actions. No extra builder is created for the example's fixed title and text.

### 12.5 Example: One Related Form, One Builder

```dart
BlocBuilder<AuthCubit, AuthState>(
  buildWhen: (previous, current) {
    return previous.phoneNumber != current.phoneNumber ||
        previous.nationalId != current.nationalId ||
        previous.isPhoneNumberError != current.isPhoneNumberError ||
        previous.isNationalIdError != current.isNationalIdError;
  },
  builder: (context, state) {
    return Column(
      children: [
        AppTextField(
          value: state.phoneNumber,
          hintText: S.current.loginPhoneHint,
          normalizeDigits: true,
          maxLength: 11,
          errorText: state.isPhoneNumberError ? S.current.authInvalidPhone : null,
          onChanged: (value) {
            context.read<AuthCubit>().updatePhoneNumber(value);
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          value: state.nationalId,
          hintText: S.current.loginNationalIdHint,
          normalizeDigits: true,
          maxLength: 10,
          errorText:
              state.isNationalIdError ? S.current.authInvalidNationalId : null,
          onChanged: (value) {
            context.read<AuthCubit>().updateNationalId(value);
          },
        ),
      ],
    );
  },
),
```

This example complies with the contract even if a phone change rebuilds both inputs. The fields belong to one cohesive form. A complete example would also include focus-loss validation and enabled state in the fields and buildWhen, according to that flow.

## 13. Widget-Tree Coding Style

### 13.0 Mandatory UI Coding Fundamentals

Use PascalCase widget/class names, snake_case Dart filenames and camelCase
methods. Constructors use super.key and const where eligible. Known callbacks
MUST use VoidCallback, ValueChanged<T> or an explicit function type; do not use
Function?/dynamic to avoid declaring a known contract. Keep nullability meaningful.

Use the target project's theme typography, semantic colors, assets and public
avp_ui controls. Localize through S.current. Copying reference-project component
names, palette tokens, fonts or visual defaults is prohibited. Keep explicit
Row/Column/Padding/SizedBox composition and related small display conditions
readable; resource-specific tools must address an actual layout/lifecycle need.

Extracted modal content and substantial UI responsibilities follow Sections 14
and 17. Source line counts are not a new exact limit; meaningful responsibilities,
actual reuse and preserved subscription/resource ownership determine boundaries.
UI construction MUST NOT execute loads, submissions, analytics or flow decisions.

### 13.1 Block Bodies for build

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<AuthCubit, AuthState>(
    buildWhen: (previous, current) {
      return previous.step != current.step;
    },
    builder: (context, state) {
      return Column(
        children: [
          const SizedBox(height: 20),
          if (state.step == AuthStep.identity)
            const LoginFormWidget(),
          if (state.step == AuthStep.otp)
            const OtpWidget(),
        ],
      );
    },
  );
}
```

Do not write `Widget build(...) =>` for a substantial tree. Structure, predicates and `return` should be readable without compression. A simple value helper may remain short.

### 13.2 Familiar Tools Are the Default

Use `Column`, `Row`, `Padding`, `SizedBox`, `Expanded`, `SafeArea`, `ListView` and existing `avp_ui` widgets.

`Builder`, `LayoutBuilder`, `PopScope`, `AnimatedPadding` and other tools are not prohibited, but must solve a specific problem. Do not introduce `CustomScrollView + slivers`, multiple wrappers and an internal layout framework for a simple form.

For an unusual tool, the agent must explain its need in one sentence: “LayoutBuilder is needed because the card-column count changes with width.” “It is cleaner” is not sufficient.

### 13.3 Keep Small Conditions Inline

```dart
Text(
  state.isPhoneNumberError
      ? S.current.authPhoneInvalid
      : S.current.authPhoneHint,
),
```

Use a named helper for a multi-step condition. Three-level ternaries and lengthy `switch` expressions inside widget arguments are not the default.

### 13.4 Compression and Framework Building Are Prohibited

```dart
// Not preferred for a form with known fields
FieldRenderer(
  schema: [
    ('phone', state.phoneNumber, updatePhone, ...),
    ('national', state.nationalId, updateNational, ...),
  ],
),
```

**Explicit inputs following the owner's examples are required for fixed forms, not merely preferred.** Five or ten fields do not justify array-driven forms. Each field's label, hint, value, error and callback must be visible together. Possible future Agent/assistant schema needs do not justify converting current forms into a generic renderer.

The following patterns are prohibited for fixed forms:

```dart
final labels = [...];
final hints = [...];
final values = [...];

for (var index = 0; index < labels.length; index++)
  AppTextField(
    value: values[index],
    onChanged: (value) {
      switch (index) {
        // Choosing the action by field number
      }
    },
  );
```

Replacing the three arrays with a Map, record, function list, schema or metadata does not make the same pattern acceptable. This rule concerns **defining fields in a fixed form**. Rendering actual lists of cards, deposits or selector options through builders/loops is allowed. A genuinely dynamic form based on an independent server contract is outside this rule and requires an explicit task and contract. Agents must not turn fixed forms into dynamic forms on their own.

When a field changes, UI passes only its fresh value to the specific Cubit action. Reconstructing an entire recipient model from several controllers or sending other fields from a UI snapshot is not the default:

```dart
// Preferred
onChanged: (value) {
  context.read<CardIssuanceCubit>().updateRecipientName(value);
},

// Not preferred for changing one fixed field
onChanged: (value) {
  context.read<CardIssuanceCubit>().setRecipient(
    DeliveryPerson(
      name: value,
      nationalId: nationalIdController.text,
      mobile: mobileController.text,
    ),
  );
},
```

Updating the internal model from the fresh value and existing State belongs in Cubit. Receiving a complete object from a sheet result or API is a different case and is not prohibited by this rule.

### 13.5 Short Closures and Clear Actions

```dart
onChanged: (value) {
  context.read<AuthCubit>().updateNationalId(value);
},
```

`onChanged: cubit.updateNationalId` is technically valid, but the explicit form above is the team's baseline. Do not write long callbacks combining calculations, multiple requests and navigation inside arguments. Move calculations and all transferable interaction decisions to Cubit. A named UI method may only execute the already-decided Flutter operation; see Section 3.5.

## 14. Splitting Screens and Public Widgets

### 14.1 Size Rule

| Approximate handwritten UI file size | Action |
|---|---|
| Under 150 lines | Usually retain the file; extract only for actual reuse |
| Around 150–200 lines | Review responsibilities; one or two meaningful sections may be extracted |
| Over roughly 200 lines | Seriously consider splitting forms, lists, summaries or sheets |
| A cohesive section slightly over 200 lines | Acceptable with a clear reason; do not damage structure for a number |

A machine-counted line total is not a definitive quality measure. Do not manipulate imports, blank lines or formatting to make a file appear smaller. Generated code is excluded.

### 14.2 Two Main Reasons for Extraction

1. The screen/section has grown large and a specific responsibility can be read separately.
2. The same section is used more than once in the same flow.

Complex controller ownership or frequent timer updates may also provide a specific reason, but must not become an excuse to create ten widgets for a simple screen. A small builder alone is not a reason to extract.

### 14.3 Public Class in Its Own File

```dart
// widgets/card_features_content.dart
class CardFeaturesContent extends StatelessWidget {
  const CardFeaturesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardFeaturesCubit, CardFeaturesState>(
      // buildWhen and UI belonging to this section
      ...
    );
  }
}
```

```dart
// In the screen
Expanded(
  child: CardFeaturesContent(),
),
```

The class name must not start with `_`. `class _CardFeaturesContent` and `class _AverageBalanceView` are prohibited for extracted widgets. `_AuthScreenState extends State<AuthScreen>` remains private: it is the StatefulWidget's internal implementation, not an extracted widget.

### 14.4 Prohibited: Functions Returning UI Trees

```dart
Widget _content(BuildContext context, MyState state) { ... }
Widget _body(BuildContext context, MyState state) { ... }
Widget _footer(BuildContext context, MyState state) { ... }
```

Under this team's style, if a section needs separation, create a public widget in its own file. If it is too small to warrant a widget, keep it inline. `String getButtonTitle(...)` is different from `Widget _footer(...)`.

This is a team readability rule. Do not falsely claim that every function returning Widget inherently damages Flutter performance.

### 14.5 What Must Not Be Extracted

- `TitleWidget` wrapping one single-use Text;
- `GapWidget` for SizedBox;
- `IconWrapper` without behavior or reuse;
- `ScreenBodyView` created only for context below Provider;
- One widget for every short `if` branch;
- One widget for each property of an input.

### 14.6 Reasonable LoginLocalAuth Split

An acceptable split of the owner's large example could be:

```text
screens/login_local_auth_screen.dart       Provider, Listener, overall layout
widgets/local_password_form.dart           Description, PIN state display, keyboard
widgets/local_password_action.dart         Button and its subscription
```

If the button is only a few lines, the third file is unnecessary. A repeated template/widget for the four PIN dots is justified only by actual reuse or clear form simplification. Do not split four dots into four files.

## 15. Display Conditions and Title/Text Helpers

### 15.1 Five Step Titles in One Named Function

This is a UI function; it returns localized text only:

```dart
String getFinancialCertificateStepTitle(
  FinancialCertificateStep step,
) {
  switch (step) {
    case FinancialCertificateStep.conditions:
      return S.current.certificateConditionsStep;
    case FinancialCertificateStep.recipient:
      return S.current.financialRecipientStep;
    case FinancialCertificateStep.latinIdentity:
      return S.current.financialLatinStep;
    case FinancialCertificateStep.delivery:
      return S.current.financialDeliveryStep;
    case FinancialCertificateStep.confirmation:
      return S.current.issuanceConfirmTitle;
  }
}
```

Direct consumption:

```dart
AppStepper(
  currentStep: state.stepNumber,
  totalSteps: 5,
  title: getFinancialCertificateStepTitle(state.step),
  supportingText: getFinancialCertificateNextTitle(state.step),
),
```

`stepNumber` is a proposed State field in this example, updated by Cubit together with `step`. Step-order calculations must not depend on localized text.

### 15.2 A Clearly Named Button-Text Helper

```dart
String getAverageBalanceButtonTitle(
  AverageBalanceStep step,
) {
  switch (step) {
    case AverageBalanceStep.conditions:
    case AverageBalanceStep.delivery:
      return S.current.issuanceNext;
    case AverageBalanceStep.confirmation:
      return S.current.issuanceSubmit;
  }
}
```

If five steps have different text, write five explicit cases. A simple ternary is allowed for two small cases. Do not introduce a function merely to lengthen two obvious alternatives.

### 15.3 Why Is This Function Not in Cubit?

Cubit determines the step; UI determines the language and displayed words. The following are prohibited:

```dart
// Prohibited in Cubit
String getButtonTitle(BuildContext context) { ... }

emit(state.copyWith(buttonTitle: 'ثبت درخواست'));

emit(state.copyWith(buttonTitle: S.current.submit));
```

If text selection is complex and depends on several business rules, Cubit stores a meaningful enum such as `primaryAction` or `nextStep` in State, and a UI helper localizes it. Do not introduce a title enum merely to eliminate one ternary.

### 15.4 Display-Helper Location

- A value helper used only by this screen may remain in the same file.
- If several widgets in the flow use it, place it in a clearly named `..._labels.dart` file.
- Display helpers must not `emit`, call APIs or navigate.
- Names must convey meaning: `getIssuanceButtonTitle` is clearer than `labelFor`.
- `List<String> titles` and `titles[state.step.index]` are not the default for known steps; map the enum explicitly.

### 15.5 Remove Business Logic from Rendering

```dart
// Prohibited: deciding fees and eligibility in a builder
final walletSufficient = state.catalog!.walletBalanceRial >=
    state.fees.fold<int>(0, (sum, fee) => sum + fee.amountRial);
```

```dart
// Preferred: Cubit has already calculated the result.
if (!state.walletSufficient)
  Text(S.current.issuanceWalletInsufficient),
```

If an example's localization key does not exist, add or substitute an approved ARB key. Technical codes must not be displayed to users.

### 15.6 Localized Text Is Not a Decision Identifier

**Required:** Labels are for display only. Conditions governing behavior, selection, spacing or the end of a list must not depend on localized text.

```dart
// Prohibited: the meaning of “last rule” depends on translated text.
if (ruleTitle != S.current.passwordDateRule)
  const SizedBox(height: 12),
```

Write sections and spacing explicitly for a small fixed collection. For a genuinely dynamic list, use a meaningful identifier or position in that list, not translation equality. Changing languages or giving two options identical text must not change behavior.

## 16. Filtering, Selection and Lists

### 16.1 Search in Cubit, Direct Rendering in UI

```dart
void updateSearch(String value) {
  emit(
    state.copyWith(
      query: value,
      visibleCards: filterCards(
        cards: state.cards,
        query: value,
        category: state.category,
        filter: state.filter,
      ),
    ),
  );
}
```

`filterCards` is a specific Cubit function. Do not perform business filtering in `itemBuilder` or a UI helper. Load, category changes and filter application also call this function with fresh inputs.

### 16.2 Readable Lists Without Aliases

```dart
ListView.separated(
  itemCount: state.visibleCards.length,
  separatorBuilder: (context, index) {
    return const SizedBox(height: 10);
  },
  itemBuilder: (context, index) {
    return AppCardsList(
      cardNumber: state.visibleCards[index].number,
      linkedDeposit: state.visibleCards[index].linkedDeposit,
      cardNumberLabel: S.current.cardFeatureNumber,
      linkedDepositLabel: S.current.cardFeatureDeposit,
      onMoreTap: () {
        showCardActionsSheet(context, state.visibleCards[index]);
      },
    );
  },
),
```

A Key may be justified for a stateful row whose identity must survive reordering. Do not add keys to simple display rows solely for test finders.

### 16.3 Draft and Committed Filters

```dart
void openFilter() {
  emit(state.copyWith(draftFilter: state.filter));
}

void updateDraftStatus(CardStatus? value) {
  emit(
    state.copyWith(
      draftFilter: CardFilter(
        status: value,
        deposit: state.draftFilter!.deposit,
      ),
    ),
  );
}

void updateDraftDeposit(String? value) {
  emit(
    state.copyWith(
      draftFilter: CardFilter(
        status: state.draftFilter!.status,
        deposit: value,
      ),
    ),
  );
}

void applyFilter() {

  emit(
    state.copyWith(
      filter: state.draftFilter!,
      visibleCards: filterCards(
        cards: state.cards,
        query: state.query,
        category: state.category,
        filter: state.draftFilter!,
      ),
      draftFilter: null,
      selectedCard: null,
    ),
  );
}

void cancelFilter() {
  emit(state.copyWith(draftFilter: null));
}
```

The sheet only sends selections to these actions. Constructing the filtered list and defining what Apply does belong in Cubit. Dismissing the sheet by an outside tap or Back must also cancel the draft; do not implement cancellation only for the Cancel button.

### 16.4 Category Selection and Footer

The current example calculates `footerAction` from category inside the builder. Since that choice determines which service is available, the decision must be made in Cubit and stored in State:

```dart
void selectCategory(CardCategory category) {
  emit(
    state.copyWith(
      category: category,
      selectedCard: null,
      visibleCards: filterCards(
        cards: state.cards,
        query: state.query,
        category: category,
        filter: state.filter,
      ),
      footerAction: getCategoryFooterAction(category),
    ),
  );
}
```

If an action enum is used for business behavior/State, place it in Domain or an independent feature file. Cubit must not import a widget file just to obtain it.

UI:

```dart
if (state.footerAction != null)
  AppButton(
    label: getCardActionTitle(state.footerAction!),
    onPressed: () {
      context.read<CardFeaturesCubit>().requestFooterAction();
    },
  ),
```

Cubit prepares the footer request and destination intent. A filtered listener executes that effect through the existing router. Concrete route dispatch remains in UI/router; selecting the destination from the action/category does not. An adapter is allowed only under Section 3.5; renaming the old decision tree to `openCardAction` does not make it acceptable.

### 16.5 Proposed Typed Selector — Recommendation, Not a Migration Requirement

**Decision status:** The owner requested an explanation and a suitable solution. This section records a specific proposal; it does not authorize automatic changes to existing selectors. Do not infer a general String prohibition, new enums for every select or a fieldErrors rewrite.

Current issue: card status is `CardStatus`, but the selector converts it to String and then converts it back to the enum with `byName`:

```dart
AppSelect<String>(
  value: state.draftFilter?.status?.name ?? 'all',
  // ...
);

// Then inside the callback:
CardStatus.values.byName(value);
```

**Proposed solution:** The selector value keeps its meaningful type; its label is localized separately. `AppSelect<CardStatus>` suffices when there is no “All” option. For a filter including “All,” the current `AppSelect` API treats a null return as cancellation. Do not return null as the “All” option. A specific enum for that filter is appropriate:

```dart
// Flow definition; this example name is not an instruction to add it to every feature.
enum CardStatusFilter {
  all,
  active,
  blocked,
  expired,
}

// Proposed State field for this filter
@Default(CardStatusFilter.all) CardStatusFilter draftStatusFilter,
```

```dart
AppSelect<CardStatusFilter>(
  value: state.draftStatusFilter,
  label: S.current.cardFeatureCardStatus,
  options: [
    AppSelectOption(
      value: CardStatusFilter.all,
      label: S.current.cardFeatureAll,
    ),
    AppSelectOption(
      value: CardStatusFilter.active,
      label: S.current.cardFeatureActive,
    ),
    AppSelectOption(
      value: CardStatusFilter.blocked,
      label: S.current.cardFeatureBlocked,
    ),
    AppSelectOption(
      value: CardStatusFilter.expired,
      label: S.current.cardFeatureExpired,
    ),
  ],
  onChanged: (value) {
    context.read<CardFeaturesCubit>().updateDraftStatusFilter(value);
  },
),
```

```dart
// Specific action; no String parsing or State construction in a helper
void updateDraftStatusFilter(CardStatusFilter value) {
  emit(state.copyWith(draftStatusFilter: value));
}
```

Convert “All” into no condition and apply the filter inside Cubit on Apply. The open sheet owns when these actions are invoked; no draft-open entry guard is required. This example illustrates only typed values/callbacks, not the complete filter flow.

The `options` list above is not a prohibited form array; it contains options for **one selector**, each with explicit label and value. Card/deposit IDs that are genuinely Strings remain Strings. Do not turn this proposal into generic wrappers, generic mappers or enums for inherently textual data.

## 17. Dialogs and Bottom Sheets

### 17.1 Allowed Pattern: Opening Function + Public Class

The function only opens the already-requested sheet and supplies a public widget; a large UI tree is not hidden in its callback. It does not choose which sheet to open, construct flow requests or interpret the result. Those responsibilities belong in Cubit under Section 3.5. Call this launcher from a listener when opening the sheet is a flow decision.

```dart
// widgets/card_details_sheet.dart
Future<void> showCardDetailsSheet(
  BuildContext context,
  ListedCard card,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    builder: (sheetContext) {
      return CardDetailsSheet(card: card);
    },
  );
}

class CardDetailsSheet extends StatelessWidget {
  const CardDetailsSheet({
    super.key,
    required this.card,
  });

  final ListedCard card;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardDetailRow(
              title: S.current.cardFeatureNumber,
              value: card.number,
              valueDirection: TextDirection.ltr,
            ),
            CardDetailRow(
              title: S.current.cardFeatureIban,
              value: card.iban,
              valueDirection: TextDirection.ltr,
            ),
            CardDetailRow(
              title: S.current.cardFeatureDeposit,
              value: card.linkedDeposit,
              valueDirection: TextDirection.ltr,
            ),
            CardDetailRow(
              title: S.current.cardFeatureStatus,
              value: getCardStatusTitle(card.status),
              valueDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: S.current.backLabel,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

`CardDetailRow` is used four times, so its extraction is actual reuse. If `avp_ui` provides an equivalent standard row, use it. This example does not authorize duplicating a package primitive. Without an equivalent, a card-detail-specific row may use the following public class in its own file:

```dart
// widgets/card_detail_row.dart
class CardDetailRow extends StatelessWidget {
  const CardDetailRow({
    super.key,
    required this.title,
    required this.value,
    required this.valueDirection,
  });

  final String title;
  final String value;
  final TextDirection valueDirection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textDirection: valueDirection,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
```

Localizing row titles and choosing card/IBAN direction are UI display logic. These data do not all need to move into Cubit. If a sheet only displays a details snapshot without business interaction, it does not need a separate Cubit either.

### 17.2 Prohibited Patterns in the Current Sheet Example

```dart
final rows = [
  (S.current.cardFeatureNumber, card.number),
  (S.current.cardFeatureIban, card.iban),
];

Text(rows[index].$1);
Text(rows[index].$2);
textDirection: index < 3 ? TextDirection.ltr : TextDirection.rtl,
```

For a few known rows, explicit title/value names and direction are clearer. Identifying field type by index is fragile: reordering rows changes the meaning of direction.

Dart records are not inherently prohibited. However, `$1/$2` access and index conditions for formatting fixed forms are not accepted under this contract. For genuinely dynamic row counts, use a model with named fields and a specific responsibility.

### 17.3 A Sheet Sharing the Screen Cubit

A modal is normally created in a separate route; do not assume access to the screen's local Provider without checking. To continue the same state, pass the existing instance:

```dart
Future<void> showCardFilterSheet(BuildContext context) async {
  final cubit = context.read<CardFeaturesCubit>();
  cubit.openFilter();

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: const CardFilterSheet(),
        );
      },
    );
  } finally {
    cubit.cancelFilter();
  }
}
```

In `CardFilterSheet`, Apply first calls `applyFilter`, then closes the modal. `cancelFilter` only sets `draftFilter` to null and has no entry guard; it never touches the committed filter. After Apply, finally must not clear the committed filter.

This `.value` use is the expressly allowed existing-instance sharing case; the sheet must not close the screen Cubit.

### 17.4 Deletion Dialog: Bind the Confirm Event Directly

When a modal has separate Confirm and Cancel buttons, bind the Confirm event
to the specific Cubit action using the non-null ID supplied by the effect:

```dart
onConfirm: () {
  context.read<CardIssuanceCubit>().removeAddress(address.id);
  Navigator.of(sheetContext).pop();
},
onCancel: () {
  Navigator.of(sheetContext).pop();
},
```

Outside dismissal also closes without deleting. No `bool? confirmed` argument,
selected-address equality recheck or entry guard is needed. Cubit still owns the
actual address-list/draft/eligibility update. This UI callback only forwards the
concrete Confirm event and invokes the Flutter modal API. Modals that genuinely
return a choice (such as action selection or Apply/Cancel) keep their actual
result-based flow decision in Cubit.

### 17.5 Avoid Generic Helpers Without Need

`_sheet<T>(context, panel).then((_) {})` is not the default way to hide a few shared lines. Use an existing shared sheet API in `avp_ui` when available; otherwise, a clearly named feature function with a short builder is appropriate.

Do not use `then((_) {})` merely to discard a result; write the return type and await explicitly. All sheets with inputs must handle keyboard insets, scrolling and RTL.

## 18. Keys and UI Tests

### 18.1 Default: Do Not Add Keys

```dart
// Preferred
AppChips(
  label: getCardCategoryTitle(category),
  selected: state.category == category,
  onPressed: () {
    context.read<CardFeaturesCubit>().selectCategory(category);
  },
),
```

```dart
// Prohibited without a specific behavioral need
key: Key('card_category_${category.name}'),
key: const Key('continue_button'),
key: const ValueKey('screen_body'),
key: UniqueKey(),
```

`super.key` in constructors is required and allowed. The prohibition concerns manually constructing keys at consumption points without a reason.

### 18.2 Cases with a Real Reason

| Need | Possible use |
|---|---|
| Stateful row identity during reordering | `ValueKey(item.id)` |
| ReorderableList | A stable row key |
| Truly necessary access to FormState | `GlobalKey<FormState>` |
| AnimatedList | The list's State key |
| Measurement/ensureVisible for a specific case | GlobalKey with a defined reason and lifecycle |
| Intentional reset of a stateful subtree | Only if an explicit reset does not solve the issue; explain near the code |

Being in a ListView, having a label or wanting a convenient finder is insufficient. `UniqueKey` inside build may unnecessarily discard state.

### 18.3 Tests Should Prefer Public Behavior

Use actual labels, text, widget types, tooltips and semantics in tests. Semantics are designed for accessibility; do not put artificial test identifiers in semanticLabel.

For a repeated, genuinely ambiguous control, first create a finder scoped to an appropriate parent. A test key is a last resort with a specific reason, not the default for every button. Removing current keys also requires reviewing dependent tests in an authorized refactor. Nothing has been removed at this stage.

## 19. Controllers, Focus, Timers and Lifecycle

### 19.1 Controlled value When a Controller Is Unnecessary

The current `AppTextField` API provides `value` and `onFocusLost`. For a simple input:

```dart
AppTextField(
  value: state.phoneNumber,
  normalizeDigits: true,
  keyboardType: TextInputType.phone,
  maxLength: 11,
  errorText: state.isPhoneNumberError
      ? S.current.authPhoneInvalid
      : null,
  onChanged: (value) {
    context.read<AuthCubit>().updatePhoneNumber(value);
  },
  onFocusLost: () {
    context.read<AuthCubit>().validatePhoneNumber();
  },
),
```

Do not supply both `controller` and `value`; the current package API does not accept that combination.

### 19.2 StatefulWidget Owns a Necessary Controller

```dart
class OtpWidget extends StatefulWidget {
  const OtpWidget({super.key});

  @override
  State<OtpWidget> createState() {
    return _OtpWidgetState();
  }
}

class _OtpWidgetState extends State<OtpWidget> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        return previous.isOtpError != current.isOtpError ||
            previous.otpRequestStatus != current.otpRequestStatus ||
            previous.loginStatus != current.loginStatus;
      },
      builder: (context, state) {
        return AppTextField(
          controller: _otpController,
          focusNode: _otpFocusNode,
          normalizeDigits: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          enabled: state.otpRequestStatus != RequestStatus.loading &&
              state.loginStatus != RequestStatus.loading,
          obscureText: true,
          enableIMEPersonalizedLearning: false,
          errorText: state.isOtpError
              ? S.current.authOtpInvalid
              : null,
          onChanged: (value) {
            context.read<AuthCubit>().updateOtp(value);
          },
        );
      },
    );
  }
}
```

This example illustrates controller ownership only. If Cubit resets or autofills OTP, synchronize the controller through a listener for `otp` changes, or use `value` instead. A controller must not become a second business source of truth. Do not force its value in build, because this disrupts text selection and the cursor.

### 19.3 Prohibited: UI Resources in Cubit or Static Storage

```dart
// Prohibited
static final FocusNode otpFocusNode = FocusNode();

class AuthCubit extends Cubit<AuthState> {
  final controller = TextEditingController();
  BuildContext? context;
}
```

State must not store `TextEditingController`, `FocusNode`, `ScrollController`, Widget or BuildContext either.

### 19.4 Stale Snapshots in onChanged

```dart
// Incorrect: this closure's state may predate the action.
onChanged: (value) {
  context.read<AuthCubit>().updatePhoneNumber(value);

  if (!state.isPhoneNumberError) {
    // The decision uses the previous snapshot.
    _nationalCodeFocusNode.requestFocus();
  }
},
```

When input validity genuinely needs to drive focus movement, Cubit stores a specific result such as `isPhoneNumberValid` together with the input. The callback reads the fresh value after the synchronous action:

```dart
onChanged: (value) {
  context.read<AuthCubit>().updatePhoneNumber(value);

  if (value.length == 11 &&
      context.read<AuthCubit>().state.isPhoneNumberValid) {
    _nationalCodeFocusNode.requestFocus();
  }
},
```

Alternatively, a Listener comparing that field's changes may perform the focus movement. `isPhoneNumberError == false` does not necessarily mean valid input; focus-loss validation may not have run yet. Add the validity field only when this need exists.

### 19.5 Timer in Cubit, Rendering in UI

Assume `AuthCubit` has `_timer` and `_otpDeadline`, and OTP length is four digits:

```dart
DateTime? _otpDeadline;

void startOtpTimer(int seconds) {
  stopOtpTimer();
  _otpDeadline = DateTime.now().add(Duration(seconds: seconds));

  emit(
    state.copyWith(
      remainingSeconds: seconds,
      canSubmitLogin: CodeValidator.isValid(state.otp, length: 4) &&
          seconds > 0,
    ),
  );

  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      final milliseconds = _otpDeadline!
          .difference(DateTime.now())
          .inMilliseconds;
      final remainingSeconds = milliseconds <= 0
          ? 0
          : (milliseconds / 1000).ceil();

      if (remainingSeconds == 0) stopOtpTimer();

      emit(
        state.copyWith(
          remainingSeconds: remainingSeconds,
          canSubmitLogin:
              CodeValidator.isValid(state.otp, length: 4) &&
              remainingSeconds > 0,
        ),
      );
    },
  );
}

void stopOtpTimer() {
  _timer?.cancel();
  _timer = null;
}

@override
Future<void> close() {
  stopOtpTimer();
  return super.close();
}
```

The timer is cancelled in `close()`, so its callback needs no `isClosed` check. A deadline avoids measuring elapsed time incorrectly through callback counts after delayed ticks or backgrounding. This is a display countdown; the server determines actual OTP validity and expiry. If immediate refresh on resumed is required, UI lifecycle requests fresh time through a Cubit action. Do not move MethodChannel or BuildContext into Cubit.

UI only formats the time:

```dart
String getOtpRemainingTime(int remainingSeconds) {
  final minutes = remainingSeconds ~/ 60;
  final seconds = remainingSeconds % 60;

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
```

```dart
BlocBuilder<AuthCubit, AuthState>(
  buildWhen: (previous, current) {
    return previous.remainingSeconds != current.remainingSeconds;
  },
  builder: (context, state) {
    return Text(
      CurrencyFormatter.toPersianDigits(
        getOtpRemainingTime(state.remainingSeconds),
      ),
    );
  },
),
```

Splitting seconds for **text rendering** in a UI function is allowed; OTP submission eligibility remains in Cubit. Display valid minutes and seconds instead of `00:60`.

### 19.6 After await in UI

Any callback using context or widget State after awaiting must check `context.mounted` or `mounted`. An artificial `Future.delayed(300ms)` for focus is not the default. Move focus after the section is actually displayed, with a lifecycle guard.

Clearing a controller does not automatically invoke `onChanged`. Cubit performs business resets, and rendering synchronizes from State.

### 19.7 setState Prohibition, Including Purely Visual State

**Explicit owner instruction:** Agents MUST NOT use `setState` for flow or display state. Even password visibility, summary expansion and visual selections require a Freezed State field and a Cubit action. “This is only UI state” is not an exception.

```dart
// State
@Default(false) bool isPasswordVisible,
@Default(false) bool isConfirmationPasswordVisible,
@Default(false) bool isSummaryExpanded,
```

```dart
// Cubit
void togglePasswordVisibility() {
  emit(
    state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ),
  );
}

void toggleConfirmationPasswordVisibility() {
  emit(
    state.copyWith(
      isConfirmationPasswordVisible: !state.isConfirmationPasswordVisible,
    ),
  );
}

void updateSummaryExpanded(bool value) {
  emit(state.copyWith(isSummaryExpanded: value));
}
```

```dart
BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
  buildWhen: (previous, current) {
    return previous.password != current.password ||
        previous.isPasswordVisible != current.isPasswordVisible;
  },
  builder: (context, state) {
    return AppTextField(
      value: state.password,
      obscureText: !state.isPasswordVisible,
      normalizeDigits: true,
      enableIMEPersonalizedLearning: false,
      onChanged: (value) {
        context.read<SecondPasswordCubit>().updatePassword(value);
      },
      suffixIcon: AppButton(
        variant: AppButtonVariant.text,
        label: state.isPasswordVisible
            ? S.current.passwordHide
            : S.current.passwordShow,
        onPressed: () {
          context.read<SecondPasswordCubit>().togglePasswordVisibility();
        },
      ),
    );
  },
),
```

Visibility fields in the example are additions to the target contract and have not yet been added to actual State. The real flow also preserves that field's enabled/loading/validation behavior in UI and the relevant buildWhen.

Controllers and FocusNodes may remain in a StatefulWidget; that does not authorize `setState`. A focus Listener sends an event to a specific action such as `validatePasswordConfirmation()`. Mismatch outcomes and error-display timing belong in State.

```dart
// Prohibited
bool showPassword = false;
bool mismatch = false;

setState(() => showPassword = !showPassword);
setState(() => mismatch = password.text != confirmation.text);
```

If no implementation is possible with the flow contract and available APIs, report the precise blocker and leave the dependent change unimplemented. There is no agent-granted exception. Only an explicit owner amendment to the specific rule changes it. Shorter code, Flutter habits or “purely visual state” never waive this rule. Do not replace `setState` with parallel State in ValueNotifier or a new notifier to evade this rule. Ordinary use of existing animation/controllers for Flutter lifecycle and behavior is a separate concern.

### 19.8 Lifecycle Hooks Are Not Flow Orchestrators

Do not add `didChangeDependencies`, `initState`, `didUpdateWidget`, a local
“scheduled” flag or post-frame work merely to hide a decision that belongs in
Cubit. Use `didChangeDependencies` only for an actual inherited dependency need;
it is not the default place to initialize a category or flow.

A real layout requirement may need `addPostFrameCallback`: scroll extents and
rendered targets may not exist before the first layout. Keep only that scheduling
boundary and lifecycle/resource guards in UI, then request the already-defined
Cubit action or execute its pending effect. Do not place selection, initial-data
resolution, payload construction or action routing inside the callback. Do not
move Flutter scheduling or controllers into Cubit.

Initial effects require explicit delivery: `BlocListener` does not replay the
initial State. Arrange the first Cubit action after listener attachment and layout
when necessary. Guard queued callbacks against disposal, preserve ordinary
rebuilds, and do not schedule duplicate actions from repeated builds. Removing a
redundant hook must preserve the needed initial reveal/focus behavior.

## 20. Multi-Step Flows and Back

### 20.1 One Action for the Primary Button

Instead of repeating submit/next decisions in several UI callbacks:

```dart
Future<void> continueFlow() {
  if (state.step == IssuanceStep.confirmation) {
    return submit();
  }

  nextStep();
  return Future.value();
}
```

UI:

```dart
onPressed: state.canContinue
    ? () {
        context.read<CardIssuanceCubit>().continueFlow();
      }
    : null,
```

Cubit determines the next step; UI selects the form for the current step. The form-selection builder reads only `step`; independent forms read their own fields.

### 20.2 Back Within the Form and Leaving the Route

- Cubit decides whether to move back one step.
- UI executes navigation and shows exit confirmation.
- Hardware Back and the in-screen button must behave consistently.
- System and in-screen Back are blocked by UI while any request in the owning flow is loading (owner-approved project-wide amendment). After loading, normal step-back and exit confirmation remain available. Cubit navigation actions do not repeat the UI gate with loading guards. Other ways of leaving still retain the accepted late-response consequence in Section 8.3.
- The first step of a form with discardable input requires exit confirmation.
- After a successful receipt, leave the flow using `go` to the approved destination; the user must not return to a form that can be submitted again.

**Required:** the in-screen Back event calls a Cubit action such as
`requestBack()`. Cubit changes a step when appropriate,
or publishes an exit-confirmation/exit effect. UI executes that effect, checks
`context.mounted` after awaiting, and sends the raw confirmation result back to Cubit (e.g., `exitConfirmationResult(confirmed)` which simply emits `navigation: confirmed == true ? FlowNavigation.back : null`).
Only Cubit decides whether that result permits leaving. UI must not read request
status and orchestrate `back() -> confirmation -> exit` in a helper or listener.
These names illustrate the contract; implement only actions/effects needed by
the actual flow, rather than assuming these APIs already exist.

When `PopScope.canPop` blocks exit, an authorized exit effect needs a concrete
navigation path that releases the restriction or uses the approved `go`
destination. Do not send another `pop` to the blocked scope. Preserve platform
Back handling and test both system Back and the in-screen button.

### 20.3 Entry Parameters and Reset

`initialDepositNumber`, the initial category and tracking ID are route inputs. Provider passes them to Cubit. Cubit resolves the selection and creates meaningful initial state. UI does not search lists for the initial number inside build.

A resumable flow retrieves state from the server. This document defines UI style and does not replace the architecture's `resume` contract.

## 21. Shared Design, RTL and Localization

### 21.1 Using avp_ui

Before building a component:

1. Consult the [integration guide](main-app-integration-guide.md).
2. Inspect the public exports of `package:avp_ui/avp_ui.dart`.
3. Use the existing component.
4. Supply only feature data, callbacks and validation from the application.
5. If the API is insufficient, identify the required variant/component. Extend the package only within the task's authorized scope.

“Public widget in its own file” does not authorize duplicating AppButton, AppTextField, checkbox or package theme in the application. Wrapping an existing component requires specific behavior or reuse.

### 21.2 Material Tools

Layout widgets such as Row/Column/Padding/SafeArea and Text are used in screen composition. Raw controls such as TextField, Checkbox and ElevatedButton are not used when `avp_ui` provides an equivalent. This distinction prevents agents from inventing nonexistent components from another project for every Text.

Check existing package APIs for dialogs and feedback first as well. `ScaffoldMessenger` examples show the location of side effects. If an approved public feedback API exists in the package, use it.

### 21.3 Typography and Colors

```dart
Text(
  S.current.cardFeatureDetails,
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    color: context.colors.textPrimary,
  ),
),
```

- Do not introduce `TextStyle(fontSize: ...)` or new hex colors in a feature.
- Use existing semantic tokens.
- Do not register the package's primary font again in the application.
- For a specific Figma variation, use an existing typography role with `copyWith`.
- Use `const` for eligible constructors and fixed SizedBoxes.
- Take design spacing from tokens or the screen's established pattern; do not alter Figma with numbers chosen by the agent.

### 21.4 RTL and Digits

- Application layout is RTL; preserve it through routes and overlays.
- `EdgeInsetsDirectional`, `AlignmentDirectional` and `TextAlign.start/end` are defaults.
- Card numbers, IBANs and identifiers requiring Latin/LTR have explicit direction.
- Normalize Persian/Arabic numeric input to Latin; pure validators receive Latin input.
- Monetary values in State are numeric; display them with the package formatter.
- Domain/Data dates are Gregorian and UTC; Jalali rendering happens in UI.
- Do not interchange status codes, tracking IDs and localized labels.

### 21.5 Do Not Put Analytics in build

Older Skill examples suggest event tracking in build. This document does not accept that for a one-time screen event: build repeats. Record screen events in a defined lifecycle/observer location and click events in the corresponding callback. Do not build new analytics infrastructure solely for this document.

### 21.6 Approved Localization Access Contract: S.current

**Owner decision on 2026-10-14:** Read UI text as `S.current.mobileNumber`, and generally `S.current.<key>`. Generate class `S` from ARB through `intl_utils`; do not build a handwritten facade to shorten `AppLocalizations`.

```dart
import 'package:pishkhan_mobile/generated/l10n.dart';

Text(S.current.mobileNumber);
Text(S.current.otpSentMessage(state.maskedPhone));
```

`mobileNumber` illustrates the requested style. Adding or changing a real key must match the ARB file. Localization examples in this document have been updated to the target contract.

- Direct access is required; do not create `final l10n = ...` or `final strings = S.current` in UI.
- A multi-step title helper receives the step and returns text from `S.current`; do not pass BuildContext solely for localization.
- Cubit and Domain do not access `S.current`; they produce error codes, enums and data. Request-driven Cubits may emit prepared Persian error text through a pure Presentation helper under the project-wide amendment; Domain/Data still produce no UI text.
- Read S.current after its delegate loads; this access itself is not a language-change subscription.
- Runtime language switching, if separately requested, must coordinate app locale and necessary UI rebuilds.
- Localization generation, delegate configuration and locale tests follow [architecture Section 14.1](architecture-smart-virtual-counter-v2-en.md#141-localization).

**This change is documentation-only.** Current code still uses `gen-l10n`, `AppLocalizations` and `context.l10n`; dependencies, ARB and Dart have not changed. Migration requires a separate task.

## 22. Review of Current Project Examples

This section diagnoses style; not every item is a runtime bug.

### 22.1 AverageBalanceScreen and _AverageBalanceView

**Readability issue:** The screen is primarily a Provider wrapper, while UI resides in another private class. A Key containing repository and seed makes resets implicit.

**Proposed rule:** Provider, Listener and Scaffold belong in the same screen build. Real sections such as Conditions and Delivery become independent public widgets. A public screen `initialState` parameter remains only for an actual contractual need; do not add it to every screen automatically.

**Technical note:** The current construction is valid, and ordinary rebuilds do not necessarily reset Provider. Fixing style must not destroy correct existing lifecycle behavior.

### 22.2 CardListScreen with Manually Owned Cubit

**Readability issue:** The screen creates/closes `_cubit`, supplies explicit `bloc:`, and also contains large UI sections and methods returning Widget.

**Proposed rule:** Provider owns Cubit; controllers, focus and scroll remain owned by widget State. Extract the substantial list into public `CardFeaturesContent` and remove `_content`. Category and query changes update the prepared list in State.

Retain `didUpdateWidget` and `changeRepository` only for a runtime replacement need. Do not add them automatically for testing or hypothetical future use.

### 22.3 _revealCategory and Chip Keys

**Issue:** Index 3 and scattered conditions tie scrolling to enum position. GlobalKeys for all chips add mental overhead.

**Required:** Cubit owns the selected category, whether a reveal is needed and
the intended reveal target. UI listener resolves that target against real layout
and executes `animateTo`/`ensureVisible`. Controllers and chip contexts remain in
UI; they never enter Cubit/State. Do not keep the reveal decision in a UI helper.
Do not add keys merely for tests or to every chip. Magic indices must not replace
behavioral names. Initial layout timing follows Section 19.8.

### 22.4 _request and _more

**Required:** move card selection, request/payload construction, available-action
rules, destination selection and modal-result interpretation into Cubit. Cubit
publishes prepared typed effects for an action sheet, details or service request.
UI listener executes the selected effect and returns sheet selections to Cubit.

The old permission to retain `_request`/`_more` as “short UI coordination” is
superseded. Neither private/public naming nor moving the body inline is an
exception. A modal launcher may remain only as the Flutter-only adapter described
in Section 3.5.

### 22.5 footerAction in the Builder

**Issue:** The rule defining the startable service is located in layout code.

**Rule:** Store the action in State if it is a behavioral decision; localize its title through a UI display helper. If it is merely a visual variation, a UI helper suffices. The agent must explicitly distinguish these cases.

### 22.6 Record Rows and $1/$2

**Issue:** Titles and values are identified by position, while direction changes by index.

**Rule:** Write a few fixed rows explicitly as `CardDetailRow(title:, value:, valueDirection:)`. Genuinely dynamic data should use appropriately named fields. Do not turn fixed UI into a schema.

### 22.7 title, next and stepNumber in the Issuance Builder

**Issue:** Selecting titles and next-step text produces several local variables before return, making UI code longer to read.

**Rule:** Actual flow ordering and stepNumber belong in Cubit/State. `getIssuanceStepTitle` and `getIssuanceNextTitle` text belongs in UI and is consumed directly by AppStepper. Do not create parallel title/progress arrays merely because UI has multiple steps.

### 22.8 _body and _footer in Card Issuance

**Issue:** Large UI sections are hidden behind private functions.

**Rule:** If screen size warrants it, extract public `IssuanceContent` or `IssuanceFooter` into its own file, with direct State or an explicit independent subscription. A small loading branch does not need a new independent widget.

### 22.9 _prepareState in Current Cubits

**Issue:** A simple field change may invoke a large central function that rebuilds selection, fees, editability, request and several booleans together. Understanding the action requires following the entire helper.

**Rule:** Use explicit actions and clearly named pure calculation helpers. Write `emit(state.copyWith(...))` in the action itself. `_prepareState` and every State preparation/publication intermediary, whether private or public, are prohibited. Preserve genuinely shared calculations only as pure values, not State constructors or a second behavioral facade.

### 22.10 Label and Asset Helpers

A function returning String, such as `getCardStatusTitle` or an asset path, is acceptable display logic. A function creating Widget with layers of transforms and layout is different from a value helper. A substantial/reused responsibility needs an approved component; otherwise keep it inline.

## 23. Common Mistakes and Proposed Corrections

| Not preferred | Replacement |
|---|---|
| `final loading = state.status == ...` | Direct comparison in the argument |
| `final cards = state.visibleCards` | Direct `state.visibleCards` |
| A `State.canSubmit` getter | Field calculated by Cubit |
| `prepareState / _updateState / publishState` constructing or publishing State | Explicit emit/copyWith in the action; helpers return pure values only |
| `AuthRules / ViewStateMapper` for a simple form | Specific Cubit actions and functions |
| `_ScreenView` merely below Provider | UI in the same screen build |
| Large `_buildContent()` | Public widget in its own file |
| A component for one SizedBox | Inline SizedBox |
| Default `ValueKey((repository, seed))` | Fresh route scope or an explicitly required reset |
| `GlobalKey` for every chip | Only keys needed for actual behavior |
| `rows[index].$1/$2` for a few fixed fields | Explicit title/value properties |
| Direction based on `index < 3` | Explicit direction for each data type |
| Title selection through an enum.index array | A title helper with meaningful cases |
| Eligibility in onPressed | Decision in Cubit; UI only calls the action |
| Async callbacks without mounted checks | Guard after await |
| Timer without close handling | Cancel in close |
| Controller in StatelessWidget | Controlled value or StatefulWidget ownership |
| Separate fieldErrors in UI and Cubit | Errors in State; UI only localizes |
| Repeating UI enablement/loading inside Cubit | UI controls invocation; action publishes the requested change |
| Navigator in Cubit | UI listener/callback |
| Validation code in a widget | Validator/UseCase, coordinated by Cubit |
| Repository/UseCase passed through screen and child constructors | Resolve dependencies from GetIt inside Cubit fields |
| `_createCubit()` or another Cubit creation wrapper | Direct constructor and explicit initial action in `BlocProvider.create` |
| Cubit registered in GetIt or resolved through `getIt<MyCubit>()` | GetIt holds dependencies; BlocProvider.create constructs and owns Cubit |
| Mock inside every screen by default | Mock selected in environment DI registration |
| Fake success for an unimplemented action | Unavailable message or explicit host callback |
| Analytics event inside build | Appropriate lifecycle/observer or callback |
| setState for password visibility, summary or form errors | State field and explicit Cubit action |
| labels/hints/values arrays and switch(index) for fixed forms | Explicit inputs following the owner's example |
| validateField('phone') for fixed forms | Field-specific update/validate and central validator |
| Localized-text comparison for decisions | Meaningful identifier or explicit layout |
| Deleting fields solely because current UI does not read them | Check operational responsibilities or future service contracts |
| Mandatory builder for every Text and Icon | Builder around a meaningful changing section; a higher level to avoid fragmentation |

For mock dependencies, configure the mock implementation in DI for the intended environment. BlocProvider.create constructs the Cubit directly; Cubit fields resolve registered dependencies and never forwards a mock or live Repository through UI constructors. This rule does not authorize changing existing adapters without a task.

## 24. Agent Instructions and Review Checklists

### 24.1 Short Text Suitable for Agent Instructions

```text
Follow the approved UI/Cubit/State contract for this project's Presentation code.
Read the complete contract before work. Sections 2.3 and Mandatory Enforcement
are binding; no self-granted exceptions, renamed workarounds or skill/example
precedence. Preserve current State conventions. Do not claim completion while
introduced/modified code violates an applicable rule.

1. Write UI in the team's familiar style with block-body build methods.
2. Place BlocProvider(create) at the screen/actual flow entry. Do not add private
   Screen/View wrappers, manually owned Cubits or explicit bloc: without need.
   Construct Cubit directly in create; no GetIt Cubit registrations/resolution and no _create/_createCubit helpers.
3. Use context below Provider in callbacks.
4. State is a plain Freezed data class, without handwritten getters or logic.
5. UI reads state.field directly. Do not introduce aliases, record projections or
   ViewModels to repackage State.
6. Keep independent operation statuses separate and compare loading directly.
7. Form decisions, validation, filtering and monetary totals belong in Cubit/Domain.
8. Write emit and copyWith explicitly in the action. Do not create prepareState,
   updateState, StateMapper or publication wrappers, even private ones. Pure bool/number helpers are allowed.
9. Localize multi-step titles through named UI helpers; do not put BuildContext in Cubit.
10. Listeners have listenWhen; form builders have relevant buildWhen.
    Place builders around meaningful changing sections, not necessarily every widget.
    If only the list changes, subscribe that list. Related fields or numerous
    builders may use a higher-level builder.
11. Review screens around 150–200 lines. Extract only substantial or actually reused
    sections into public widgets in their own files. Do not create ten tiny wrappers.
12. Do not write private UI-tree-returning methods or private extracted widgets.
13. Keys require behavioral needs and nearby explanations; default decorative/test keys are prohibited.
14. Check the public avp_ui API first; do not invent nonexistent components.
15. UI owns controllers/focus/scroll, Cubit owns timers; dispose/close them correctly.
16. UI owns repeat-click/edit gating. Do not duplicate its entry preconditions in Cubit. Preserve server idempotency.
    Async style: Future<void> methods return `useCase(...).then((result) { ... })`;
    no async/await and no catchError/try-catch in Cubit. Handle Result with a switch
    inside .then (Err is a value, not an exception). Repository/UseCase must convert
    all exceptions to Err. NEVER write `isClosed` anywhere (no BaseCubit/safeEmit either);
    a request-id check only for a real overlapping-response case. Do not invent an
    unexpected-exception Failure type; report it as a pending decision.
17. No unsolicited global refactoring, package changes or new dependencies.
18. Do not use setState even for password/summary display state. Keep values in State
    and actions in Cubit. Do not use parallel notifiers to evade this rule.
    Report a concrete blocker without implementing a forbidden workaround; agents cannot grant exceptions.
19. Write fixed forms explicitly like the owner's reference. labels/values/callbacks arrays,
    schemas and switch(index) for their fields are prohibited. Actual data lists are allowed.
20. Each form field has a specific action calling the central validator. Do not dispatch
    by String field names or duplicate regex/checksum implementations.
21. Localized text is for display only; do not use it to decide behavior or spacing.
22. Do not remove operational/future-service-contract fields solely for lack of UI consumption.
    A request snapshot may remain in State; a fresh payload may also be constructed at submit.
23. The typed-selector proposal (Section 16.5) does not authorize migration. Matching enums by
    index remains open. Empty button callbacks are not currently a correction target.
24. Use S.current.<key> for UI localization, without aliases or context.l10n.
25. Mandatory: all logic transferable without Flutter UI resources belongs in Cubit/Domain.
    This includes requests, action/category rules, footer choices, destination intents,
    modal-result interpretation and flow orchestration. No UI helper/callback/listener loophole.
26. UI sends events; Cubit updates State and publishes typed effects; listeners execute
    Flutter operations and return raw results. Repeated effects need reliable delivery.
27. Lifecycle hooks and post-frame callbacks contain only required attachment/layout
    scheduling and resource guards. No redundant didChangeDependencies or local flow flags.
28. Never pass Repository/UseCase through UI constructors, route arguments or child props.
    Register dependencies, services and API clients in GetIt, never Cubit/Bloc.
    Screen/flow widgets own Providers; central GoRouter only selects destination widgets.
    Extract multi-case listener bodies into named UI effect methods.
    BlocProvider.create directly constructs Cubit; Cubit fields resolve dependencies from GetIt.
    Provider owns the instance once per screen/flow scope; UI reads State through Bloc.
29. Minimal Cubit Rules (owner amendment 2026-10-18) override every example: no `isClosed`,
    no BaseCubit/safeEmit, no defensive `if (...) return;` guards in actions, validate each
    field once (aggregates read stored `isXValid` flags), emit only changed fields, no initial
    action without a real fetch, non-null arguments (pass the object, not an ID to re-find),
    no dead methods/State fields, verb vocabulary and State naming from Section 6.6.
```

This text is a compact summary of the mandatory contract, not an alternative to it. Root AGENTS.md requires agents to read and apply the complete contract. Open decisions do not relax approved rules.

### 24.2 Before Writing UI

- [ ] Actual screen needs, route inputs and exit callbacks are defined.
- [ ] Existing `avp_ui` and app-shared components have been checked.
- [ ] State types and operation statuses are identified.
- [ ] Every planned UI helper/callback has passed the mandatory Section 3.5 ownership gate.
- [ ] Cubit decisions and UI rendering responsibilities are distinct.
- [ ] No new abstraction has been designed for a simple screen.
- [ ] No out-of-scope change has been assumed necessary.

### 24.3 While Writing Cubit

- [ ] Cubit resolves its dependencies from GetIt fields; there are no Repository/service/UseCase constructor arguments or UI/router lookups.
- [ ] Every action names its verb and subject; names distinguish input updates, fetching, effect requests and returned results (Section 6.6).
- [ ] Method boundaries follow real operations; repeated calculations are private pure helpers, without generic State-publication methods (Sections 6.4–6.7).
- [ ] Public APIs and mutable dependencies have real product consumers; test setup follows architecture Section 12.7.
- [ ] Requests, footer/action choices, destination intents and modal-result interpretation are owned here, not duplicated in UI.
- [ ] Necessary effects carry prepared data and support repeated delivery without Flutter resources.
- [ ] Input emits update dependent results in the same snapshot.
- [ ] Helpers name their calculation; UI does not obtain rules from them.
- [ ] Helpers neither construct State nor emit; changes are visible in the action.
- [ ] Each field is validated through the owner's specific-method style and central validator.
- [ ] Independent operations have independent statuses.
- [ ] UI loading/eligibility gates are not repeated as Cubit entry guards; selected inputs use meaningful non-null contracts.
- [ ] Loading is recorded before the Future starts.
- [ ] Async methods return a `.then` chain: no `async`/`await`, no `catchError`/`try-catch`, and the chain is returned.
- [ ] There is no `isClosed` anywhere; a request-id check exists only for a real overlapping-response case.
- [ ] Each `updateX` runs only X's validator; other fields are read from stored `isXValid` flags.
- [ ] No `if (...) return;` guard exists in any action, no field is re-emitted with its default/current value, and every method/State field has a caller/reader in the same change.
- [ ] The `.then` callback contains only `emit` calls and pure helper calls that cannot throw.
- [ ] Retrying the same payload uses an appropriate stable key.
- [ ] Cubit-owned timers/subscriptions are released in close.
- [ ] Sensitive information is neither logged nor exposed in generated toString output.

### 24.4 While Writing State

- [ ] It contains only fields, enums and data factories.
- [ ] Visibility, expansion and displayed form errors are also controlled by State.
- [ ] Future/operational fields with defined responsibilities are retained; no new ceremonial fields are added.
- [ ] Lack of direct UI consumption alone has not caused removal of request or operation metadata.
- [ ] No handwritten getters, BuildContext, Widget or controllers.
- [ ] Null is used only with an actual meaning.
- [ ] Defaults are not unnecessarily nullable.
- [ ] Required derived fields are updated by every dependent action.
- [ ] A new boolean is not merely a status alias.
- [ ] Models inside State have appropriate equality and immutability.

### 24.5 While Writing UI

- [ ] Provider placement is clear and ownership uses create.
- [ ] The Cubit constructor and initial action are directly visible in Provider.create; no locator resolution of Cubit or custom creation helper.
- [ ] No Repository/UseCase parameters or prop forwarding exist in screen/child widgets; locator lookup occurs inside Cubit fields, with no UI/router lookup or dependency constructor injection.
- [ ] GetIt contains dependencies only, no Cubit/Bloc registration. Provider creates/closes each scope; tests replace data dependencies instead of registering Cubits or expanding widget APIs.
- [ ] No private View wrapper or default Key.
- [ ] Callbacks use the correct context below Provider.
- [ ] State is read directly in arguments.
- [ ] No transferable logic exists in UI methods, closures, builders, listeners or lifecycle hooks (Section 3.5).
- [ ] No request construction, action/category-to-service mapping, footer decision or back-flow orchestration remains in UI.
- [ ] Listeners execute typed effects and return modal results to Cubit without choosing the next flow action.
- [ ] Every remaining UI helper requires a specific Flutter or display API; short length/private naming is not its justification.
- [ ] Initial effects are delivered after attachment/layout where necessary; no redundant lifecycle hook or duplicate scheduling flag.
- [ ] Fees, filtering and eligibility are not calculated in builders.
- [ ] Lengthy title selection uses named display helpers.
- [ ] Builders perform no side effects.
- [ ] listenWhen/buildWhen cover the section's actual needs.
- [ ] No duplicate nested subscription to the same data.
- [ ] Builders wrap meaningful changing sections; no separate builder for every Text and Icon.
- [ ] No setState, local boolean or parallel notifier for flow display state.
- [ ] Fixed forms have explicit inputs, without parallel arrays or index-based dispatch.
- [ ] Localized text is not compared to determine behavior or layout.
- [ ] Extracted widgets are public and in their own files.
- [ ] No `_content/_body/_footer` returning Widget.
- [ ] Unusual Flutter tools have specific, explainable needs.
- [ ] Controllers/focus/scroll have owners and disposal.
- [ ] Package RTL, localization and typography conventions are followed.

### 24.6 Behavioral Verification During Authorized Refactoring

When actual code changes are requested, these scenarios merit testing:

1. Input changes correctly update canSubmit and errors.
2. Timer ticks update only the necessary section; expiry disables submission.
3. Loading/disabled UI controls do not invoke another submission.
4. Failure preserves data needed for retry.
5. An old quote response does not replace a newer selection.
6. Closing a flow releases its Cubit and cancels its owned timers.
7. Back/outside dismissal of the filter sheet discards the draft.
8. Ordinary form rebuilds do not reset Cubit or inputs.
9. System Back and in-UI Back behave consistently.
10. After success, a resubmittable form does not remain in the stack.

Do not write tests that mirror implementation just to verify a variable declaration or Padding placement. For behavioral changes, run relevant tests and report results precisely. This task has only produced documentation; application execution tests have not been run.

### 24.7 Completion Gate: No Self-Granted Exceptions

Before claiming completion, verify every applicable mandatory rule against all
code introduced or modified by the task. Correct violations first. If blocked,
report the exact unimplemented requirement and conflict; do not claim compliance.
Passing analysis/tests, pre-existing patterns, a skill example, a short deadline
or a preference for another architecture never waives this gate.

An expressly permitted branch, such as a key required to preserve row identity
while reordering, must state its concrete behavioral need near the code:

```dart
// Reordering must preserve the internal editor associated with this card ID.
key: ValueKey(card.id),
```

This documents an allowed case; it does not create a new exception. Agents may
not invent additional allowances. Keep unrelated work outside the authorized task.

## 25. Differences from Existing Documentation and Adoption Path

### 25.1 Proposed Changes Relative to Existing Rules

| Topic | Existing sources | This document's rule or stated proposal |
|---|---|---|
| Transferable UI logic | Older examples allow short UI coordination methods | Mandatory Section 3.5: decisions and request construction in Cubit/Domain; UI executes prepared Flutter effects only |
| State factory | `State(...)` and independently generated State output | Reference style: `State.initial(...)`, part of Cubit |
| Injected initialState | Required in Section 12 | Supported by the constructor; UI passes it only when needed |
| Provider and View | Architecture example uses a child View | Simple screens have no private View wrapper; Provider and UI share the same build |
| GetIt and Cubit lifetime | Earlier guidance registered Cubits as factories | Superseded: GetIt registers dependencies only; Cubit is directly constructed and owned by BlocProvider.create |
| State preparation | Section 12 permits a coordinating private helper | New owner instruction: State construction/publication intermediaries are absolutely prohibited; helpers return pure values only |
| Extracted widget class | Skill permits local helpers in the same file | Owner requirement: public widget in its own file |
| File size | Skill suggests around 200 and a 200–300 range | Review extraction around 150–200; split responsibilities without fragmentation |
| Selector | Skill/architecture generally allow it | `BlocBuilder + buildWhen` by default; selectors require specific need |
| Getters and aliases | Architecture mostly prohibits them | Reinforced through direct examples and precise checklists |
| Material | Some Skill sections use absolute wording | Basic layout is allowed; do not replace controls that have package equivalents |
| Localization | Current code uses gen-l10n and context.l10n | Approved S.current style; code migration has not occurred |
| Analytics in build | Skill contains an example | Repeated side effects in build are prohibited |
| Keys | Skill includes general exceptions | Exceptions require clear behavioral needs; automatic Provider resets are not default |
| setState | Some current forms keep display/error state locally | Owner instruction: display state and errors belong in State; agents cannot waive the prohibition; an impossible case is reported as blocked |
| Fixed forms | Some forms use parallel arrays | Explicit fields like the owner's examples; no renderer or index-based dispatch |
| Builder level | “Lowest subtree” could be read absolutely | Meaningful changing sections; higher-level grouping is allowed for readability |
| Async style in Cubit | Section 8 baseline was `async/await`; `.then` was merely allowed | Owner decision 2026-10-17: returned `.then` chain, no `catchError`/`try-catch` in Cubit; Repository/UseCase must convert all exceptions to `Err` |
| `isClosed` placement | One guard at the top of each `.then`/Timer callback (2026-10-17) | Removed entirely (owner decision 2026-10-18) |
| Unexpected-exception Failure | Not defined in architecture Section 11.2 | Pending owner decision; agents must not add a Failure type on their own |
| BaseCubit | Listed in the architecture tree (`core/cubit/base_cubit.dart`) | Removed (owner decision 2026-10-18) |
| Field validation | Aggregate flags re-ran every validator on every change | Validate once per field; aggregates read stored `isXValid` flags |
| Initial emit | Initial action published the default State | No initial action without a real fetch; never re-emit defaults |
| Button gating | `canX && != loading && != success` inside `onPressed` | `isLoading:` parameter + `onPressed: state.canX ? ... : null` |
| Naming | `load`, `set*`, `get*`, `handle*`, ID + object pairs | Verb vocabulary and State naming (Section 6.6) |

### 25.1.1 Final Status of Reviewed Items: Do Not Turn Proposals into New Requirements

These numbers refer to the supplementary review list in the conversation, not this document's chapter numbers.

| Review item | Owner decision | Exact implication for agents |
|---|---|---|
| 1: setState | Prohibited even for password visibility | Display field in State; action in Cubit; no agent-granted exception; report a concrete blocker |
| 2: Array-driven forms | Owner's explicit examples are authoritative | Fixed forms use explicit inputs; actual data loops and selector options are allowed |
| 3: BlocBuilder placement | Lower where readable and meaningful | Subscribe only changing sections; no mandatory builder per widget; higher levels allowed when builders are numerous |
| 4: String-based validation | Specific-method style from the reference | Field-specific update/validate and central validators; String dispatch for fixed forms prohibited |
| 5: Typed select | Explain a suitable solution | AppSelect<T> with meaningful values is proposed in Section 16.5; changing existing selects is not yet mandatory |
| 6: Decisions based on translations | Approved | Text is display-only; translation-based behavior/spacing conditions are prohibited |
| 7: Matching two enums by index | Pending review | Do not infer new refactoring or prohibitions from this document |
| 8: Fields without current consumption | Examine the reason; future integration is valid too | Do not automatically remove fields or introduce unjustified ceremonial statuses |
| 9: Request in State | Distinction from form State clarified; no blanket removal approved | Operational consumption is allowed; UI reads required data from State; do not automatically relocate request |
| 10: Empty callback | Currently acceptable | Do not change () {} button callbacks solely because of this review |
| 11: Shared validation and prepareState | Central validator required; emit intermediaries prohibited | No duplicate regex/checksum; pure helpers allowed; public/private State preparation/publication prohibited |

Open item 7 does not permit array-driven fixed forms or index-based field actions; item 2 explicitly prohibits them. Acceptance of empty button callbacks under item 10 does not permit empty Listeners or fabricated APIs. These are separate concerns.

### 25.2 Consolidation Status

Version 1.6 consolidates all approved principles from reference Sections 2, 3,
4, 6, 7 and 8 into this contract, preserves existing State conventions, and adds
the root AGENTS.md entry requirement and compliance gate. The two temporary reference Markdown files are removed. This documentation revision does
not modify Dart code or certify the compliance of the existing application.

Version 1.9 (2026-10-18) applies the owner simplicity amendment (top of this document): no `isClosed`, no BaseCubit, validate-once, no default re-emit, no dead code, naming rules. It changes documentation only.

Version 1.10 records the owner-approved Login-only shared Failure, prepared Persian
message/helper and Listener delivery, HTTP-200 business rejection mapping, blocked
Back during loading, resend button loading and single CAPTCHA session source.
It does not change the rules for other features or authorize broader refactors.

Version 1.11 extends the request-message/loading rules to all request-driven flows.
Version 1.12 (2026-10-25) removes effect/navigation sequence counters, documents
status-transition notification delivery and consumption of reusable commands,
and records independent feature ownership, direct image prefixes and core mapper placement.
These amendments supersede the earlier Login-only scope recorded in version 1.10.

### 25.3 Contract Adoption Does Not Authorize Automatic Refactoring

Root AGENTS.md already requires this contract. Older architecture and skill examples
do not weaken it. Future work to align their wording or add README links must
remain within an explicit documentation task; it is not required before agents
can or must comply with the rules here.

A sample flow, such as Login or Average Balance, may then be rewritten and reviewed under these rules in a separate task. Changing every flow requires defined scope and behavioral verification; accepting the style alone does not authorize global refactoring.

### 25.4 References

- [Project architecture document](architecture-smart-virtual-counter-v2-en.md)
- [Existing UI Skill](../.agents/skills/flutter-widget-ui-style/SKILL.md)
- [avp_ui integration guide](main-app-integration-guide.md)
- [UI-first policy](avp-ui-first-implementation-policy.md)
- [Official BlocProvider API](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocProvider-class.html)
- [Official BlocBuilder API](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocBuilder-class.html)
- [Official BlocListener API](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocListener-class.html)

Style rules in this document come from the owner's requirements. API links explain only widget technical behavior. A pattern being valid in Flutter does not make it desirable for this team's style.
