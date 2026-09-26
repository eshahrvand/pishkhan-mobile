# AVP UI-first implementation policy

## Purpose

`avp_ui` is the source of truth for Pishkhan's shared design system. Before adding or changing any UI, developers and agents must first determine whether the required token, asset, or component is already exported by `package:avp_ui/avp_ui.dart`.

This policy supplements [main-app-integration-guide.md](main-app-integration-guide.md). When the documents differ, the integration guide and the package's public API take priority.

## Required decision gate

Complete these steps **before writing UI code**:

1. Read `doc/main-app-integration-guide.md` and inspect the public exports of `avp_ui`.
2. Look for a matching `App...` component in the Figma-to-Flutter mapping and package API.
3. If it exists, use that component from `package:avp_ui/avp_ui.dart`.
4. Pass feature-specific data, callbacks, validation, and state through the component's public properties.
5. If it does not exist, add the shared component or missing variant to `avp_ui` first, with package widget tests and an integration-guide update. Do not create a main-app-only design-system duplicate.
6. Only then compose the component into the screen or feature.

## Rules

- The entire application is **RTL-first**. Persian is RTL, and every language added in the future must also be treated as RTL.
- Build every screen, component, navigation flow, form, modal, tooltip, and state from an RTL layout by default. Do not create LTR-first layouts and mirror them later.
- Use `Directionality(textDirection: TextDirection.rtl)` at the app root and preserve it through routes, overlays, dialogs, bottom sheets, menus, and nested widgets.
- Use RTL-aware layout and text behavior: `EdgeInsetsDirectional`, `BorderDirectional`, `AlignmentDirectional`, `TextAlign.start`/`TextAlign.end`, and RTL text direction for user-facing copy. Use physical `left`/`right` alignment only when the Figma design explicitly requires a fixed physical side, such as the drawer opening from the right.
- Validate every component in RTL, including open/closed, selected/unselected, loading, error, disabled, and long-text states.
- Import only `package:avp_ui/avp_ui.dart`; do not import the package's internal `lib/widgets/...` files.
- Install `AppTheme.light()` at the application root.
- In app-owned composition, use semantic tokens such as `context.colors.primary`, `context.colors.textPrimary`, and `context.colors.borderSubtle`. Do not write hex values or `Color(0x...)` values in app UI.
- Do not use raw `TextField`, `TextFormField`, `Checkbox`, `Switch`, `Slider`, `ElevatedButton`, or equivalent Material controls when `avp_ui` exports an equivalent component.
- The main app owns screen composition, navigation, feature state, API calls, domain data, and validation rules.
- `avp_ui` owns shared visual states, Figma-owned assets, tokens, interaction primitives, and their tests.
- Do not copy package-owned SVG/PNG assets into the main app. Use the package component that owns the asset. Domain-specific Figma assets belong in the main app only when no `avp_ui` component owns that visual.

## Current component lookup

| Need | Use from `avp_ui` |
| --- | --- |
| Colors, spacing, typography, radius, shadows | `context.colors`, `AppSpacing`, `AppTypography`, `AppRadius`, `AppShadows` |
| Standard input | `AppTextField` |
| Search input | `AppSearchField` |
| Multiline input | `AppTextArea` |
| Select/dropdown | `AppSelect<T>` and `AppSelectOption<T>` |
| Button | `AppButton` |
| Toggle | `AppToggle` |
| Checkbox | `AppCheckbox` |
| Badge, tooltip, help | `AppBadge`, `AppTooltip`, `AppHelp` |
| Avatar | `AppAvatar`, `AppAvatarProfilePhoto` |
| Progress and slider | `AppProgressIndicator`, `AppProgressCircle`, `AppSlider` |

The complete supported-component inventory is maintained in `main-app-integration-guide.md` and must be consulted instead of assuming a widget is unavailable.

## Pull-request checklist

- [ ] Read the integration guide and checked the public `avp_ui` exports.
- [ ] Reused the matching `App...` component or documented why no component exists.
- [ ] Used semantic `avp_ui` tokens; no hard-coded app color values were introduced.
- [ ] Implemented and tested the UI as RTL-first, including all interactive states.
- [ ] Kept Figma-owned assets in `avp_ui` when a component owns them.
- [ ] Added or updated focused widget tests for stateful behavior.
- [ ] Ran `flutter test` and `flutter analyze`.
