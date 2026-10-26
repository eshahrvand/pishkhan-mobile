---
name: pishkhan-cubit-clean-code
description: Use when writing, refactoring or reviewing a Cubit or its State in the Pishkhan (Smart Virtual Counter) Flutter app. Teaches how to avoid duplicated requests, duplicated copyWith groups and duplicated conditions, and how to emit only what the user's next step actually reads (no cleanup nulls/falses), within the project's Cubit contract.
---

# Pishkhan Cubit Clean Code

Short working rules for writing a clean Cubit. The full contract is `ui-cubit-state-agent-rules-en.md`; read it for anything not covered here. When this file and the contract disagree, the contract wins — report the disagreement.

## Workflow (do these in order)

1. **Inventory.** Before writing code, list every request operation in the feature and every user event that triggers it:

   | Operation | Owner action | Trigger actions |
      |---|---|---|
   | quote | `fetchQuote` | `selectDeposit`, `updateCount`, `submitRetry` |
   | submission | `submitVirtualCards` | button |

2. **Flow map.** Write the user's step-by-step path and, for each step, what it reads and where the user goes next:

   | Step / screen | State fields it reads | Next | Can user come back? | Cubit alive afterwards? |
      |---|---|---|---|---|
   | identity | `phoneNumber`, `nationalId`, `isXError`, `canRequestOtp`, captcha | otp | yes | yes |
   | otp | `otp`, `remainingSeconds`, `canSubmitLogin`, `loginStatus` | home (`navigation`) | no | **no** — released with its screen |

   This map is the only thing that decides which fields an emit may touch (see "Flow-aware emits").
3. **Write.** One owner action per operation. Trigger actions record their own input and delegate. Every emit passes the flow gate below.
4. **Review.** Run the duplication review and the flow review below before reporting anything as done.
5. **Report.** End with one line: `Duplication review: N repeated blocks found, N resolved (…). Flow review: N clears removed.`

## The core rule: one operation, one owner

The dependency call, the `.then` chain, the `switch (result)`, the request-ID handling and the loading reset group exist **once per operation**.

```dart
Future<void> selectDeposit(VirtualCardDeposit deposit) {
  emit(state.copyWith(deposit: deposit));
  return fetchQuote(); // delegate; never copy the request
}

Future<void> fetchQuote() {
  final requestId = ++_quoteRequestId;
  final canQuote = state.deposit != null && state.isCountValid;

  emit(
    state.copyWith(
      quoteStatus: canQuote ? RequestStatus.loading : RequestStatus.initial,
      quote: null,
      termsAccepted: false,
      canSubmit: false,
      failure: null,
      message: null,
    ),
  );

  if (!canQuote) return Future.value(); // real flow decision, lives only here

  return QuoteVirtualCards(_repository)(state.deposit!.id, state.count!).then((result) {
    if (requestId != _quoteRequestId) return;
    switch (result) {
      case Err(:final failure):
        emit(state.copyWith(quoteStatus: RequestStatus.failure, failure: failure, message: getRequestErrorMessage(failure)));
      case Success(:final data):
        emit(state.copyWith(quoteStatus: RequestStatus.success, quote: data));
    }
  });
}
```

