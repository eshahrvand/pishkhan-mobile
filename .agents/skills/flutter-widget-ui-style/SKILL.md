---
name: flutter-widget-ui-style
description: >-
  Enforces the project's Flutter UI and widget coding conventions.
  Use this skill whenever writing, editing, or reviewing any Flutter widget,
  screen, dialog, or UI component in the presentation layer. Covers widget
  extraction rules, constructor patterns, BlocBuilder usage, styling,
  spacing, dialog patterns, and file organization.
---

# Flutter Widget & UI Coding Style

This skill defines the **exact** coding conventions for all Flutter UI code in
this project. Every widget, screen, dialog, and UI component **must** follow
these rules.

> [!CAUTION]
> Violating these rules produces code that looks foreign to the team and creates
> unnecessary churn in reviews. Read every section before writing UI code.

---

## 1. Widget Extraction — The Single Most Important Rule

### 1.1 Extract by Responsibility

Prefer a **coherent Bloc-driven UI section** as the extraction boundary: move
its `BlocBuilder`, `BlocSelector`, or `BlocConsumer` together with the subtree
it controls into a named widget. The parent composes that widget with surrounding
layout. Keep callbacks explicit for screen-owned navigation and side effects.
Business logic stays in Cubits.

Other valid boundaries are reusable components, widgets with controllers or
lifecycle, scoped BlocProviders, and substantial forms, cards, or sheets. Reuse
package components before extracting app-owned wrappers.

A short Bloc expression does not automatically require another widget. A
countdown with independent updates is a useful boundary; a selector choosing
only a background color can remain inline.

### 1.2 Use 200 Lines as a Review Trigger

When a screen or UI section exceeds **about 200 lines**, look for a coherent
responsibility to extract into its own file under the service's `widgets/` folder.
Prefer an existing Bloc subscription boundary. This is a guide, not a hard
file-size limit: do not fragment a readable section to satisfy a line count.
Keep a StatefulWidget and its State class together.

### 1.3 Avoid Widget and File Proliferation

Keep one-use titles, icons, notices, spacers, small Rows/Columns, and trivial
wrappers inline. Do not create a widget for every branch of a widget tree.
Several small helpers supporting one reusable component can share its file;
do not create one file per helper.

Use separate files for substantial Bloc-driven sections, reusable components,
controller-owning forms, and substantial dialogs/sheets. Multiple related helper
classes may stay together. Separate a helper only when its reuse or independent
responsibility justifies it.

### 1.4 Preserve Subscription Boundaries

- Move the subscription and its controlled UI together when extracting.
- Keep buildWhen, listenWhen, and selector projections focused on the state
  the section actually reads.
- If the parent already selects the relevant state, pass it to the child;
  do not add another subscription for the same data.
- Independent sections may subscribe to different state slices. Preserve narrow
  subscriptions instead of wrapping the entire screen in one builder.
- Preserve controllers, focus, scrolling, callbacks, and loading/error behavior.

---

## 2. Keys — Never Create Keys Manually

### 2.1 The Rule

**Never** manually create `Key`, `ValueKey`, `GlobalKey`, or `UniqueKey` for
widgets unless there is a **specific, documented reason** (e.g., `AnimatedList`,
`Form` with `GlobalKey<FormState>`, preserving widget state across parent
rebuilds).

### 2.2 Constructor Pattern

Always use `super.key` in the constructor. Never assign a custom key:

```dart
// ✅ CORRECT
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  ...
}
```

```dart
// ❌ WRONG — never do this
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);  // old syntax
  ...
}

// ❌ WRONG — never create keys manually
MyWidget(key: ValueKey('my_widget_123'))  // unnecessary
MyWidget(key: UniqueKey())                // unnecessary
```

### 2.3 When Keys ARE Needed (Rare)

| Use Case | Key Type |
|---|---|
| `Form` that needs validation via `currentState` | `GlobalKey<FormState>` |
| `AnimatedList` / `SliverAnimatedList` | `GlobalKey<AnimatedListState>` |
| Reorderable lists | `ValueKey(item.id)` on list items |
| Forcing widget recreation on data change | `ValueKey(id)` on the parent |

If none of these apply, **do not add a key**.

---

## 3. Constructor Conventions

