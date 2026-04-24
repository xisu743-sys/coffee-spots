import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_spots/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CoffeeSpotsApp());
  });
}
