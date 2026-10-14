
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_drawer.dart';

class AppDrawerHeader extends StatelessWidget {
  const AppDrawerHeader({
    super.key,
    required this.title,
    required this.logo,
    required this.onClose,
  });

  final String title;
  final Widget? logo;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: colors.surfaceSubtle,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              key: const Key('app_drawer_close'),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 24, height: 24),
              icon: AppDrawerIcons.close(),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 2,
                ),
              ),
            ),
          ),
          if (logo != null) ...[
            const SizedBox(width: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(child: logo),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
