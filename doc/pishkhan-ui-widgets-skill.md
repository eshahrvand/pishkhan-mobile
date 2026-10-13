---
name: "pishkhan-ui-widgets"
description: "Use when writing, refactoring, splitting or reviewing Flutter UI in the Pishkhan (Smart Virtual Counter) app: screens, widgets, sections, cards, bottom sheets, skeletons, tab views, forms. Teaches how to structure UI code and break big screens into small widgets, within the project architecture."
---

# Pishkhan UI Code: Structure and Widget Splitting

This skill is about HOW UI code is written and split. It is distilled from the author's own screens (a family of log/report screens: screen shell, section classes, period views, shimmer, empty state, bottom sheets) and adapted to the project's architecture (doc v2.0.0). When writing or changing UI, follow this skill first; the architecture constraints in §5 always apply on top.

Illustrative names: examples use `Avp...` widget names, `AppColors`, `AppTypography`, `AppSpacing`, and `context.l10n`. Only `AppColors`, `AppTypography`, `AsyncStateBuilder`, `DirectionalIcon`, `DigitNormalizer` and the "form step shell" are named by the architecture doc. Before using any `avp_ui` / l10n / token name, read `packages/avp_ui/lib/avp_ui.dart` and `tokens/` for the real name and constructor. Never guess one.

## 1. The shape of every screen

Every screen, however big, has the same skeleton:

```text
XxxScreen                      thin shell (<= ~100 lines)
 ├─ page scaffold + app bar (title, back, action widgets)
 ├─ BlocListener(s)            side effects only (navigate, snackbar, close sheet, refresh)
 └─ XxxBody                    ONE state-to-view switch (loading / failure / empty / content)
     └─ content = Column of SECTIONS
         ├─ XxxHeaderSection
         ├─ XxxChartSection / XxxFormSection / XxxListSection
         └─ XxxSummaryCard ...
```

A section is a named block of the page (what a designer would circle in Figma). Sections are classes in their own files. Inside a section you find small reusable pieces (rows, headers, badges). The screen file never contains chart, list, form or card markup.

## 2. How to split a big UI: the procedure

Follow these steps in order, both when writing new UI and when refactoring an existing big file.

1. **Read the whole design/file first.** Write the widget tree as an indented outline (names only, no code). Do not start typing widgets before the outline exists.
2. **Mark blocks.** Every block you can name out loud becomes a candidate: "averages card", "empty state", "period tabs", "legend row".
3. **Classify each block** with the table below. The kind decides its name, location and inputs.
4. **Find repetition.** Any shape that appears twice (even with different text/icons/values) is ONE widget with parameters. Any list of near-identical rows becomes data plus a loop.
5. **Decide state access.** Leaf widgets receive values and callbacks. Only sections (or the body) read a slice of Cubit state with `BlocSelector`.
6. **Write bottom-up:** leaves, then sections, then the body, then the screen.
7. **Re-check sizes** (§2.2) and run the checklist (§7).

### 2.1 Widget kinds

| Kind | Name pattern | Lives in | Receives |
|---|---|---|---|
| Screen | `XxxScreen` | `screens/` | nothing (reads context); is the route target |
| Body | `XxxBody` | `widgets/` | nothing; owns the status switch |
| Section | `XxxSection` | `widgets/` | reads its own state slice via `BlocSelector` |
| Card | `XxxCard` | `widgets/` | values + callbacks |
| Row / tile | `XxxRow`, `XxxTile` | `widgets/` | one item + `onTap` |
| Small piece | `SectionHeader`, `LegendRow`, `StatusBadge` | `widgets/` (or `shared/`, or `avp_ui` if cross-module) | primitives |
| Period/tab view | `XxxWeeklyView`, `XxxMonthlyView` | `widgets/` | its slice via `BlocSelector` |
| Skeleton | `XxxSkeleton` | `widgets/` | nothing; mirrors the final layout |
| Empty state | `XxxEmpty` | `widgets/` | optional CTA callback |
| Overlay | `showXxxSheet()` + `XxxSheet` | `widgets/` (one file) | props + callbacks |

### 2.2 Size and trigger rules

Extract a block into its own class when ANY is true:
- `build` is longer than about 60 lines, or nesting is deeper than about 3 levels.
- It has a name you can say out loud.
- It appears twice or more.
- It reads a different state slice than its neighbours (rebuild boundary).
- It has its own loading/empty/error variant, or owns callbacks / opens an overlay.
- The file passes about 150 lines.

