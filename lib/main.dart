import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/auth/presentation/auth_screen.dart';
import 'package:pishkhan_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PishkhanApp());
}

class PishkhanApp extends StatefulWidget {
  const PishkhanApp({super.key});

  @override
  State<PishkhanApp> createState() => _PishkhanAppState();
}

class _PishkhanAppState extends State<PishkhanApp> {
  var _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: const Locale('fa'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: _isAuthenticated
          ? const DashboardScreen()
          : BlocProvider(
              create: (_) => AuthCubit(),
              child: AuthScreen(
                onAuthenticated: () => setState(() => _isAuthenticated = true),
              ),
            ),
    );
  }
}

/// Kept as a compatibility entry point for existing app tests and integrations.
class MyApp extends PishkhanApp {
  const MyApp({super.key});
}
