import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wawubasket/app/wawubasket_app.dart';

void main() {
  testWidgets('App boots and renders the splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WAWUBasketApp()));
    await tester.pump();

    expect(find.text('WAWUBasket'), findsOneWidget);
    expect(find.text('One basket. Everything.'), findsOneWidget);

    // Splash schedules a 1.6s redirect to /welcome — let it fire so the
    // pending timer doesn't trip the binding's invariant check.
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