Targets: leaf 10 to 50 lines, section 30 to 80, screen about 100 or fewer.

Do NOT over-split: a single `Padding` + one label used once does not need a class. Every extracted class must have a meaningful name and a reason (reuse, rebuild boundary, readability of a long tree).

### 2.3 Forbidden shortcuts

- `Widget _buildX()` / `Widget getX()` helper methods returning subtrees: use a `const` class (hot reload, rebuild isolation, testability).
- Passing the entire `State` object to children: pass values and typed callbacks (`ValueChanged<T>`, `VoidCallback`, never bare `Function`).
- Copy-pasting a screen or widget per variant: one parameterised widget.
- Computations in `build` (percentages, averages, date maths, `switch(index)` to pick a title): business logic belongs in a use case, display derivations in a small presentation mapper/extension or an `avp_ui` formatter.
- Nested ternaries in the tree: use `switch` expressions or extract.
- `state.field!` chains: state fields are non-nullable with `@Default`; nullable only when absence is meaningful.

## 3. Pattern catalogue (the author's recurring shapes, in their corrected form)

### P1. Section header (icon + title in a tinted rounded box)
The old code pasted the same `Container(decoration..., Row(icon, SizedBox, text))` for "Macronutrients" and "Micronutrients". Extract once:

```dart
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.iconAsset, required this.title});
  final String iconAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AvpSurface(                         // tinted rounded container from avp_ui
      padding: AppSpacing.cardPadding,
      child: Row(
        spacing: AppSpacing.sm,
        children: [AvpIcon(iconAsset), AvpText(title)],
      ),
    );
  }
}
```

### P2. Many similar rows: data plus loop
Old: six `MidPointSliderProgressBar(...)` calls separated by `SizedBox(height: 20)`. New: describe rows as data (built in the Cubit state or a presentation mapper), render with one loop.

```dart
class SummaryItem extends Equatable {
  const SummaryItem({required this.title, required this.value, this.onTap});
  final String title;
  final String value;      // already formatted by the mapper / avp_ui formatter
  final VoidCallback? onTap;
  @override
  List<Object?> get props => [title, value];
}

class SummaryList extends StatelessWidget {
  const SummaryList({super.key, required this.items});
  final List<SummaryItem> items;

  @override
  Widget build(BuildContext context) => Column(
        spacing: AppSpacing.lg,
        children: [for (final item in items) SummaryRow(item: item)],
      );
}
```

### P3. Two near-identical blocks become one widget
Old: `getPreviousWeight()` and `getStartWeight()` differ only by label and the compared value. New: one `ComparisonRow(label, deltaText, isIncrease)` used twice. Whenever you copy a block and change two strings, stop and parameterise.

### P4. Expandable/detail card = header row + details column
Compose it from three pieces: `XxxCard` (the expandable shell, from `avp_ui` if it exists), `XxxCardHeader` (icon, title, value, action icons) and `XxxCardDetails` (date row, divider, comparison rows). Action icons (edit, delete) call callbacks passed down; the card does not call the Cubit itself. Conditional rows that share one condition go in one `if` group instead of repeating the same `if` per child:

```dart
children: [
  const DetailsDateRow(...),
  if (hasHistory) ...[
    const DashedDivider(),
    ComparisonRow(...),
    const DashedDivider(),
    ComparisonRow(...),
  ],
],
```

### P5. Same screen, several periods (week / month / year)
One screen owns the tab selector. Each period is its own view widget in its own file. They share building blocks (period picker, chart, summary card) instead of duplicating them. The tab change calls ONE Cubit method that sets the period and loads.

```dart
class ReportBody extends StatelessWidget {
  const ReportBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.lg,
      children: [
        const ReportTabs(),
        Expanded(
          child: BlocSelector<ReportCubit, ReportState, ReportPeriod>(
            selector: (s) => s.period,
            builder: (_, period) => switch (period) {
              ReportPeriod.week => const ReportWeeklyView(),
              ReportPeriod.month => const ReportMonthlyView(),
              ReportPeriod.year => const ReportYearlyView(),
            },
          ),
        ),
      ],
    );
  }
}
```

Two screens that differ only by a type/title/icon/endpoint (the author had nine near-identical nutrient screens) are ONE screen with a parameter, not nine copies.

