import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

import '../../../shell_routes.dart';

class RouteUnavailableScreen extends StatelessWidget {
  const RouteUnavailableScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.surfaceSubtle,
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.cardFeatureUnavailable),
            const SizedBox(height: 16),
            AppButton(
              label: context.l10n.backLabel,
              onPressed: () => context.go(ShellRoutes.home),
            ),
          ],
        ),
      ),
    ),
  );
}