### 3.1 Always Use `super.key`

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});           // ✅ StatelessWidget
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});           // ✅ StatefulWidget
}
```

### 3.2 `const` Constructors When Possible

If a widget takes no mutable fields and all parameters have defaults or are
primitives/immutable, make the constructor `const`:

```dart
const DashboardPage({super.key});        // ✅ no mutable fields
const DataEntryCards({super.key});        // ✅
```

If the widget has a mutable field (e.g., `ScrollController`, list built in
constructor body), omit `const`:

```dart
MainPage({super.key});                   // ✅ has mutable homeItems list
RecipesInfo({super.key, this.state, this.category});  // ✅ has mutable items list
```

### 3.3 Required vs Optional Parameters

- Use `required` for parameters that **must** always be provided.
- Use nullable types with no default for truly optional parameters.
- Use `@Default` annotations only in freezed state classes, not in widget
  constructors.

```dart
// ✅ CORRECT
const HeaderImage({
  super.key,
  required this.state,
});

// ✅ CORRECT — optional
const SelectOrderCard({super.key, this.blocks});
```

---

## 4. BlocBuilder / BlocListener / BlocConsumer

### 4.1 Choose the Right Widget

| Need | Widget |
|---|---|
| Rebuild UI on state change | `BlocBuilder` |
| Side effect only (navigation, dialog, snackbar) — no rebuild | `BlocListener` |
| Both rebuild AND side effect | `BlocConsumer` |
| Multiple independent listeners on the same Cubit | `MultiBlocListener` |

### 4.2 Always Use `listenWhen` / `buildWhen`

For `BlocListener` and `BlocConsumer`, **always** specify `listenWhen` to avoid
unnecessary listener calls:

```dart
// ✅ CORRECT
BlocListener<HomeCubit, HomeState>(
  listenWhen: (s1, s2) => s1.requestWeightGoalStatus != s2.requestWeightGoalStatus,
  listener: (context, state) { ... },
)
```

For form screens with many fields, use `buildWhen` or `BlocSelector` to prevent
full-screen rebuilds:

```dart
// ✅ CORRECT — rebuild only when status changes
BlocBuilder<HomeCubit, HomeState>(
  buildWhen: (s1, s2) => s1.requestDashboardStatus != s2.requestDashboardStatus,
  builder: (context, state) { ... },
)
```

### 4.3 Wrap Only the Minimum Subtree

When extracting a substantial Bloc-driven section, move its builder/selector
and subtree together into the section widget; see Section 1.

Place `BlocBuilder` around the **smallest widget subtree** that actually needs
the state, not the entire screen:

```dart
// ✅ CORRECT — only the FAB needs this state
floatingActionButton: BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    return FloatingActionButton(
      onPressed: () { ... },
      child: const Icon(Icons.add),
    );
  },
),
```

### 4.4 Naming Convention for Builder Parameters

Use `(context, state)` for builders, `(builder, state)` is also acceptable
when an outer context is needed:

```dart
builder: (context, state) { ... }    // ✅ preferred
builder: (builder, state) { ... }    // ✅ acceptable
```

---

## 5. Spacing and Padding

### 5.1 Use `SizedBox` for Spacing Between Widgets

```dart
// ✅ CORRECT — consistent pattern across the project
Column(
  children: [
    const SizedBox(height: 16),
    const DashboardAppBar(),
    const SizedBox(height: 20),
    SelectOrderCard(blocks: state.pageBuilder!.blocks!),
    const SizedBox(height: 30),
  ],
)
```

### 5.2 Use `const SizedBox` Whenever Possible

Always add `const` to `SizedBox` with literal dimensions:

```dart
const SizedBox(height: 16)      // ✅
const SizedBox(width: 20)       // ✅
SizedBox(height: 16)            // ❌ missing const
```

### 5.3 Padding Around Sections, Not Individual Widgets

Apply `Padding` at the section/page level, not on every small widget:

```dart
// ✅ CORRECT — one Padding for the whole page
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: SingleChildScrollView(
    child: Column(children: [ ... ]),
  ),
)
```

### 5.4 Standard Spacing Values

Use these consistent spacing values from the project:

| Context | Value |
|---|---|
| Horizontal page padding | `16` |
| Between cards/sections vertically | `16` or `20` |
| Inside card padding | `20` (all sides) |
| Between icon and text | `10` |
| Small inline spacing | `6` or `8` |
| Between action buttons | `12` |

---

## 6. Styling Patterns

### 6.1 Use Theme TextStyles — Never Hardcode

Always reference `Theme.of(context).textTheme.*`:

```dart
// ✅ CORRECT
style: Theme.of(context).textTheme.titleMedium

