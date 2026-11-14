import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class ChikoApp extends StatelessWidget {
  const ChikoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Chiko',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: appRouter,
    );
  }
}
