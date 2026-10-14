# UI, Cubit and State Coding Contract for the Team and Agents

**Project:** Smart Virtual Counter — `pishkhan_mobile`  
**Version:** 1.1 — owner-approved rules, with explicitly identified open items  
**Date:** 2026-10-14  
**Scope:** Presentation coding style, State management and readability rules  
**Status:** Documentation only at this stage; no application refactoring or behavior changes have been performed.

This document turns the project owner's requirements and supplied examples into explicit rules. A team member opening a screen should be able to see how the UI is built, how State is read and how Cubit is called, without navigating through multiple wrappers and files to understand a simple form.

“Required” and “prohibited” in this document are owner-approved style instructions. Sections explicitly marked “recommendation” or “pending review” do not create new requirements. This document does not authorize agents to change code automatically or automatically rewrite the [architecture document](architecture-smart-virtual-counter-v2-en.md) or the [current UI skill](../.agents/skills/flutter-widget-ui-style/SKILL.md). When styles conflict, the owner's explicit instructions recorded here take precedence over older examples. Boundaries and open decisions are recorded in Section 25.

**Interpretation rule:** An agent must not infer permission to introduce new abstractions, wrappers, parallel State or exceptions to prohibitions from “readability,” “cleaner code,” “extensibility” or possible future needs. Do not evade a prohibition by renaming the same pattern. Do not turn “allowed” into “mandatory for every screen.” If the required behavior truly cannot be implemented under this contract, report the specific issue rather than inventing a replacement rule.

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
| Creating the screen Cubit | `BlocProvider(create: ...)` inside the screen's `build`; no extra Screen/View |
| Resolving Cubit | `context.read<MyCubit>()` using a context below the Provider |
| State | One plain Freezed data class, without handwritten getters or logic |
| Initial value | A readable `State.initial(...)` constructor; only one factory |
| Rendering | Read `state.field` directly in widget arguments |
| Loading | Compare `state.submissionStatus == RequestStatus.loading` directly |
| Business decisions | Calculate in a Cubit action or specific function and store the result in State |
| Display-state changes | Even password visibility and section expansion belong in Cubit/State; routine `setState` use is prohibited |
| Fixed forms | Explicit fields like the owner's example; parallel arrays and index-based dispatch are prohibited |
| Text depending on multiple steps | A named UI function returning `String` |
| Side effects | UI listener or callback; outside builders and Cubit |
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

- Specific methods such as `updatePhoneNumber`, `updateOtp` and `requestOtp`.
- Explicit, traceable `emit(state.copyWith(...))` calls.
- State containing field values, request statuses and action eligibility.
- Provider creation inside the screen, followed by Listener and Scaffold.
- Direct State reads in arguments, without converting State into another ViewModel.
- `buildWhen` and `listenWhen` at the consumption point.
- Widgets familiar to the team and the existing design-system package.
- Extracting a form, OTP section or substantial flow section, without splitting titles, spacing and icons into independent files.

### 2.2 Patterns Not to Copy Verbatim from the Other Application

The Axino example is a style reference; it does not define this project's network, storage or security contracts.

| Reference pattern | Decision for this project |
|---|---|
| `locator.get` inside Cubit | Inject dependencies through the constructor; do not introduce a new service locator |
| `S.current` | Approved direct localization access; implementation belongs to a separate task |
| A shared enum containing `otpSubmitting` and `authLoading` | Independent operations use independent statuses with the existing `RequestStatus` |
| Two emits for an input and button eligibility | Prefer one emit for a complete, consistent snapshot |
| `void ... async` | Awaitable operations use `Future<void>` |
| No `isClosed` check after await | Preserve disposal guards and stale-response guards where needed |
| Controllers in StatelessWidget and static focus nodes | A StatefulWidget owns the lifecycle and disposes resources |
| Printing OTPs or PINs | Prohibited; sensitive data must not enter logs |
| Storing raw passwords or a fallback such as `0000` | Do not incorporate this into the project's contract |
| Updating UI after a callback using old State | Read the action result or fresh State value |
| OTP examples using lengths 4, 6 and a `> 4` check | Determine the permitted length from the service contract and use it consistently |

