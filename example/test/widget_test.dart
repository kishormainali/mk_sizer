import 'package:flutter_test/flutter_test.dart';
import 'package:mk_sizer_example/main.dart';

void main() {
  testWidgets('demo renders the button design system', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('mk_sizer demo'), findsOneWidget);
    expect(find.text('Responsive button design system'), findsOneWidget);
    expect(find.text('small primary'), findsOneWidget);
    expect(find.text('large outline'), findsOneWidget);
  });
}