// ✅ CORRECT — with modification
style: Theme.of(context).textTheme.labelSmall!.copyWith(
  color: grayPalette.shade600,
)

// ❌ WRONG — hardcoded style
style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
```

### 6.2 Use Semantic Color Tokens

Use the project's palette system, never raw `Colors.*` values (except
`Colors.white` and `Colors.transparent`):

```dart
// ✅ CORRECT
color: mainPalette.shade500
color: grayPalette.shade600
color: errorPalette.shade400
color: secondaryPalette.shade400
color: Colors.white            // ✅ exception allowed

// ❌ WRONG
color: Color(0xFF4CAF50)
color: Colors.green
color: Colors.grey[600]
```

### 6.3 Decoration Pattern for Cards

```dart
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
)
```

Use the project's `cardBoxDecoration()` helper when available.

---

## 7. State Loading Pattern

### 7.1 Three-State Pattern

Every screen that loads data follows the same pattern:

```dart
BlocBuilder<MyCubit, MyState>(
  builder: (context, state) {
    // 1. Loading
    if (state.requestStatus == AsyncRequestStatus.Submitting) {
      return const Center(child: CircularProgressIndicator());
      // or return a Shimmer widget
    }

    // 2. Success
    if (state.requestStatus == AsyncRequestStatus.Success && state.data != null) {
      return Column(children: [ /* actual content */ ]);
    }

    // 3. Empty/Error fallback
    return const SizedBox();
  },
)
```

### 7.2 Shimmer for Initial Loading

Use dedicated shimmer widgets for complex pages:

```dart
if (state.requestStatus == AsyncRequestStatus.Submitting) {
  return SizedBox(
    height: getSizeDevice(context)[0],
    child: const Center(
      child: DashboardShimmer(),
    ),
  );
}
```

### 7.3 Inline Loading for Actions

For inline actions (e.g., add water), show a small loading indicator in place
of the action button:

```dart
child: state.requestDrinkingStatus == AsyncRequestStatus.Submitting
    ? const SizedBox(
        height: 33,
        width: 33,
        child: CircularProgressIndicator(),
      )
    : const CaltivitaImage(image: "assets/icons/add_water.svg"),
```

---

## 8. Dialog and Bottom Sheet Patterns

### 8.1 Top-Level Function + Widget Class

Dialogs and bottom sheets follow a two-part pattern:

1. A **top-level function** that calls `showModalBottomSheet` or `showGeneralDialog`
2. A **widget class** that contains the UI

```dart
// ✅ CORRECT — top-level function
void changeUnitFoodDialog({
  required BuildContext context,
  required List<PortionRecord> portionRecord,
  required PortionRecord selectPortion,
  required int amountFood,
  required Function onSubmit,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext bc) {
      return ChangeUnitFood(
        portionRecord: portionRecord,
        selectPortion: selectPortion,
        amountFood: amountFood,
        onSubmit: onSubmit,
      );
    },
  );
}

// ✅ Widget class handles the UI
class ChangeUnitFood extends StatefulWidget { ... }
```

### 8.2 Bottom Sheet Decoration

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
    color: grayPalette.shade50,
  ),
  padding: const EdgeInsets.all(20),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [ ... ],
  ),
)
```

### 8.3 Keyboard-Aware Bottom Sheet

Always handle keyboard insets in bottom sheets with text fields:

```dart
AnimatedPadding(
  duration: const Duration(milliseconds: 150),
  curve: Curves.easeOut,
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom,
  ),
  child: Container( ... ),
)
```

---

## 9. Navigation Patterns

### 9.1 Use `context.push` / `context.pop` (go_router)

```dart
// ✅ CORRECT
context.push(dataEntryFood, extra: {"meal": meals[0]});
context.pop();
context.pushReplacement(selectLanguage);

// ❌ WRONG — raw Navigator (except in rare cases like SliverAppBar leading)
Navigator.of(context).push(...);
```

