import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/features/auth/domain/entities/password_data.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_options_sheet.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

Future<void> showPasswordRecord(
  BuildContext context,
  PasswordRequestRecord record, {
  bool newlySubmitted = false,
  PasswordOperation operation = PasswordOperation.setSecondPassword,
}) => passwordSheet<void>(
  context,
  (context) => PasswordRecordSheet(
    record: record,
    newlySubmitted: newlySubmitted,
    operation: operation,
  ),
  requestStatus: true,
  scrimAsset: operation == PasswordOperation.changePassword
      ? AppAssets.passwordChangeScrim
      : null,
);

Future<bool?> showPasswordExitDialog(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) => const PasswordExitDialog(),
);

Future<T?> passwordSheet<T>(
  BuildContext context,
  WidgetBuilder panel, {
  bool requestStatus = false,
  String? scrimAsset,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    enableDrag: false,
    builder: (context) => PasswordSheetLayout(
      panel: panel,
      requestStatus: requestStatus,
      scrimAsset: scrimAsset,
    ),
  );
}

Future<T?> showPasswordOptions<T>(
  BuildContext context,
  String title,
  List<AppSelectOption<T>> options,
  T? selected, {
  String? scrimAsset,
}) => passwordSheet<T>(
  context,
  (context) =>
      PasswordOptionsSheet(title: title, options: options, selected: selected),
  scrimAsset: scrimAsset,
);

class PasswordSheetLayout extends StatelessWidget {
  const PasswordSheetLayout({
    super.key,
    required this.panel,
    this.requestStatus = false,
    this.scrimAsset,
  });

  final WidgetBuilder panel;
  final bool requestStatus;
  final String? scrimAsset;

  @override
  Widget build(BuildContext context) {
    // A field inside SafeArea has consumed inherited padding. Read system bars
    // from the view so every sheet reserves the same physical safe area.
    final view = View.of(context);
    final insets = EdgeInsets.fromViewPadding(
      view.viewPadding,
      view.devicePixelRatio,
    );
    return Directionality(
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
                onTap: () => context.pop(),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: SvgPicture.asset(
                      scrimAsset ??
                          (requestStatus
                              ? AppAssets.passwordRequestScrim
                              : AppAssets.passwordScrim),
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
    );
  }
}

class PasswordExitDialog extends StatelessWidget {
  const PasswordExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.passwordExitTitle),
      content: Text(S.current.passwordExitBody),
      actions: [
        AppButton(
          onPressed: () => context.pop(false),
          label: S.current.passwordStay,
          variant: AppButtonVariant.text,
          constrainLabel: true,
        ),
        AppButton(
          onPressed: () => context.pop(true),
          label: S.current.passwordExit,
          isDestructive: true,
        ),
      ],
    );
  }
}
