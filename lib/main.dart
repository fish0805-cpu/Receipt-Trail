import 'package:flutter/material.dart';

import 'src/app/app_dependencies.dart';
import 'src/app/receipt_trail_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  await dependencies.sessionCoordinator.initialize();
  runApp(ReceiptTrailApp(dependencies: dependencies));
}
