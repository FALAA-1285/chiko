import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'app_scope.dart';
import 'router.dart';
import 'theme.dart';

class NoStretchScrollBehavior extends MaterialScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class ChikoApp extends StatefulWidget {
  const ChikoApp({super.key, required this.services});

  final AppServices services;

  @override
  State<ChikoApp> createState() => _ChikoAppState();
}

class _ChikoAppState extends State<ChikoApp> {
  // Router dibuat per instance app (bukan variabel global), supaya tiap test mulai dari awal.
  late final GoRouter _router = createRouter(
    initialLocation: widget.services.settings.onboardingSelesai ? '/beranda' : '/sambutan',
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: widget.services,
      child: MaterialApp.router(
        title: 'Chiko',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        routerConfig: _router,
        // Bahasa Indonesia untuk pemilih tanggal/jam dan teks bawaan Material.
        locale: const Locale('id'),
        supportedLocales: const [Locale('id')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        scrollBehavior: const NoStretchScrollBehavior(),
      ),
    );
  }
}
