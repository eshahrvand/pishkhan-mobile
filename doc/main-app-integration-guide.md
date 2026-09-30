# `avp_ui` integration guide for main-app agents

## Purpose

`avp_ui` is the shared Flutter design-system package for Pishkhan AI / Smart Virtual Counter. It contains reusable design tokens, formatters, input helpers, and Figma-aligned widgets.

When developing the main application, **reuse the components in this package before creating a new widget**. This prevents design drift and keeps the Flutter app aligned with the Figma library.

## First-use setup

Add the package to the consuming application's `pubspec.yaml`. Use the source appropriate for the workspace; for a local monorepo this is typically:

```yaml
dependencies:
  avp_ui:
    path: ../avp_ui
```

Import the single public entrypoint:

```dart
import 'package:avp_ui/avp_ui.dart';
```

Install the package theme near the root of the app:

```dart
MaterialApp(
theme: AppTheme.light(),
home: const MyScreen(),
)
```

Do not import files from `lib/widgets/...` directly in the main app. The public import above is the supported API.

## Agent decision rule

Before implementing a UI element, follow this order:

1. Read the Figma-to-Flutter mapping below.
2. If the Figma component is marked **Implemented**, use its `App...` widget.
3. Pass state and content through the component's public parameters; do not copy its layout, colors, or SVG assets into the app.
4. If a required Figma variant is missing, extend `avp_ui` with the same Figma component name and add widget tests. Do not create a main-app-only duplicate.

## Figma-to-Flutter mapping

Unless a row explicitly says **Not implemented**, the component is implemented and exported from `package:avp_ui/avp_ui.dart`.

| Figma component | Figma node | Flutter component | Notes |
| --- | --- | --- | --- |
| Button | `15699:34979` | `AppButton` | Variants, sizes, destructive, loading, icons, tooltip, disabled state. |
| Badge | `15743:28288` | `AppBadge` | Background, color, size, corner, icon/dot/avatar options. |
| Input field | `15652:17725` | `AppTextField` | Label, hint, helper/error text, icons, add-ons, digit normalization, direction, multiline support. |
| Search field | `15807:44137` | `AppSearchField` | Search icon and optional clear action. |
| Text area input field | `13759:45191` | `AppTextArea` | Multiline text field with field-state styling. |
| Dropdown / select field | `13846:6903` | `AppSelect<T>` | Opens the package option sheet. Use `AppSelectOption<T>`. |
| Select dropdown menu | `13819:12912` | `AppSelectMenu<T>` | Use only when a custom menu container is needed; `AppSelect` covers normal app usage. |
| Toggle | `13759:55154` | `AppToggle` | `sm`/`md`, optional label and supporting text. |
| Checkboxes | `15722:13478` | `AppCheckbox` | Square checkbox primitive, `sm`/`md`/`lg`, checked/unchecked/indeterminate. |
| Check circles / radio visuals | `15722:13564` | Not implemented | This node was inspected as part of checkbox work, but the radio component has not been added. |
| Checkbox with text | `25645:26821` | `AppCheckbox` | Provide `label` and `supportingText`; set `value: null` for indeterminate. |
| Tooltip | `1052:489` | `AppTooltip` | Light/dark, message, optional title, and pointer directions. |
| Help icon | `1054:13` | `AppHelp` | 16px tap-to-toggle help icon with dark tooltip positions. |
| Linear progress bar | `15992:142102` | `AppProgressIndicator` | `value` is normalized from `0.0` to `1.0`; labels can be right, bottom, or floating. |
| Progress circle | `1154:89981` | `AppProgressCircle` | 64px/160px circle or half-circle; `value` is normalized. |
| Slider | `1086:534` | `AppSlider` | Dual-thumb range slider based on `RangeValues`; optional label positions and extra bars. |
| Avatar | `19:1012` | `AppAvatar` | Standard 24–64px avatar with photo, initials, placeholder, focus, online/company badge. |
| Avatar profile photo | `1217:108477` | `AppAvatarProfilePhoto` | Large 96px/160px avatar profile-photo component. |

## Typography

`AppTheme.light()` installs the package-owned `IRANYekanX` family and the
complete `AppTypography.textTheme`. The consuming app must not register,
bundle, or set this font family again.

For normal screen copy, use the themed semantic role:

```dart
Text(
  'اطلاعات حساب',
  style: Theme.of(context).textTheme.titleMedium,
)
```

For a Figma-specific variation, derive it from an `AppTypography` semantic
role. Do not create a new `TextStyle` or set `fontFamily` in a screen or
component.

```dart
Text(
  'ادامه',
  style: AppTypography.titleMedium.copyWith(
    color: context.colors.textPrimary,
    letterSpacing: 0,
  ),
)
```

Use the role that describes the content, not a size-based name:

