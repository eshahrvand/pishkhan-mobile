import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class RouteUnavailableScreen extends StatelessWidget {
  const RouteUnavailableScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceSubtle,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.current.cardFeatureUnavailable),
              const SizedBox(height: 16),
              AppButton(
                label: S.current.backLabel,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