### P6. Skeleton per section
Each section that loads has its own `XxxSkeleton` mirroring its layout, built with `avp_ui` shimmer/loader widgets and token colours. The body shows the skeleton while `status` is `initial` or `loading`. Keep the section's old data visible during a reload when possible.

### P7. Empty state with a call to action
`XxxEmpty`: illustration, short message, one CTA button. It gets only a callback (`onAction`). The screen decides what the callback does.

### P8. Overlays: function plus widget in one file

```dart
Future<void> showDetailsSheet(
  BuildContext context, {
  required DetailsViewData data,
  required VoidCallback onConfirm,
}) {
  return showAvpBottomSheet<void>(
    context: context,
    builder: (_) => DetailsSheet(data: data, onConfirm: onConfirm),
  );
}

class DetailsSheet extends StatelessWidget { /* title row, content, action buttons */ }
```

The sheet chrome (rounded top, safe area, keyboard inset, close icon) is in `avp_ui`, never rewritten per file. Legend/info lists inside sheets use a `LegendRow(color, label)` piece repeated by loop, not copy-pasted `Row`s. If the sheet submits, reuse the existing Cubit with `BlocProvider.value`, close from a `BlocListener`, and never leave a local `isLoading = true` that is not reset on failure.

### P9. App-bar actions
If an action depends on state (e.g. only visible after success), make it a tiny widget (`XxxAppBarAction`) with its own `BlocSelector`, instead of a `BlocBuilder` with a big closure inside the app-bar call.

### P10. Side effects
One `BlocListener` per concern, each with `listenWhen` on the status change (delete finished, edit finished, connectivity lost). Group them with `MultiBlocListener`. After a successful edit: close the sheet, then ask the Cubit to refresh. A builder never navigates or shows dialogs.

## 4. Writing style

- Always use the design-system wrappers for text, icons/images, buttons, ink/tap areas, rich text, cards, dividers and loaders. Never raw Material visual widgets in a feature.
- `const` constructors everywhere possible; `super.key`; required named parameters; fields `final`.
- One public widget per file, file name equals class name in snake_case.
- Vertical rhythm with `Column(spacing: ...)` / `Row(spacing: ...)` and token values, not chains of `SizedBox`. Screen side padding from a token.
- Lists: `ListView.separated` / `.builder` for long lists. `shrinkWrap` + `NeverScrollableScrollPhysics` inside a scroll view only for short fixed lists (about 10 items or fewer).
- Private `_Foo` classes in the same file only for tiny single-use pieces (about 30 lines or fewer).
- Ephemeral UI state (expanded, focus, controllers, picker value before confirm) may live in a `StatefulWidget`; dispose controllers. Anything async or submitted lives in the Cubit.
- Start loading in the route's Cubit creation or in `initState`, never inside `build`.

## 5. Architecture constraints for UI (always apply)

**Location.** `features/<category>/presentation/<service>/{cubit,screens,widgets}/`; shared inside the category in `presentation/shared/`; cross-category widgets belong in `packages/avp_ui` (needs senior approval and 2 reviewers; say so in the task summary). Never import another feature. Service folder names are snake_case English and match `domain/usecases/<service>.dart`.

**Cubit wiring.** The Cubit is provided at the route (`<feature>_routes.dart`) or at the `ShellRoute` for multi-step flows, registered `@injectable`. Screens and widgets never call `getIt`. `context.read` only in callbacks. `BlocSelector` / `buildWhen` is mandatory on form fields and on any widget with several independent state slices.

**State.** One freezed state per Cubit with the shared `RequestStatus { initial, loading, success, failure }`; read it with an exhaustive `switch`; no guard getters. A second independent operation gets a second `RequestStatus` field. Submit buttons are disabled while `loading`; the Cubit submit method uses `guarded`. Do not invent `FormStatus` or extra statuses without asking.

**Async views.** Use `AsyncStateBuilder` (loading, empty, error with retry, offline, content) wherever it fits instead of hand-written spinners and error screens.

**avp_ui and tokens.** Colours from semantic tokens (`AppColors.surface`, `textPrimary`, `border`); no `Colors.*`, hex colours or palette shades. Typography from `AppTypography`; a local `copyWith` may change colour only. Spacing, radius, sizes and shadows from tokens; no literal numbers. Missing widget: extract it into `avp_ui` from the real usage, do not build a Material one-off in the feature. Specialised fields (national ID, IBAN, card, account, mobile, amount, Jalali date, selects, pickers, upload) already normalise and mask input; never add `DigitNormalizer` by hand to them and never put validation inside a field. Display formatting only via `avp_ui` formatters.

