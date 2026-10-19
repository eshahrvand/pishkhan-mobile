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
| Stepper | `27984:8986` | `AppStepper` | Controlled step count, title, next/end text; see issuance notes below. |
| Chips (default / selected) | `27902:85120`, `27902:85127` | `AppChips` | 40px category chips; optional icon and labelStyle for reviewed frame instances. |
| Button | `15699:34979` | `AppButton` | Variants, sizes, destructive, loading, icons, tooltip, disabled state. |
| Badge | `15743:28288` | `AppBadge` | Background, color, size, corner, icon/dot/avatar options. |
| Input field | `15652:17725` | `AppTextField` | Label, hint, helper/error text, icons, add-ons, digit normalization, direction, multiline support. |
| Search field | `15807:44137` | `AppSearchField` | Search icon and optional clear action. |
| Text area input field | `13759:45191` | `AppTextArea` | Multiline text field with field-state styling. |
| Dropdown / select field | `13846:6903` | `AppSelect<T>` | Opens an input-width anchored menu with a 6px gap. Use `AppSelectOption<T>`. |
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

## Updated login support

Use the public AppLoginColors semantic tokens for login canvas, ownership notice,
service labels, and section labels. AppTextField accepts textAlign (default:
TextAlign.start). Login, CAPTCHA, and OTP explicitly use TextDirection.rtl and
TextAlign.start for both placeholders and entered text.

## Dashboard instance styling

The shared package exports AppDashboardColors for dashboard-specific semantic styling. AppButton.foregroundColor supports text-action instance colors while preserving disabled styling. AppSearchField.clearIcon supplies the exact Figma clear icon while preserving automatic clearing and callbacks. See [Dashboard development](dashboard/development.md) for the page composition and shared micro-service instance sizing.

## Loan progress alignment

AppProgressIndicator.fillAlignment optionally selects the origin. Default: AlignmentDirectional.centerStart. AppLoanCard passes Alignment.centerLeft for the loan frames in RTL. The foreground now keeps the full 8px track height. Calculate installment progress from validated numeric paid/total counts, with zero-total handling.

## Dashboard tab repository composition

Import package:pishkhan_mobile/features/dashboard/dashboard.dart for DashboardScreen and its public data/action contracts. DashboardScreen.repositories accepts DashboardRepositories with Home/Cards/Deposits/Loans implementations. Leaving it unset builds mocks from the optional list/favorite seed arguments. Tab widgets and their Cubits receive typed repository interfaces rather than raw lists. Standalone feature folders no longer export dashboard tab screens. See the [Dashboard architecture and Figma audit](dashboard/development.md) for exact paths, states and live-service adapter requirements.

## Standalone Cards feature

Routing uses two central files for every feature: `core/router/app_routes.dart`
contains the single `AppRoutes` class and URL builders; `core/router/app_router.dart`
contains all `GoRoute` definitions directly in `createAppRouter`, plus typed route
arguments. Add routes there; per-feature `*_routes.dart` files and `build*Routes`
factories are no longer used. The app owns and disposes its router/session.

Card password setup, change and recovery are owned by `features/cards`, including
their presentation, domain and mock data layers. Use `AppRoutes.cardPasswords`
(`/cards/password-services`) from `core/router/app_routes.dart` and
`PasswordRouteArguments` from `core/router/app_router.dart`.
`ServiceRegistry.openCardService` forwards the existing password service IDs to
this route. Login and login OTP remain in `features/auth`. See
[Password services](cards/password-services.md) for paths and flow contracts.

See [Cards architecture](cards/card-services.md). Import features/cards/cards.dart for CardListScreen, CardsRepository, ListedCard and typed CardFeatureRequest. Dashboard card summaries remain a separate feature. Compatible new package APIs are documented in avp_ui/docs/main-app-integration-guide.md; deploy the sibling package changes together with this app.

## Stepper and card issuance instances

| Figma name | Node | Public widget | Source |
| --- | --- | --- | --- |
| Stepper / stepper | `27984:8986` | `AppStepper` | `lib/widgets/layout/app_stepper.dart` |

Use `AppStepper(currentStep: 1, totalSteps: 3, title: title, supportingText: nextLabel)`. Step numbers are one-based; total must be positive. State, navigation, validation, localized title/next/end labels and accessibility copy belong to the app. The 42px ring stays on the physical left in RTL, with a 24px gap, 4px warning dot, 12px/18px DemiBold title and 10px/16px Light supporting copy. The original 42px Figma ring SVGs live in package assets; dynamic progress clips the full foreground ring. Default progress is current/total. `progress` optionally reproduces authored samples: the library first 1/5 frame uses .1, and issuance frames use .3/.6/1 despite displaying 1/3, 2/3, 3/3. This visual override does not alter step numbering or validation. Long copy wraps and can increase the component height.

