import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('BeissAb app starts', (tester) async {
    await tester.pumpWidget(const BeissAbApp());
    expect(find.byType(BeissAbApp), findsOneWidget);
  });
}