These differences do not change the team's preferred style; they prevent lifecycle and behavioral defects from spreading.

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
- Preventing duplicate requests and stale responses;
- Managing timers owned by the flow.

Business logic reused by multiple consumers remains in Domain. “Move logic into Cubit” does not mean moving all banking rules from UseCase into Cubit. Cubit coordinates form behavior.

### 3.3 UI: Layout, Rendering and Flutter Interaction

UI is responsible for:

- Building the widget tree;
- Choosing localized text, colors and spacing;
- Managing focus, scroll and controllers;
- Showing dialogs, sheets and snackbars;
- Navigation and host callbacks;
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
| Scroll to the top after a step change | UI listener |
| Close a sheet | UI |
| Show or hide the password? | State field and Cubit action; UI renders the value |
| Display a password-mismatch error? | Validation and error field in Cubit/State; focus-loss event from UI |
| Store and retrieve tokens | Authentication infrastructure, outside widgets |
| Track a screen or click | A defined side-effect location; never a repeatedly executed build |

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
Future<void> requestOtp() async { ... }
Future<void> submitLogin() async { ... }
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

- Do not remove a field solely because “the UI does not currently use it.”
- Do not add ceremonial status fields to every Cubit because “they might be needed later.”
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

### 6.1 Readable Constructor and Injected Dependencies

```dart
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.requestOtpUseCase,
    required this.submitLoginUseCase,
    AuthState initialState = const AuthState.initial(),
  }) : super(initialState);

  final RequestOtpUseCase requestOtpUseCase;
  final SubmitLoginUseCase submitLoginUseCase;

  Timer? _timer;
}
```

`initialState` remains for compatibility with the project's contract and tests. Ordinary UI need not pass the default State every time. A real entry parameter such as `initialDepositNumber` is different from a complete State snapshot.

Adopt the plain State structure and explicit methods from the reference, not the other application's use-case names or dependency lookup mechanism.

### 6.2 Small, Specific Actions

This example assumes numeric input has already been normalized in UI and identity editing is locked during an async request.

```dart
void updatePhoneNumber(String value) {
  if (state.otpRequestStatus == RequestStatus.loading ||
      state.loginStatus == RequestStatus.loading) {
    return;
  }

  emit(
    state.copyWith(
      phoneNumber: value,
      isPhoneNumberError: false,
      canRequestOtp: checkOtpButtonEnable(
        phoneNumber: value,
        nationalId: state.nationalId,
      ),
      otpRequestStatus: RequestStatus.initial,
      otpRequestFailure: null,
    ),
  );
}

bool checkOtpButtonEnable({
  required String phoneNumber,
  required String nationalId,
}) {
  return PhoneNumberValidator.isValid(phoneNumber) &&
      NationalCodeValidator.isValid(nationalId);
}
```

`checkOtpButtonEnable` belongs to Cubit and is not called by UI. It receives the fresh input so its decision does not use the old `state.phoneNumber`.

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

**A pure calculation helper is different.** A function such as `checkOtpButtonEnable(...)` or `calculateSelectedCardsTotal(...)` may return a `bool` or amount; it must not construct State, emit, mutate inputs implicitly or connect UI to a rules facade.

```dart
// Allowed: one specific calculation, without constructing State or emitting.
bool checkOtpButtonEnable({
  required String phoneNumber,
  required String nationalId,
}) {
  return PhoneNumberValidator.isValid(phoneNumber) &&
      NationalCodeValidator.isValid(nationalId);
}

// Action with explicit changes
void updateNationalId(String value) {
  emit(
    state.copyWith(
      nationalId: value,
      isNationalIdError:
          value.length < 10 ? false : !NationalCodeValidator.isValid(value),
      canRequestOtp: checkOtpButtonEnable(
        phoneNumber: state.phoneNumber,
        nationalId: value,
      ),
    ),
  );
}
```