### 9.2 Refresh After Navigation Return

Use `.then()` to refresh data when a pushed route returns:

```dart
// ✅ CORRECT
context.push(dataEntryFood, extra: { ... }).then((value) {
  context.read<HomeCubit>().getHomeLogByType(HomeLogType.food);
});
```

---

## 10. ListView and Scrollable Patterns

### 10.1 ListView.separated for Lists with Dividers

```dart
ListView.separated(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemBuilder: (context, index) { ... },
  separatorBuilder: (context, index) {
    return const CaltivitaDashSeparator(height: 1);
  },
  itemCount: items.length,
)
```

### 10.2 `shrinkWrap` + `NeverScrollableScrollPhysics` for Nested Lists

When a `ListView` is inside a `Column` or `SingleChildScrollView`:

```dart
ListView.separated(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  ...
)
```

---

## 11. Widget Composition Patterns

### 11.1 Row with Icon + Text

```dart
Row(
  children: [
    const CaltivitaImage(
      image: "assets/icons/timer.svg",
      height: 20,
    ),
    const SizedBox(width: 10),
    CaltivitaText(
      text: S.current.preparationTime,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  ],
)
```

### 11.2 Row with Label + Value

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    CaltivitaText(
      text: S.current.currentWeight_dashboard,
      style: Theme.of(context).textTheme.labelSmall!.copyWith(
        color: grayPalette.shade600,
      ),
    ),
    CaltivitaRichText(
      span: TextSpan(
        text: value.toString(),
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          spacerForTextSpan,
          TextSpan(
            text: S.current.kgUnit,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: grayPalette.shade600,
            ),
          ),
        ],
      ),
    ),
  ],
)
```

### 11.3 Action Buttons Row (Cancel + Submit)

```dart
Row(
  children: [
    Expanded(
      child: CaltivitaOutlineButton(
        btnTitle: S.current.cancel,
        height: 44,
        onPressed: () => context.pop(),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: CaltivitaButton(
        btnTitle: S.current.record,
        height: 44,
        onPressed: () { ... },
      ),
    ),
  ],
)
```

---

## 12. File Organization

### 12.1 Import Order

1. Dart SDK imports (`dart:math`, `dart:io`)
2. Package imports (`package:flutter/...`, `package:flutter_bloc/...`)
3. Project absolute imports (`package:caltivita/...`)
4. Relative imports (`'./...'`, `'../...'`)

### 12.2 Folder Structure (Presentation Layer)

```
features/
  └── cards/
      └── presentation/
          ├── block_card/              # one service
          │   ├── cubit/
          │   │   ├── block_card_cubit.dart
          │   │   └── block_card_state.dart
          │   ├── screens/
          │   │   └── block_card_screen.dart
          │   └── widgets/             # widgets used ONLY by this service
          │       └── block_reason_selector.dart
          │
          └── shared/                  # widgets shared across ≥ 2 services in this feature
              └── widgets/
                  └── card_tile.dart
```

### 12.3 Widget File Naming

- Screens: `<service_name>_screen.dart`
- Feature-local widgets: descriptive name, no prefix (`card_tile.dart`)
- Dialog functions: `<name>_dialog.dart`
- Shimmer: `<name>_shimmer.dart`

---

## 13. Anti-Patterns — What NOT to Do

### 13.1 Do NOT Over-Extract

```dart
// ❌ NEVER extract a 5-line Padding+Text into its own widget
// ❌ NEVER extract a single SizedBox spacer into a widget
// ❌ NEVER create a widget just to wrap one CaltivitaImage
```

### 13.2 Do NOT Create Manual Keys

```dart
// ❌ NEVER
Widget build(BuildContext context) {
  return Column(
    key: const ValueKey('main_column'),  // ← REMOVE
    children: [
      MyWidget(key: ValueKey('item_$index')),  // ← REMOVE unless in AnimatedList
    ],
  );
}
```

### 13.3 Do NOT Use Hardcoded Colors

```dart
// ❌ NEVER
color: Color(0xFF4CAF50)
color: Colors.green
color: Colors.grey.shade600

// ✅ ALWAYS
color: mainPalette.shade500
color: grayPalette.shade600
```

### 13.4 Do NOT Use `_build` Methods as Widget Extractors

If you need to split UI logic, create a **widget class**, not a private method
that returns a widget tree. Methods that return `Widget` do not participate in
Flutter's element tree efficiently:

```dart
// ❌ AVOID — _build methods for large widget trees
Widget _buildHeader() { ... }
Widget _buildBody() { ... }
Widget _buildFooter() { ... }

// ✅ PREFER — separate widget classes in the same file
class HeaderSection extends StatelessWidget { ... }
class BodySection extends StatelessWidget { ... }
```

Exception: small helper methods (< 10 lines) that compute a value or return a
simple widget (e.g., `getHealthColor()`, `getHintWaterTextMessage()`) are fine.

### 13.5 Do NOT Nest BlocBuilder Unnecessarily

If two pieces of data come from the same Cubit, use **one** `BlocBuilder`
instead of nesting two:

```dart
// ❌ WRONG — two nested BlocBuilders on the same Cubit
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state2) { ... },
    );
  },
)

