import 'package:flutter_test/flutter_test.dart';
import 'package:vahan_flutter_app/main.dart';

void main() {
  testWidgets('VahanApp loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VahanApp());
    expect(find.byType(VahanApp), findsOneWidget);
  });
}