| Content | Start with |
| --- | --- |
| Large page hero | `displayLarge`, `displayMedium`, `displaySmall` |
| Page or section heading | `headlineLarge`, `headlineMedium`, `headlineSmall` |
| Section title or prominent action | `titleLarge`, `titleMedium`, `titleSmall` |
| Paragraph, field value, or supporting copy | `bodyLarge`, `bodyMedium`, `bodySmall` |
| Field label, compact control, or metadata | `labelLarge`, `labelMedium`, `labelSmall` |

`copyWith(...)` is for contextual properties—such as color, a Figma-required
line-height, weight, or letter spacing. It retains the package font family and
RTL-safe typography settings. Shared `avp_ui` components already apply these
roles internally; application code only needs them for custom composition.

## Common usage patterns

### Inputs and selections

```dart
AppTextField(
  label: 'شماره همراه',
  hintText: '۰۹۱۲۱۲۳۴۵۶۷',
  keyboardType: TextInputType.phone,
  normalizeDigits: true,
  onChanged: (value) => state.phone = value,
)

AppSelect<String>(
  label: 'نوع درخواست',
  value: state.requestType,
  options: const [
    AppSelectOption(value: 'card', label: 'کارت بانکی'),
    AppSelectOption(value: 'iban', label: 'شماره شبا'),
  ],
  onChanged: (value) => setState(() => state.requestType = value),
)
```

`AppTextField` also accepts `textStyle` for a Figma typography variation and
`onSubmitted` for keyboard actions. `AppSearchField` accepts `textStyle` and
`searchIcon` when the design supplies an exact icon asset. Derive text overrides
from `AppTypography`; the field retains its package font when an override omits
the font family. Existing callers keep their current defaults.

### Boolean controls

```dart
AppCheckbox(
  value: state.rememberMe,
  label: 'مرا به خاطر بسپار',
  supportingText: 'اطلاعات ورود من را در این دستگاه ذخیره کن',
  onChanged: (value) => setState(() => state.rememberMe = value),
)

AppToggle(
  value: state.notificationsEnabled,
  label: 'اعلان‌ها',
  size: AppToggleSize.md,
  onChanged: (value) => setState(() => state.notificationsEnabled = value),
)
```

`AppCheckbox.value` is nullable: use `null` for the Figma indeterminate state. An indeterminate checkbox reports `true` when tapped.

### Progress and range values

```dart
AppProgressIndicator(
  value: .65,
  labelPosition: AppProgressLabelPosition.topFloating,
)

AppSlider(
  values: state.priceRange,
  labelPosition: AppSliderLabelPosition.bottom,
  onChanged: (values) => setState(() => state.priceRange = values),
)
```

`AppProgressIndicator`, `AppProgressCircle`, and `AppSlider` use normalized values: `0.0` means 0% and `1.0` means 100%.

### Tooltips and avatars

```dart
AppHelp(
  title: 'راهنمای استفاده',
  message: 'برای ادامه، اطلاعات خواسته‌شده را وارد کنید.',
)

AppAvatar(
  image: NetworkImage(user.avatarUrl),
  size: AppAvatarSize.md,
  status: AppAvatarStatus.online,
)

AppAvatarProfilePhoto(
  initials: 'OR',
  size: AppAvatarProfilePhotoSize.lg,
)
```

For remote images, the main app owns loading, caching, failure, and authentication behavior. Pass a suitable `ImageProvider` to the avatar; do not replace the package's Figma-owned placeholder or badge assets.

## Tokens and RTL

- Use `AppTheme.light()` to install the package theme.
- Use `Theme.of(context).textTheme` for normal screen typography and derive
  Figma-specific variations from `AppTypography` with `.copyWith(...)`.
- Prefer semantic theme colors in app-specific composition: `context.colors.primary`, `context.colors.textPrimary`, and related values from `AppThemeContextX`.
- `AppPalette` is available for package-level design-system work, but app screens should prefer `context.colors`.
- Use `DirectionalIcon` and `AlignmentDirectional` when an icon or placement must mirror in RTL.
- Components accept normal Persian or English text. Preserve the screen's `Directionality`; only use a field-level `textDirection` when the data type requires it (for example, a card or IBAN number).

## Package assets and boundaries

The package owns the SVG/PNG assets required by Figma components under `assets/icons/` and `assets/images/`, plus the registered `IRANYekanX` font files under `assets/fonts/`. Consumers must not hard-code these paths or create copies in the main app.

The main app owns:

- Screen composition, routing, feature state, APIs, and validation rules.
- Domain-specific copy and callback behavior.
- Remote image loading policies and data models.

`avp_ui` owns:

- Shared tokens, typography and font registration, component visuals, interaction primitives, Figma assets, and component tests.

## Verification when changing `avp_ui`

After changing or adding a component, run:

```bash
flutter analyze
flutter test
```

Add or update a focused widget test in `test/widgets/`. Keep the mapping table in this document updated whenever a new Figma component is implemented or an existing mapping changes.

`AppButton.horizontalPadding` optionally adjusts horizontal inset for compact
text actions, such as the notification header. Omit it to keep the size defaults.