// ✅ CORRECT — one builder, access both fields
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    // use state.fieldA and state.fieldB
  },
)
```

---

## 14. Project-Specific Widget Library (`avp_ui`)

When building UI for the `pishkhan_mobile` project, use the `avp_ui` package
widgets instead of raw Material widgets:

- `CaltivitaText` / `CaltivitaRichText` → instead of `Text` / `RichText`
- `CaltivitaImage` → instead of `Image.asset` / `SvgPicture`
- `CaltivitaButton` / `CaltivitaOutlineButton` → instead of `ElevatedButton`
- `CaltivitaTextField` → instead of `TextField`
- `CaltivitaInkWell` → instead of `InkWell` / `GestureDetector`
- `CaltivitaDashSeparator` → instead of `Divider`
- `CaltivitaSnackBar` → instead of `ScaffoldMessenger.showSnackBar`

> [!IMPORTANT]
> Raw Material widgets are prohibited in `app/lib/features/` by `custom_lint`
> Rule 3 (Section 17.4 of the architecture document). Only `avp_ui` widgets
> are allowed.

---

## 15. Shimmer — Mirror the Real Layout

### 15.1 Shimmer Must Match the Screen Structure

Shimmer files do **not** show generic placeholders. They **recreate the exact
visual wireframe** of the destination screen:

```dart
// dashboard_shimmer.dart — mirrors the real dashboard layout
Widget _shimmerLine({required double width, required double height}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: width,
      height: height,
      color: Colors.white,
    ),
  );
}

Widget _shimmerCircle(double size) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: size, height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
    ),
  );
}
```

### 15.2 RTL Shimmer Direction

For Persian/RTL layouts, specify `ShimmerDirection.rtl`:

```dart
Shimmer.fromColors(
  baseColor: Colors.grey.shade300,
  highlightColor: Colors.grey.shade100,
  direction: ShimmerDirection.rtl,  // ✅ required for RTL
  child: ...
)
```

### 15.3 Use Shimmer Helper Methods in the Same File

Small shimmer primitives (`_shimmerLine`, `_shimmerCircle`,
`_shimmerRoundedBox`) are fine as private methods — this is the one exception
to the "no `_build` methods" rule because they are tiny utilities, not widget
trees.

---

## 16. Helper Methods — When They ARE Allowed

### 16.1 Acceptable Private Methods

Small methods (< 10 lines) that **compute a value** or **return a tiny
parameterized piece** are fine:

```dart
// ✅ OK — returns a data value, not a big widget tree
Color getHealthColor(String? animation) { ... }
String getHintWaterTextMessage(int index) { ... }

// ✅ OK — tiny repeating template with many parameters (used in same file)
Widget _mealLogItem({
  required BuildContext context,
  required String image,
  required String meal,
  required String amount,
  required String unit,
}) {
  return Row(children: [
    CaltivitaImage(image: image, width: 24, height: 24),
    const SizedBox(width: 10),
    CaltivitaText(text: meal, style: ...),
    const Spacer(),
    CaltivitaText(text: "$amount $unit", style: ...),
  ]);
}

