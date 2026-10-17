import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/dashboard_reso_cubit.dart';
import 'dashboard_reso_banner_panel.dart';

class DashboardResoBanner extends StatelessWidget {
  const DashboardResoBanner({
    super.key,
    this.focusNode,
    this.enableAnimations = true,
  });
  final FocusNode? focusNode;
  final bool enableAnimations;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardResoCubit(),
      child: DashboardResoBannerPanel(
        focusNode: focusNode,
        enableAnimations: enableAnimations,
      ),
    );
  }
}