Two synchronous emits for one user event (input emit + owner's loading emit) are accepted. Do not merge them back into one.

## Flow-aware emits: change only what the next step reads

A Cubit serves the user's path step by step. An emit is not a place to tidy up State. Before writing a `null`, `false`, `''`, `0`, `initial` or any "default" value into a `copyWith`, pass this gate for **each such field**:

1. **Who reads the old value after this action?** Name the widget, listener or action (use the flow map). No reader → delete the line. "It might be stale" or "to be safe" is not a reader.
2. **Does this action leave the flow?** (success followed by `navigation`, confirmed exit, final submit.) The Cubit is released with its screen (Section 8.3), so nothing needs cleaning. Emit only the outcome: the status, the result/receipt and the `navigation` command. No clearing of inputs, validity flags, errors, countdowns, retry fields or earlier step data.
3. **Can the user stay on, or come back to, this screen?** If back is possible, keep the previous step's data. Clear a field only when the user stays and the old value would now be wrong or dangerous (for example a stale quote that would keep Submit enabled after the count changed). That is the only legitimate reason, and it must be visible in the flow map.
4. **Is the field already at that value?** If nothing set it since the initial State or since the loading emit, writing it again is noise (Minimal Cubit Rule 5).

**Always allowed (contract-mandated, not "cleanup"):**
- `failure: null, message: null` in the **loading** emit of a request (starting a request clears the previous failure and message). Do not repeat them in the success emit.
- `canX: false` in the **success** emit of a request when the screen stays visible until navigation happens (Minimal Cubit Rule 8, prevents a second tap).
- A real reset event under Section 6.9 (`State.initial(...)`).

### Before / after (from `VirtualCardCubit`)

```dart
// Before: the user is leaving the flow, yet the success emit tidies up.
case Success(:final data):
  emit(
    state.copyWith(
      submissionStatus: RequestStatus.success,
      receipt: data,
      retryAction: null, // nobody reads it: the screen navigates away
      navigation: FlowNavigation.home,
      message: null,     // already cleared by the loading emit
    ),
  );

// After: only the outcome of the flow.
case Success(:final data):
  emit(
    state.copyWith(
      submissionStatus: RequestStatus.success,
      receipt: data,
      navigation: FlowNavigation.home,
    ),
  );
```

```dart
// Justified: on failure the user STAYS and may retry, so these have readers.
case Err(:final failure):
  emit(
    state.copyWith(
      submissionStatus: RequestStatus.failure,
      isEditable: true,
      canSubmit: ...,
      retryAction: VirtualCardRetryAction.submission,
      canRetry: ...,
      failure: failure,
      message: getRequestErrorMessage(failure),
    ),
  );
```

Same check for loading emits: a field that is still at its initial value (nothing could have changed it before this request) does not need `false`/`null` again. Decide it from the flow map, not by habit.

### Per-action cheat sheet

| Action | Emit |
|---|---|
| Input update | The input, its `isXValid`/`isXError`, and the aggregate flags that depend on it. Nothing else. |
| Request start | `status: loading`, `failure: null`, `message: null`, plus only the stale **result or flag the still-visible form could act on** (stale quote, `canSubmit`). |
| Success that **leaves** the flow | `status: success`, the result/receipt, `navigation`. Nothing else. |
| Success that **stays** on screen | `status: success`, the data, and the flags the **next step** needs. |
| Failure | `status: failure`, `failure`, `message`, and retry fields only if a retry control exists. |
| Go to the next step | `step` and what the next step needs. Keep earlier step data if the user can come back. |
| Back / exit | The `navigation` command only. |

## Which fix for which duplication

| Duplicated thing | Do | Never |
|---|---|---|
| Same request / `.then` / switch in several actions | Delegate to the owner action | Copy it; `_publishSuccess`; pass the switch as a callback |
| 3+ identical `copyWith` fields in 2+ actions | They are one operation: delegate | `_resetX()` or any function that builds/emits State |
| Same boolean condition 2+ times (even one line) | Private pure `bool _canX(...)` | A local alias in each action |
| Same calculation | Private pure helper returning the value | A helper that returns State |
| Reset of the whole form | `emit(State.initial(...))` in the action (Section 6.9) | A reset helper or extra State factory |

A condition used only **once**: one/two lines stay inline in `copyWith`; longer goes into a named calculation function (not a local alias).

## Always (Minimal Cubit Rules)

- No `isClosed`, no `BaseCubit`/`safeEmit`, no `catchError`/`try-catch`, no `async/await` in Cubit actions. Return a `.then` chain.
- No defensive `if (...) return;` on UI-guaranteed preconditions. A start-or-skip decision based on real data is allowed, once, in the owner action.
- Pass the rendered object or a non-null value, never an ID the Cubit must find again.
- `updateX` runs only X's own validator, once, and stores `isXValid` and `isXError`. Aggregates read stored `isXValid` flags.
- Emit only the fields the action changes, and only those the next step reads (see "Flow-aware emits"). No dead methods or State fields.
- Names: `fetchX`, `updateX`, `selectX`, `toggleX`, `validateX`, `submitX`, `requestX`, `applyX`, `cancelX`, `resetX`, `openX`. Never `get`, `set`, `load`, `handle`, `process`, `init`.
- Request ID only in the owner action, only for real overlapping responses.
- `emit(state.copyWith(...))` is written inside the action. No State-building or State-publishing helper, public or private, whatever its name.

## Duplication review (before reporting done)

1. Search the Cubit for each dependency call and for `.then(`: each must appear once per operation.
2. Search for `switch (result)`: once per operation.
3. Compare the `copyWith` blocks of all actions: no group of 3+ identical fields in 2+ actions.
4. Look for any boolean expression written twice.
5. Fix every finding as above. If something cannot be fixed within the contract, report the exact location and the rule pair that collides. Do not invent a new pattern.

## Flow review (before reporting done)

1. List every field written as `null`, `false`, `''`, `0` or an initial value in an emit you wrote or changed.
2. For each one, name the step in the flow map that reads the old value. Write the answer in your head or notes; if you cannot name a reader, remove the line.
3. Check every success/exit emit: if the flow ends there, it contains only the outcome and `navigation`.
4. Check that no cleanup was added to `close()` or to a "just in case" action.
5. Report the count of removed clears in the final line.

## When rules collide

Delegation beats one-emit-per-event. A repeated predicate beats the inline rule. Rules beat examples. A later owner amendment beats earlier text. An unlisted conflict is reported, never resolved silently.