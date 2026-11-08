import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';

/// Shared page chrome only. Each screen visibly owns its Provider and flow.
class WalletScaffold extends StatelessWidget {
  const WalletScaffold({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.busy = false,
    this.showAssistant = true,
    this.showClose = false,
  });
  final String title;
  final Widget child;
  final Widget? footer;
  final bool busy, showAssistant, showClose;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: !busy,
        child: Scaffold(
          backgroundColor: context.colors.surfaceSubtle,
          body: SafeArea(
            child: Column(
              children: [
                AppTopBar(
                  title: title,
                  showLeadingActions: false,
                  leadingAction: showClose
                      ? AppButton(
                          tooltip: S.current.walletCancel,
                          icon: const AvpImage(
                            image:
                                '${AppConstants.baseImage}icon_close_24_gray700.svg',
                            width: 24,
                            height: 24,
                          ),
                          variant: AppButtonVariant.text,
                          onPressed: () => NavigationActions.back(context),
                        )
                      : const SizedBox.shrink(),
                  trailingIcon: const AvpImage(
                    image: '${AppConstants.baseImage}deposit_list_back.svg',
                    width: 24,
                    height: 24,
                  ),
                  trailingTooltip: S.current.backLabel,
                  isTrailingActive: !busy,
                  onTrailingPressed: () => NavigationActions.back(context),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      child,
                      if (showAssistant)
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: IgnorePointer(
                            ignoring: busy,
                            child: AppAssistantButton(
                              onPressed: () =>
                                  NavigationActions.returnHome(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: SizedBox(width: double.infinity, child: footer!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
