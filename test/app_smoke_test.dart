import 'package:brainery_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Brainery app renders splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BraineryApp()));
    expect(find.text('Brainery Mobile'), findsOneWidget);
  });
}
