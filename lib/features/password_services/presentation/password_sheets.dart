import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../domain/password_data.dart';

Future<T?> passwordSheet<T>(
  BuildContext context,
  WidgetBuilder panel, {
  bool requestStatus = false,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  // A field inside SafeArea has consumed inherited padding. Read system bars
  // from the view so every sheet reserves the same physical safe area.
  final view = View.of(context);
  final insets = EdgeInsets.fromViewPadding(
    view.viewPadding,
    view.devicePixelRatio,
  );
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    enableDrag: false,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: Stack(
          children: [
            Positioned.fill(
              top: insets.top,
              bottom: insets.bottom,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: SvgPicture.asset(
                      requestStatus
                          ? AppAssets.passwordRequestScrim
                          : AppAssets.passwordScrim,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: insets.bottom,
              child: Material(
                color: context.colors.surfaceSubtle,
                borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.sizeOf(context).height -
                        insets.top -
                        insets.bottom -
                        16,
                  ),
                  child: SingleChildScrollView(child: panel(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

TextStyle passwordBody(BuildContext context) =>
    AppTypography.bodyMedium.copyWith(
      height: 20 / 14,
      letterSpacing: 0,
      color: AppPasswordServiceColors.title,
    );

Future<T?> showPasswordOptions<T>(
  BuildContext context,
  String title,
  List<AppSelectOption<T>> options,
  T? selected,
) => passwordSheet<T>(
  context,
  (context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppBottomSheetHeader(
        title: title,
        showRightIcon: false,
        onLeftAction: () => Navigator.of(context).pop(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0)
                SizedBox(
                  height: 0,
                  child: OverflowBox(
                    minHeight: .5,
                    maxHeight: .5,
                    child: SvgPicture.asset(
                      AppAssets.cardFeaturesDivider,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              Semantics(
                selected: options[i].value == selected,
                button: true,
                child: InkWell(
                  key: Key('password_option_${options[i].value}'),
                  onTap: options[i].enabled
                      ? () => Navigator.of(context).pop(options[i].value)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            options[i].label,
                            style: passwordBody(context)
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          if (options[i].supportingText != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              options[i].supportingText!,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.textSecondary,
                                height: 18 / 12,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  ),
);

Future<void> showPasswordRecord(
  BuildContext context,
  PasswordRequestRecord record, {
  bool newlySubmitted = false,
}) => passwordSheet<void>(context, (context) {
  final approved = record.status == PasswordRequestStatus.approved;
  final l = context.l10n;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const AppBottomSheetHeader(type: AppBottomSheetHeaderType.handleOnly),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (approved) ...[
              Center(
                child: SizedBox(
                  width: 57.0045,
                  height: 59.9961,
                  child: SvgPicture.asset(AppAssets.passwordApproved),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              approved
                  ? l.passwordApprovedTitle
                  : newlySubmitted
                  ? l.passwordSubmittedTitle
                  : l.passwordPendingTitle,
              textAlign: TextAlign.center,
              style: passwordBody(context)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Text(
              approved
                  ? l.passwordApprovedBody
                  : newlySubmitted
                  ? l.passwordSubmittedBody
                  : l.passwordPendingBody,
              textAlign: approved || newlySubmitted
                  ? TextAlign.center
                  : TextAlign.start,
              style: passwordBody(context),
            ),
            if (approved || newlySubmitted) ...[
              const SizedBox(height: 20),
              Container(
                key: const Key('password_tracking'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                constraints: const BoxConstraints(minHeight: 44),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.passwordTracking,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.textTertiary,
                          height: 18 / 12,
                        ),
                      ),
                    ),
                    SelectableText(
                      record.trackingCode ?? '—',
                      textDirection: TextDirection.ltr,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppPasswordServiceColors.body,
                        height: 18 / 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (record.isMock) ...[
              const SizedBox(height: 12),
              Text(
                l.passwordMockReceipt,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textTertiary,
                  height: 18 / 12,
                ),
              ),
            ],
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: AppButton(
          key: const Key('password_record_dismiss'),
          onPressed: () => Navigator.of(context).pop(),
          label: l.passwordUnderstood,
          size: AppButtonSize.lg,
          constrainLabel: true,
        ),
      ),
    ],
  );
}, requestStatus: true);
