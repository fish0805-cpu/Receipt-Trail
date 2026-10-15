import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/app/receipt_trail_app.dart';

import 'support/test_app_dependencies.dart';

void main() {
  testWidgets('injected dependencies build the complete application shell',
      (tester) async {
    final bundle = createTestAppDependencies();
    await bundle.dependencies.sessionCoordinator.initialize();
    await bundle.dependencies.sessionCoordinator.continueAsGuest();

    await tester.pumpWidget(
      ReceiptTrailApp(dependencies: bundle.dependencies),
    );
    await tester.pump();

    expect(find.text('Receipt Trail'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('總覽'), findsOneWidget);
    expect(find.text('發票'), findsOneWidget);
    expect(find.text('掃描'), findsOneWidget);
    expect(find.text('地圖'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(bundle.scanner.disposed, isTrue);
  });
}