**Localisation and RTL.** No user-visible string literals in widgets; use the project l10n accessor, never `S.current`. `avp_ui` widgets receive already-localised strings. Failure text comes from the central code-to-key mapping (`Failure` has no message). Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `BorderRadiusDirectional`; never `left`/`right`. Arrows and chevrons use `DirectionalIcon`. Card number and IBAN render LTR. Amounts and dates in Persian digits; card, IBAN, national ID, account number in Latin digits. Jalali dates exist only in presentation; entities carry Gregorian UTC. Do not override text `height` locally.

**Flows.** Each step is its own screen in the form-step shell; `PopScope` on every step (back = previous step, first step = exit confirmation); after a successful submission use `go`, not `push`; `resume` is handled by the Cubit.

**Lint.** Six custom_lint errors apply to UI: no cross-feature imports; no hardcoded colours/numbers; no raw Material widgets in features; no `dio` outside `data/`; `Equatable` on state models; no string literals in widgets.

## 6. Refactoring an existing big UI file safely

1. Read the entire file and its Cubit/state. Write the outline (§2 step 1).
2. Keep behaviour identical: same state reads, same callbacks, same navigation. Refactor first, fix bugs in a separate step and say which you found.
3. Extract bottom-up, one block at a time; after each extraction run `dart analyze`.
4. Replace helper methods that return widgets with classes; replace repeated blocks with one parameterised widget; replace whole-state parameters with values; add `BlocSelector` where a section reads one slice.
5. Move each class to its own file under `widgets/` with the correct name (§2.1); leave the screen as the thin shell.
6. Replace hardcoded colours, numbers, strings, `S.current` and raw Material widgets with tokens, l10n and `avp_ui` wrappers as you touch each block.
7. Final report: new file list, what was merged as duplicate, anything that needs an `avp_ui` addition, and any bug found.

## 7. Checklist before reporting done

- [ ] Screen is a thin shell; every nameable block is its own class in its own file with the right kind/name.
- [ ] No `Widget _build...()` / `getX()` helpers; no whole `State` passed to children; no untyped `Function` callbacks.
- [ ] No duplicated blocks or screens that differ only by parameters; repeated rows are data plus loop.
- [ ] Nothing extracted without a reason (no pointless one-line wrapper classes).
- [ ] `BlocSelector` / `buildWhen` where needed; side effects only in `BlocListener` with `listenWhen`; status handled by exhaustive `switch`.
- [ ] Skeleton, empty and failure/offline views exist for every async view.
- [ ] No `Colors.*`, hex colours, literal paddings/radii/sizes, string literals, `S.current`, raw Material widgets, `getIt`, or `dio` in presentation.
- [ ] Directional APIs, `DirectionalIcon`, digit and date display policy respected.
- [ ] New or changed `avp_ui` pieces are called out for 2-reviewer approval.

## 8. Old habits that were deliberately replaced

| Old code | Now |
|---|---|
| `bloc/` folder, `XxxLog` screen names | `cubit/` folder, `XxxScreen` / `XxxSection` / `XxxCard` |
| Cubit built inside the screen with `sl<...>()` use cases | Cubit from DI at the route; use cases injected via constructor |
| `AsyncRequestStatus.Submitting/Success/Error`, many nullable state fields | `RequestStatus`, non-null fields with `@Default` |
| `S.current`, `Colors.grey`, palette shades, literal sizes | l10n accessor, semantic and spacing tokens |
| Whole `state` passed to child widgets, no `buildWhen` | values and callbacks, `BlocSelector` |
| `if (Submitting) spinner; if (Success) ...; return SizedBox()` chains (one screen even forgot the `return`) | exhaustive `switch` or `AsyncStateBuilder` |
| `context.read<C>().load()` inside `build` | load from route creation, `initState` or the Cubit method |
| `setCurrentIndex()` plus a listener that triggers the load | one Cubit method does both |
| Hand-written sheet chrome in every file | `avp_ui` bottom-sheet helper |
| `Function onChange` | `ValueChanged<T>` / `VoidCallback` |