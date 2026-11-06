import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kartu_profil_digital/main.dart';
import 'package:kartu_profil_digital/services/pref_services.dart';

void main() {
  testWidgets('shows the persisted card open count', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'open_count': 2});
    final prefs = await PrefService.init();
    await prefs.increaseOpenCount();

    await tester.pumpWidget(MyApp(prefs: prefs));

    expect(find.text('Kartu ini sudah dibuka 3 kali'), findsOneWidget);
  });
}