The title row hugs its content so the warning dot stays adjacent to the title. The title column explicitly uses physical-right alignment under RTL; supporting text is inset 8px from that edge, with a 6px vertical gap. This shared fix also applies to the [expired gift balance flow](cards/expired-gift-balance.md).

The example gallery's `FigmaNameMapper` registers Stepper → AppStepper and previews it; the Components tab also renders first/last variants.

`AppToggle.appearance: AppToggleAppearance.issuance` opts into Gray/100 off track, the two Shadow/sm thumb layers and physical off-left/on-right alignment. Default `standard` retains existing colors, shadow and direction-aware alignment. Disabled behavior is unchanged.

`AppCardIssuanceColors` owns the summary Brand/25 surface, summary title, terms surface and input hint instance tokens. The main app composes them with existing semantic colors. No bank workflow or payment behavior lives in avp_ui.

### Shared app composition for issuance

The app-owned `AppInvoice` opts into a white surface with `backgroundColor: context.colors.surface`, Gray/500 labels with `labelColor: context.colors.textTertiary`, and localized wallet-status copy through `walletSufficientLabel`/`walletInsufficientLabel`. Its existing defaults remain unchanged. `AppAddressCard.variant: AppAddressCardVariant.delivery` renders the compact white address/delete row; `full` remains the default. These widgets remain in the main app's shared layer and are not exports of avp_ui. The issuance toggle clips the thumb shadows to its rounded track, matching the original SVG.

Known retained state differences: the existing primary button disabled surface is Gray/100 with no shadow, while issuance frames use Gray/200 with Shadow/xs; loading keeps the existing package spinner treatment. The shared invoice retains .5px divider layout slots, adding 1px to expanded and .5px to collapsed height compared with Figma's zero-height divider layout. See the main app's `doc/cards/card-issuance.md` for the complete flow and design audit.

## Password services and Video player (2026-10-10)

| Figma name | Node | Public widget | Source |
| --- | --- | --- | --- |
| Video player | `27997:11898` (instance in `27997:11891`) | `AppVideoPlayer` | `lib/widgets/media/app_video_player.dart` |

`AppVideoPlayer` uses Flutter's official `video_player` plugin (2.14.1, BSD-3-Clause, flutter.dev publisher) for real inline playback on Android/iOS/web. The app creates a `VideoPlayerController.networkUrl` or `.asset`, passes it with a poster and localized play/pause/retry/unavailable/seek labels, and disposes it. Controller types are re-exported through the public barrel. The widget initializes on Play, handles buffering/error/retry, seeks on an LTR timeline inside RTL layouts, reports completion, preserves the full video frame with configurable videoFit (default contain), and pauses on backgrounding/removal. Replacement ignores old initialization completions. It does not own URLs, authentication, caching, recording or KYC. Its default is a square, rounded8px viewport with authored16px Play and8px track. `aspectRatio` and `showControls` support other instances. A missing controller keeps the poster and disables playback; errors retain the poster and expose Retry.

The Figma name mapper registers Video player once and includes a poster-only preview. Original shared play SVGs belong to the package; posters belong to the consuming feature. Do not use a screen screenshot as a poster.

Additive APIs retain existing defaults:
- `AppTextField.obscureText`, `obscuringCharacter`, `autocorrect`, `enableSuggestions` and `enableIMEPersonalizedLearning` enable secure password fields. Optional hintTextDirection aligns localized placeholders independently of the surrounding RTL icon layout; the default remains unchanged. Password callers must disable suggestions, autocorrection and personalized learning.
- `AppSelect.menuBuilder` optionally returns a selection from a custom menu. `null` cancels. By default the menu matches the input width with a 6px gap, opens above when space below is insufficient, and scrolls within a 320px maximum height. Outside taps and Back dismiss it without changing the value.
- `AppButton.disabledAppearance: AppButtonDisabledAppearance.service` opts primary disabled buttons into Gray200 plus Shadow/xs. Standard/default and loading states remain unchanged.
- `AppPasswordServiceColors` owns the password-instance title/body/hint/camera-notice/recording-scrim tokens.

Dependency review: video_player supplies native/web media surfaces; in-house platform playback would require three separate engines. Chewie adds an unnecessary control system; media_kit brings a larger engine/dependency footprint. Network videos require Android INTERNET permission, HTTPS on iOS, and a host with supported codecs/range/CORS behavior on web. Dependency resolution and tests do not prove device/browser media decoding.

The app-owned `AppInvoice` accepts optional `borderRadius` and `zeroHeightDividers` for the square white130px password-fee instance. Defaults remain16px corners and.5px divider slots; this widget is not an avp_ui export.


### Shared password recovery operation

