import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenith_market/main.dart';

void main() {
  testWidgets('L’application démarre avec ProviderScope',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ZenithMarketApp(),
      ),
    );

    // Attendre la résolution des timers asynchrones
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Vérifie que l'écran se charge et que le titre est présent
    expect(find.text('Zenith Market'), findsOneWidget);
  });
}
