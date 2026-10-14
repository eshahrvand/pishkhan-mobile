import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/data/repositories/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/core/router/router_session.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _dashboardRepositories = const DashboardRepositories(
    home: MockDashboardHomeRepository(),
    cards: MockDashboardCardsRepository(),
    deposits: MockDashboardDepositsRepository(),
    loans: MockDashboardLoansRepository(),
  );
  final _session = RouterSession();
  late final _router = createAppRouter(session: _session);
  @override
  void dispose() {
    _router.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RepositoryProvider<DashboardRepositories>.value(
        value: _dashboardRepositories,
        child: MaterialApp.router(
          routerConfig: _router,
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
        ),
      );
}

/// Kept as a compatibility entry point for existing app tests and integrations.
class MyApp extends PishkhanApp {
  const MyApp({super.key});
}