`SecondPasswordScreen(selectOperation: true, initialCardNumber: cardNumber)` enables the Figma Change password / Forgot password selector on the existing setup flow. `card-pin-second-forgot` routes here; setup routes retain the default mode. `PasswordOperation` is supplied to repository `status(cardId, operation: ...)` and `SetSecondPasswordRequest.operation`. Adapters distinguish initial setup eligibility from `PasswordCard.canResetSecondPassword` and implement operation-specific submission/status. The shared UI, PIN validation, serial, video, mock KYC and receipt stages remain common. See [password-services development](cards/password-services.md) for the contract and prototype limits.


### Change password in the shared flow

Card Services `card-pin-second-change` enables operation selection on `SecondPasswordScreen`. The change branch collects secure current/new/confirmation PINs and terms, omits the setup fee/serial/video stages, and submits `SetSecondPasswordRequest(operation: PasswordOperation.changePassword, currentPassword: ...)`. New results use the change-success sheet; returning status reads render the full-page tracking content. Adapters must verify the current credential at the bank; the mock validates its numeric format only. The existing public avp_ui inputs/buttons/selects are reused. See the ordered11-frame audit in [password-services development](cards/password-services.md).


### Virtual card requests

`VirtualCardRequestScreen(repository: adapter, initialDepositNumber: number)` composes public avp_ui inputs/selects/buttons and the app-owned AppInvoice. `VirtualCardRepository` supplies catalog, bound fee quotes and idempotent submission receipts. `card-virtual`/`card-virtual-request` open the request form; `card-virtual-list` and card category chips retain list access. The virtual-list footer opens the same form unless a host callback handles it. See [request architecture and mock fee limits](cards/virtual-card-request.md).

## Button activity and loading

`AppButton.isActive` defaults to `true`; set it to `false` to disable interaction
and apply disabled styling while keeping an `onPressed` callback. A null callback
still disables the button. `isLoading: true` shows the existing spinner in place
of its content and blocks interaction regardless of `isActive`. Existing callers
that omit `isActive` keep their previous behavior.

Login supplies `isActive: state.formValid` and
`isLoading: state.status == RequestStatus.loading`. The current synchronous login
prototype does not create artificial loading states; real request status changes
belong to future bank integration.

## Direct state-driven text inputs

`AppTextField` accepts optional `value`, `onFocusLost`, and `maxLength` inputs.
Use either `value` or an external `controller`, never both. With `value`, the
package owns a controller and synchronizes changes, including an empty string
that clears the field. Unchanged values preserve selection/composition, and
programmatic synchronization does not invoke `onChanged`. The package never
disposes externally supplied controllers or focus nodes.

`onFocusLost` runs on blur of the active focus node and can invoke app-owned
validation. `maxLength` applies after digit normalization and custom formatters
without displaying a counter. These parameters are opt-in; existing defaults
and uncontrolled/controller-based fields retain their behavior.

Login, CAPTCHA, and OTP pass their Cubit values directly, with
`normalizeDigits: true`, `FilteringTextInputFormatter.digitsOnly`, and their
individual length limits. Their text uses `TextDirection.rtl` and
`TextAlign.start` in empty and filled states. Banking validation belongs to the
app. No intermediary input widget is required.

## AvpImage: shared image presentation

Use `AvpImage` from `package:avp_ui/avp_ui.dart` for app image rendering instead
of directly constructing `SvgPicture.asset`, `Image.asset` or their network/file
variants. This is a shared rendering primitive, not a Figma component with a new
node ID. Existing assets stay owned by their app/package and keep their paths.

```dart
AvpImage(image: asset, width: 20, height: 20)

AvpImage(
  image: AppAssets.examplePhoto,
  width: 80,
  height: 80,
  fit: BoxFit.cover,
  isCircle: true,
  semanticsLabel: localizedDescription,
)

AvpImage(
  image: imageUrl,
  placeholder: AppAssets.examplePlaceholder,
  width: 120,
  height: 80,
  headers: imageHeaders,
  cacheManager: imageCacheManager,
  cacheKey: scopedCacheKey,
)
```

The `AppAssets.example...` names above illustrate host-supplied paths, not new
package assets. The package does not import application registries or Cubits.

### Supported inputs

- `image`: nullable asset path, HTTP(S) URL or native file path. Empty/missing
  input safely renders the placeholder or a size-preserving empty box.
- SVG, raster formats supported by Flutter, and Lottie JSON are selected from
  the URI **path**, case-insensitively. URL query strings do not change type.
  `type: AvpImageType.svg/raster/lottie` overrides detection for extensionless URLs.
- `isFile: true` selects native files; `file:` URIs are also recognized. File
  access uses a conditional native implementation. Browser filesystem paths
  render the fallback rather than importing `dart:io` into the web entry point.