// ✅ OK — returns a data list, not a widget
List<NutritionalModel> _nutritionalList(BuildContext context, Food food, ...) { ... }
```

### 16.2 Not Acceptable

```dart
// ❌ WRONG — this is a large widget tree, make it a class
Widget _buildGoalCard(BuildContext context, HomeState state) {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      children: [
        // ... 50+ lines of nested widgets
      ],
    ),
  );
}
```

---

## 17. Pagination Pattern

Use `NotificationListener<ScrollEndNotification>` instead of manually attaching
scroll listeners:

```dart
NotificationListener<ScrollEndNotification>(
  onNotification: (scrollEnd) {
    final metrics = scrollEnd.metrics;
    if (metrics.atEdge) {
      bool isTop = metrics.pixels == 0;
      if (!isTop) {
        if ((state!.isNextPageRecipe ?? false) &&
            !(state!.isLoadMoreRecipe ?? false)) {
          var nextPage = state!.recipePage! + 1;
          context.read<HomeCubit>().getRecipes(
            category: category,
            page: nextPage,
            index: state!.recipeCurrentIndex ?? 0,
          );
        }
      }
    }
    return true;
  },
  child: GridView.builder(...),
)
```

---

## 18. Localization — Always Use `S.current`

**Never** hardcode any user-visible string in Persian or English:

```dart
// ✅ CORRECT
title: S.current.water_dashboard,
unit: S.current.glass_dashboard,
btnTitle: S.current.addFood,

// ❌ WRONG
title: "آب",
title: "Water",
```

---

## 19. Analytics and Screen Tracking

Use the project's event tracking at the top of screen `build` methods:

```dart
@override
Widget build(BuildContext context) {
  eventScreen(ScreenName.dashboard.name, ScreenName.home.name);
  return ...;
}
```

For user actions:

```dart
addEvent(Event.click_side_bar.name);
addEventSelectContent(
  contentType: "recipe",
  itemId: id,
  category: title,
);
```

---

## 20. Platform-Specific Behavior

Use `kIsWeb` from `package:flutter/foundation.dart` for platform checks:

```dart
padding: const EdgeInsets.only(bottom: kIsWeb ? 5.0 : 0),
height: kIsWeb ? 360 : 300,
repeat: !kIsWeb,
```

---

## 21. State Passing to Child Widgets

When a child widget needs Cubit state, **pass the state object directly** rather
than wrapping the child in another `BlocBuilder`:

```dart
// ✅ CORRECT — parent already has the state, pass it down
RecipeList(state: state, scrollController: listController)
EmptyWeightGoal(state: state)
IngredientsList(state: state)
HeaderImage(state: state)

// ❌ WRONG — unnecessary nested BlocBuilder
class IngredientsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeDetailCubit, RecipeDetailState>(  // ← WRONG
      builder: (context, state) { ... },
    );
  }
}
```

---

## 22. Checklist Before Submitting UI Code

Before marking any UI task as complete, verify:

- [ ] Extractions have a Bloc, reuse, lifecycle, or substantial business boundary
- [ ] No tiny one-use wrappers or one file per layout fragment
- [ ] Reviewed sections over about 200 lines without forcing arbitrary splits
- [ ] No manual `Key` / `ValueKey` / `UniqueKey` (unless justified)
- [ ] All constructors use `super.key`
- [ ] `const` on every constructor and widget that qualifies
- [ ] `listenWhen` on every `BlocListener` / `BlocConsumer`
- [ ] `const SizedBox` for all literal spacing
- [ ] All text styles from `Theme.of(context).textTheme.*`
- [ ] All colors from semantic palette tokens (not raw `Colors.*`)
- [ ] No `_buildXxx()` methods returning large widget trees
- [ ] Loading state handled (shimmer mirroring actual layout, not generic)
- [ ] Shimmer uses `ShimmerDirection.rtl` for RTL layouts
- [ ] Dialogs use the top-level function + widget class pattern
- [ ] Navigation uses `context.push` / `context.pop`
- [ ] Refresh data in `.then()` after navigation return
- [ ] All user-visible strings use `S.current.*` (no hardcoded text)
- [ ] Screen tracking with `eventScreen(...)` at top of `build`
- [ ] State passed as parameter to children, not via nested `BlocBuilder`
