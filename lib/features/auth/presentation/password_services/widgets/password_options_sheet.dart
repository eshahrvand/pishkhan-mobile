import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

class PasswordOptionsSheet<T> extends StatelessWidget {
  const PasswordOptionsSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
  });
  final String title;
  final List<AppSelectOption<T>> options;
  final T? selected;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetHeader(
          title: title,
          showRightIcon: false,
          onLeftAction: () => context.pop(),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 32),
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
                      child: AvpImage(
                        image: AppAssets.cardFeaturesDivider,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                Semantics(
                  selected: options[i].value == selected,
                  button: true,
                  child: InkWell(
                    onTap: options[i].enabled
                        ? () => context.pop(options[i].value)
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
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(
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
    );
  }
}