This snippet illustrates the action-body style. Flow guards, such as prohibiting edits during a request or after success, must still be explicitly preserved in the actual method. A short example is not permission to remove guards.

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
  emit(
    state.copyWith(
      isNationalIdError: !NationalCodeValidator.isValid(state.nationalId),
    ),
  );
}

void validatePhoneNumber() {
  emit(
    state.copyWith(
      isPhoneNumberError: !PhoneNumberValidator.isValid(state.phoneNumber),
    ),
  );
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

Error-display timing must be explicit. Following the reference, incomplete input may remain without a displayed error while typing. On completion, focus loss and submit, call the central validator. Button eligibility may be calculated on each change. This defined behavior differs from showing an error prematurely on every keystroke, and no error is stored through `setState`.

String field identifiers in server error contracts are a separate concern. Do not infer automatic changes to server fieldErrors contracts from the prohibition on String-based dispatch in fixed forms.

## 7. Calculations and Dependent Fields

### 7.1 Calculate Totals in Cubit

```dart
void selectCards(Set<String> selectedIds) {
  if (state.submissionStatus == RequestStatus.loading ||
      state.submissionStatus == RequestStatus.success) {
    return;
  }

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

### 8.1 Readable Loading Pattern

This example uses the actual `CardServicesRepository` and `LoadCardServiceCatalog` contracts. The proposed State contains `catalogStatus`, `catalog` and `catalogFailure`.

```dart
int _catalogRequestId = 0;

Future<void> loadCatalog() async {
  if (isClosed) return;

  final requestId = ++_catalogRequestId;

  emit(
    state.copyWith(
      catalogStatus: RequestStatus.loading,
      catalogFailure: null,
    ),
  );

  final result = await LoadCardServiceCatalog(repository)();

  if (isClosed || requestId != _catalogRequestId) return;

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
}
```

Unexpected exceptions must become `Err` at the UseCase/repository boundary. If the dependency does not guarantee this, the action must also use `try/catch` with an explicit failure. Do not assume that every Future always resolves to Result.

### 8.2 Submission: A Guard Independent of Button Appearance

```dart
Future<void> submit() async {
  if (isClosed ||
      !state.canSubmit ||
      state.submissionStatus == RequestStatus.loading ||
      state.submissionStatus == RequestStatus.success) {
    return;
  }

  final request = createSubmissionRequest();

  emit(
    state.copyWith(
      submissionStatus: RequestStatus.loading,
      submissionFailure: null,
    ),
  );

  final result = await submitUseCase(request);

  if (isClosed) return;

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
}
```

`createSubmissionRequest` illustrates a specific request-construction function in Cubit, not a UI calculation function. The snippet assumes editing/reset/loading are locked during submission. If adapter replacement or reset can occur concurrently, the operation's request ID must also be checked.

### 8.3 Mandatory Async Rules

- Awaitable operations return `Future<void>`; do not write `void async`.
- Set the status to loading before awaiting.
- Check `isClosed` after awaiting.
- Overlapping loads or quotes require a generation/request ID.
- A stale response must not overwrite a newer selection.
- Lock editable fields inside Cubit as well during sensitive operations.
- Retrying the same banking request preserves the same idempotency key.
- Changing the payload after failure refreshes request identity according to the service contract.
- Client idempotency does not replace the server guarantee.
- `.then` is allowed, but return/await the chain and provide guards and a failure branch. This document's baseline style is `async/await`.

### 8.4 Errors Are Localized in UI

Do not turn Failure into raw display text in Domain. UI may remain simple:

```dart
if (state.catalogStatus == RequestStatus.failure)
  Text(S.current.dashboardLoadError),
```

When different codes require different messages, write a named display helper such as `getFailureMessage(failure)`. It uses `S.current` and does not receive BuildContext solely to retrieve text. UI must not inspect `DioException` or error DTOs directly.

## 9. BlocProvider Inside the Screen

### 9.1 The Team's Baseline Screen Structure

Write the screen with a block body. Provider is inside this same `build`, and the remainder of the tree is directly visible:

```dart
class AverageBalanceScreen extends StatefulWidget {
  const AverageBalanceScreen({
    super.key,
    required this.repository,
    this.initialDepositNumber,
    this.onCompleted,
  });

  final DepositCertificatesRepository repository;
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
    return BlocProvider(
      create: (context) => AverageBalanceCubit(
        repository: widget.repository,
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
                        onPressed: state.canContinue &&
                                state.submissionStatus != RequestStatus.loading &&
                                state.submissionStatus != RequestStatus.success
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

- Create the Cubit with `create` for a new screen.
- Do not create the same Cubit again in `initState`.
- Do not manually `close` a Cubit owned by `create`.
- Do not add `bloc: _cubit` when the correct Provider is already an ancestor.
- Use `BlocProvider.value` only for an actual existing instance, such as continuing the same flow in a sheet.
- Constructing `Cubit()` inside the `value` argument is prohibited.

### 9.4 Ordinary Rebuilds Differ from Fresh Flow Entry

Rebuilding a widget with the same type, position and Provider element identity does not itself recreate Cubit. Changing a Key or removing the subtree may dispose the previous instance; do not conceal resets this way.

A new route and fresh scope suffice for a new service entry. Support runtime repository changes only when the screen API actually needs them. Do not add generic `didUpdateWidget` and `changeRepository` handling to every screen by default. If a new entry or account change in the same scope must reset data, make that behavior explicit, testable and action-specific.

### 9.5 Context Below the Provider

This common mistake is prohibited:

```dart
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => AuthCubit(...),
    child: AppButton(
      onPressed: () {
        // This context belongs above the Provider.
        context.read<AuthCubit>().requestOtp();
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
            context.read<AuthCubit>().requestOtp();
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

`buildWhen` filters State-triggered rebuilds; it is not a business-behavior guard or a guarantee that “this builder never runs.” Request guards remain necessary in Cubit. [Official BlocBuilder reference](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocBuilder-class.html)

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
      onPressed: state.canSubmitLogin &&
              state.loginStatus != RequestStatus.loading &&
              state.loginStatus != RequestStatus.success
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

If `buildWhen` needs 15–20 fields, review the subtree boundary first. Do not convert State into a record or another object just to shorten it. If a large section truly needs all State changes, a regular builder with an explanation of that need is preferable to an incomplete predicate.

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

`onChanged: cubit.updateNationalId` is technically valid, but the explicit form above is the team's baseline. Do not write long callbacks combining calculations, multiple requests and navigation inside arguments. Move calculations to Cubit and UI coordination to a clearly named behavioral method.

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
  if (state.draftFilter == null) return;
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
  if (state.draftFilter == null) return;
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
  if (state.draftFilter == null) return;

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

The current example calculates `footerAction` from category inside the builder. Since that choice determines which service is available, this contract proposes making the decision in Cubit:

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
      // Dispatch the route through the project's existing navigation contract.
      openCardAction(context, state.footerAction!);
    },
  ),
```

Concrete navigation routes remain in UI/router. Cubit must not call `context.push` or `ScaffoldMessenger`. A clearly named adapter such as `openCardAction` is allowed; do not introduce chains of generic helpers to hide one simple action.

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

Convert “All” into no condition and apply the filter inside Cubit on Apply. Actual implementation also preserves draft-open checks and flow guards. This example illustrates only typed values/callbacks, not the complete filter flow.

The `options` list above is not a prohibited form array; it contains options for **one selector**, each with explicit label and value. Card/deposit IDs that are genuinely Strings remain Strings. Do not turn this proposal into generic wrappers, generic mappers or enums for inherently textual data.

## 17. Dialogs and Bottom Sheets

### 17.1 Allowed Pattern: Opening Function + Public Class

The function only opens the sheet and supplies a public widget; a large UI tree is not hidden in its callback.

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
    if (!cubit.isClosed) cubit.cancelFilter();
  }
}
```

In `CardFilterSheet`, Apply first calls `applyFilter`, then closes the modal. `cancelFilter` must return without extra effects when `draftFilter == null`. After Apply, finally must not clear the committed filter.

This `.value` use is an explicit existing-instance exception; the sheet must not close the screen Cubit.

### 17.4 Deletion Dialog: UI Confirms, Cubit Deletes

```dart
Future<void> confirmAddressRemoval(
  BuildContext context,
  CertificateAddress address,
) async {
  final confirmed = await showAddressDeleteSheet(context, address);

  if (!context.mounted || confirmed != true) return;

  context.read<AverageBalanceCubit>().removeAddress();
}
```

The function name explains its behavior. This callback neither filters the address list nor calculates `canContinue`. The dialog itself is defined in an independent public widget. If Cubit deletes by ID, pass the stable ID of the confirmed snapshot.

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
              state.loginStatus != RequestStatus.loading &&
              state.loginStatus != RequestStatus.success,
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
      if (isClosed) {
        stopOtpTimer();
        return;
      }

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

A deadline avoids measuring elapsed time incorrectly through callback counts after delayed ticks or backgrounding. This is a display countdown; the server determines actual OTP validity and expiry. If immediate refresh on resumed is required, UI lifecycle requests fresh time through a Cubit action. Do not move MethodChannel or BuildContext into Cubit.

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

**Explicit owner instruction:** Do not routinely use `setState`. Even password visibility, summary expansion and visual selections require a Freezed State field and a Cubit action. “This is only UI state” is not an exception.

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
        context.read<SecondPasswordCubit>().passwordChanged(value);
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

If no implementation is possible with the flow contract and available APIs, a case-specific exception may be reviewed. Before creating an exception, the agent must report the specific technical limitation and alternatives examined, and obtain the owner's decision on that case. Shorter code, Flutter habits or “purely visual state” are not grounds for an exception. Do not replace `setState` with parallel State in ValueNotifier or a new notifier to evade this rule. Ordinary use of existing animation/controllers for Flutter lifecycle and behavior is a separate concern.

## 20. Multi-Step Flows and Back

### 20.1 One Action for the Primary Button

Instead of repeating submit/next decisions in several UI callbacks:

```dart
Future<void> continueFlow() async {
  if (!state.canContinue ||
      state.submissionStatus == RequestStatus.loading ||
      state.submissionStatus == RequestStatus.success) {
    return;
  }

  if (state.step == IssuanceStep.confirmation) {
    await submit();
    return;
  }

  nextStep();
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
- During submission, leaving and editing are locked according to the flow contract.
- The first step of a form with discardable input requires exit confirmation.
- After a successful receipt, leave the flow using `go` to the approved destination; the user must not return to a form that can be submitted again.

Allowed UI method example:

```dart
Future<void> handleFlowBack(BuildContext context) async {
  if (context.read<CardIssuanceCubit>().state.submissionStatus ==
      RequestStatus.loading) {
    return;
  }

  if (context.read<CardIssuanceCubit>().back()) return;

  final confirmed = await showExitFlowConfirmation(context);

  if (!context.mounted || confirmed != true) return;

  NavigationActions.back(context);
}
```

This example handles Back before form success; the receipt screen has its own exit path. When `PopScope.canPop` blocks exit, confirmed exit needs an explicit route to release the pop restriction or use `go`. Do not send another `pop` to the blocked scope. Actual changes must test this behavior with system Back.

The UI method above coordinates side effects. Unlike `_body`, it neither creates a widget tree nor calculates steps.

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
- Cubit and Domain do not access `S.current`; they produce error codes, enums and data.
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

### 22.2 CardFeaturesScreen with Manually Owned Cubit

**Readability issue:** The screen creates/closes `_cubit`, supplies explicit `bloc:`, and also contains large UI sections and methods returning Widget.

**Proposed rule:** Provider owns Cubit; controllers, focus and scroll remain owned by widget State. Extract the substantial list into public `CardFeaturesContent` and remove `_content`. Category and query changes update the prepared list in State.

Retain `didUpdateWidget` and `changeRepository` only for a runtime replacement need. Do not add them automatically for testing or hypothetical future use.

### 22.3 _revealCategory and Chip Keys

**Issue:** Index 3 and scattered conditions tie scrolling to enum position. GlobalKeys for all chips add mental overhead.

**Rule:** Scrolling is UI logic and cannot move into Cubit. Start with the simplest required user behavior using existing scroll APIs. If ensureVisible needs a key, retain the specific reason and necessary behavior; do not add keys merely for tests or to every chip. Magic indices must not replace behavioral names.

### 22.4 _request and _more

These methods are not inherently invalid: sheets and navigation belong in UI. The problem arises when one method mixes eligibility, payloads, routing, messages and selection calculations.

**Rule:** Selection and availability belong in Cubit, action sheets in UI, and route dispatch in the existing router contract. A short UI method named `openCardActions` or `handleCardAction` is allowed. A side-effect method being private is not itself a reason to move it into Cubit.

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
| Disabled button as the primary guard | Explicit action guard |
| Navigator in Cubit | UI listener/callback |
| Validation code in a widget | Validator/UseCase, coordinated by Cubit |
| Mock inside every screen by default | Explicit dependency; mock in example-environment composition |
| Fake success for an unimplemented action | Unavailable message or explicit host callback |
| Analytics event inside build | Appropriate lifecycle/observer or callback |
| setState for password visibility, summary or form errors | State field and explicit Cubit action |
| labels/hints/values arrays and switch(index) for fixed forms | Explicit inputs following the owner's example |
| validateField('phone') for fixed forms | Field-specific update/validate and central validator |
| Localized-text comparison for decisions | Meaningful identifier or explicit layout |
| Deleting fields solely because current UI does not read them | Check operational responsibilities or future service contracts |
| Mandatory builder for every Text and Icon | Builder around a meaningful changing section; a higher level to avoid fragmentation |

For mock dependencies, an example flow can connect to MockRepository in route composition while the screen keeps its actual interface. This proposal does not authorize changing existing adapters without a task.

## 24. Agent Instructions and Review Checklists

### 24.1 Short Text Suitable for Agent Instructions

```text
Follow the approved UI/Cubit/State contract for this project's Presentation code.

1. Write UI in the team's familiar style with block-body build methods.
2. Place BlocProvider(create) at the screen/actual flow entry. Do not add private
   Screen/View wrappers, manually owned Cubits or explicit bloc: without need.
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
16. Preserve duplicate-submission, isClosed, stale-response and idempotency safeguards.
17. No unsolicited global refactoring, package changes or new dependencies.
18. Do not use setState even for password/summary display state. Keep values in State
    and actions in Cubit. Do not use parallel notifiers to evade this rule.
    Report unavoidable technical limitations before creating an exception.
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
```

This text records approved rules and boundaries of open decisions. It may be placed in AGENTS/Skill through a separate documentation task. Those files have not been changed.

### 24.2 Before Writing UI

- [ ] Actual screen needs, route inputs and exit callbacks are defined.
- [ ] Existing `avp_ui` and app-shared components have been checked.
- [ ] State types and operation statuses are identified.
- [ ] Cubit decisions and UI rendering responsibilities are distinct.
- [ ] No new abstraction has been designed for a simple screen.
- [ ] No out-of-scope change has been assumed necessary.

### 24.3 While Writing Cubit

- [ ] The constructor injects required dependencies.
- [ ] Every action has a clear behavioral name.
- [ ] Input emits update dependent results in the same snapshot.
- [ ] Helpers name their calculation; UI does not obtain rules from them.
- [ ] Helpers neither construct State nor emit; changes are visible in the action.
- [ ] Each field is validated through the owner's specific-method style and central validator.
- [ ] Independent operations have independent statuses.
- [ ] Submit checks eligibility again inside Cubit.
- [ ] Loading is recorded before await.
- [ ] Disposal and stale responses are checked after await.
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
- [ ] No private View wrapper or default Key.
- [ ] Callbacks use the correct context below Provider.
- [ ] State is read directly in arguments.
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
3. Double taps do not cause two submissions.
4. Failure preserves data needed for retry.
5. An old quote response does not replace a newer selection.
6. Closing a flow prevents late emits.
7. Back/outside dismissal of the filter sheet discards the draft.
8. Ordinary form rebuilds do not reset Cubit or inputs.
9. System Back and in-UI Back behave consistently.
10. After success, a resubmittable form does not remain in the stack.

Do not write tests that mirror implementation just to verify a variable declaration or Padding placement. For behavioral changes, run relevant tests and report results precisely. This task has only produced documentation; application execution tests have not been run.

### 24.7 How to Document an Exception

Exceptions require real needs, explained near the code:

```dart
// This row has an internal editor; reordering must keep its value with the card ID.
key: ValueKey(card.id),
```

“For clean code” or “for tests” alone is insufficient. If an exception changes the team's baseline style, report its reason rather than turning it into a general project pattern.

## 25. Differences from Existing Documentation and Adoption Path

### 25.1 Proposed Changes Relative to Existing Rules

| Topic | Existing sources | This document's proposal |
|---|---|---|
| State factory | `State(...)` and independently generated State output | Reference style: `State.initial(...)`, part of Cubit |
| Injected initialState | Required in Section 12 | Supported by the constructor; UI passes it only when needed |
| Provider and View | Architecture example uses a child View | Simple screens have no private View wrapper; Provider and UI share the same build |
| State preparation | Section 12 permits a coordinating private helper | New owner instruction: State construction/publication intermediaries are absolutely prohibited; helpers return pure values only |
| Extracted widget class | Skill permits local helpers in the same file | Owner requirement: public widget in its own file |
| File size | Skill suggests around 200 and a 200–300 range | Review extraction around 150–200; split responsibilities without fragmentation |
| Selector | Skill/architecture generally allow it | `BlocBuilder + buildWhen` by default; selectors require specific need |
| Getters and aliases | Architecture mostly prohibits them | Reinforced through direct examples and precise checklists |
| Material | Some Skill sections use absolute wording | Basic layout is allowed; do not replace controls that have package equivalents |
| Localization | Current code uses gen-l10n and context.l10n | Approved S.current style; code migration has not occurred |
| Analytics in build | Skill contains an example | Repeated side effects in build are prohibited |
| Keys | Skill includes general exceptions | Exceptions require clear behavioral needs; automatic Provider resets are not default |
| setState | Some current forms keep display/error state locally | Owner instruction: display state and errors belong in State; setState requires a decision on an unavoidable limitation |
| Fixed forms | Some forms use parallel arrays | Explicit fields like the owner's examples; no renderer or index-based dispatch |
| Builder level | “Lowest subtree” could be read absolutely | Meaningful changing sections; higher-level grouping is allowed for readability |

### 25.1.1 Final Status of Reviewed Items: Do Not Turn Proposals into New Requirements

These numbers refer to the supplementary review list in the conversation, not this document's chapter numbers.

| Review item | Owner decision | Exact implication for agents |
|---|---|---|
| 1: setState | Prohibited even for password visibility | Display field in State; action in Cubit; decide unavoidable limitations separately |
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

### 25.2 What Has Been Done

Only this Markdown file was updated in this revision. Dart files, application behavior, dependencies, Skill and README were not changed. The architecture's documentation update for `S.current` belonged to the previous request; this revision did not change the architecture again. The existing `pubspec.yaml` change also belongs to the prior workspace state and was not modified in this task.

### 25.3 Contract Adoption Does Not Authorize Automatic Refactoring

To align other sources with approved rules, three documentation changes may be performed in a specific task:

1. Align Section 12 and its Provider example with this contract;
2. Correct the Skill to remove other-project names/APIs and resolve contradictions;
3. Link the approved contract in README and agent entry instructions.

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