- `placeholder`: another asset path used for missing input, async loading or
  errors. A failed placeholder terminates at an empty box, without recursive
  loading. No fallback image asset is fabricated by the package.
- `width`, `height`, `fit` (default `BoxFit.contain`), `alignment` and directional
  `padding` control presentation. `package` resolves package-owned assets.
- `isCircle`, optional `circleWidth/circleHeight` clip content. `isMicro` renders
  the placeholder on the semantic disabled surface with the package 16px radius.
  `backgroundColor` may override the surface using an existing semantic token.
- `color` or `colorFilter` tints the rendered content; provide only one. A
  ColorFiltered wrapper applies consistently across SVG, raster and Lottie.
- `semanticsLabel` describes informative images; `excludeFromSemantics: true`
  excludes decoration. `matchTextDirection` opts asset/network SVG and raster
  content into RTL mirroring; the default is false for bank logos and numbers.
- `animate` and `repeat` control Lottie playback (both default true).

`placeHolder` from the supplied reference becomes `placeholder`; `boxFit`
becomes `fit`. Boolean parameters are non-nullable and have explicit defaults.
There are no imports, palettes or hard-coded fallback assets from Caltivita.

### Network and cache ownership

Raster HTTP(S) images use `cached_network_image`, `cacheManager`, `cacheKey` and
`headers`. The default manager provides a disk cache on supported native
platforms; it is an evictable cache, not permanent user storage. The package uses
the HttpGet web image strategy, which requires suitable CORS headers. The
upstream library does not provide the same persistent disk cache on web.

As in the supplied reference, network SVG and Lottie use their respective
loaders; they do not pass through the raster disk cache manager. `headers` is
forwarded to all HTTP(S) loaders. App authentication, allowed URLs, cache-key
scoping, retention and cleanup remain host-owned. Do not use the default public
image cache for private banking documents. A host can inject its own configured
`BaseCacheManager`; the public barrel also exports `CacheManager`, `Config` and
`DefaultCacheManager` for this purpose.

Use a native filesystem path only on native platforms. Browser file pickers
require a separate bytes/blob contract; a desktop path is not a browser image.

### Dependencies and alternatives

The owner explicitly requested all capabilities of the reference, including
Lottie and cached network raster images. The direct additions are
`cached_network_image ^4.0.4`, its platform interface `^5.0.3` (for HttpGet),
`flutter_cache_manager ^3.4.5`, and `lottie ^3.6.1`. `file ^7.0.1` is a test-only
dependency for a deterministic cache-manager fixture. These image/cache/Lottie
dependencies have MIT licenses according to their upstream package records.
The existing SVG toolchain dependency `vector_graphics_compiler ^1.3.0` is also
declared directly (BSD-3-Clause) to compile SVG before mounting its renderer.
This keeps failed I/O and invalid SVG on the observed loading Future, rendering
the fallback without unhandled secondary cache Futures. Theme data is captured
before awaiting; source changes and disposal are handled by the widget lifecycle.

Flutter's plain `Image.network` provides no equivalent managed disk cache.
Implementing an independent file-cache/eviction system would duplicate the
cache manager. Lottie JSON cannot be decoded by Flutter's raster or SVG loaders;
converting animations to GIF/video would change the supplied asset contract.
The existing `flutter_svg` remains the SVG engine. No business validation,
navigation or service state is added to this widget.

References: [cached_network_image](https://pub.dev/packages/cached_network_image),
[flutter_cache_manager](https://pub.dev/packages/flutter_cache_manager),
[Lottie](https://pub.dev/packages/lottie).

### Main-application migration

The Pishkhan app's 132 direct SVG and 9 direct raster widget constructions were
replaced with `AvpImage` in 86 Dart files. Existing width/height/fit, callbacks
and surrounding layout remain at their original consumption points. Direct
`flutter_svg` imports were removed from app rendering code.

`AssetImage` used to decode the dashboard's `ui.Image` texture for an existing
`CustomPainter` remains: it is an image-provider/pixel-decoding operation, not a
widget displaying an image. Test pre-caching and test inspection of internal
Flutter/SVG widgets also remain valid. Existing avp_ui component internals need
not be globally rewritten to consume their own new wrapper.

## Unified dashboard/Home scope (2026-10-16)

Supply adapters through `DashboardScreen(repositories: bundle)`. The screen owns
one `HomeCubit` and one plain `HomeState` for all four retained tabs.
`CardsTab()`, `DepositsTab()` and `LoansTab()` use that existing Provider;
they no longer accept repositories or callbacks. Home owns independent request
statuses, catalog generations, selected banking records, favorite editing and
operation eligibility. The parent listener executes typed `HomeEffect` outputs
for navigation, copy and host integration. Replacing the bundle reloads only
the changed adapters. Do not create a Cubit per tab.
