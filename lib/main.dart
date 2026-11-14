import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_scope.dart';
import 'core/data/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.open(AppDatabase.openDefault());
  runApp(ChikoApp(services: services));
}
