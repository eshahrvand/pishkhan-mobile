import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/core/router/router_session.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PishkhanApp());
}

class PishkhanApp extends StatefulWidget {
  const PishkhanApp({super.key});

  @override
  State<PishkhanApp> createState() => _PishkhanAppState();
}

class _PishkhanAppState extends State<PishkhanApp> {
  final _session = RouterSession();
  late final _router = createAppRouter(session: _session);
  @override
  void dispose() {
    _router.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => S.current.appTitle,
      locale: const Locale('fa'),
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// Kept as a compatibility entry point for existing app tests and integrations.
class MyApp extends PishkhanApp {
  const MyApp({super.key});
}
