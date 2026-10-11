import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/router_session.dart';

/// Exercise feature fixtures with the same route table as the application.
class TestRouterApp extends StatefulWidget {
  const TestRouterApp({
    super.key,
    required this.home,
    this.theme,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const [Locale('en')],
    this.builder,
    this.debugShowCheckedModeBanner = false,
  });
  final Widget home;
  final ThemeData? theme;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;
  final TransitionBuilder? builder;
  final bool debugShowCheckedModeBanner;
  @override
  State<TestRouterApp> createState() => _TestRouterAppState();
}

class _TestRouterAppState extends State<TestRouterApp> {
  final session = RouterSession(true);
  late final home = ValueNotifier<Widget>(widget.home);
  late final GoRouter router = createAppRouter(
    session: session,
    initialLocation: DashboardRoutes.home,
    homeBuilder: (_) => ValueListenableBuilder<Widget>(
      valueListenable: home,
      builder: (_, child, _) => child,
    ),
  );
  @override
  void didUpdateWidget(covariant TestRouterApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    home.value = widget.home;
  }

  @override
  void dispose() {
    router.dispose();
    session.dispose();
    home.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    routerConfig: router,
    theme: widget.theme,
    locale: widget.locale,
    localizationsDelegates: widget.localizationsDelegates,
    supportedLocales: widget.supportedLocales,
    builder: widget.builder,
    debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
  );
}
