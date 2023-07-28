import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:friflex_dev_plugins/core/plugin_manager.dart';
import 'package:friflex_dev_plugins/core/ui/menu_page.dart';

import '../../utils/mock_classes.dart';

void main() {
  group('MenuPage', () {
    setUp(() {
      const plugin0 = 'MockPluggable';
      const plugin1 = 'MockPluggableWithStream';
      SharedPreferences.setMockInitialValues({
        'PluginStoreKey': [plugin0, plugin1],
        'MinimalToolbarSwitch': true,
      });
    });
    testWidgets('MenuPage pump widget', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();

      PluginManager.instance
          .registerAll([MockPluggable(), MockPluggableWithStream()]);

      final menuPage = MenuPage(
        action: (pluggable) {},
        minimalAction: () {},
        closeAction: () {},
      );

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
        body: menuPage,
      )));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(menuPage, isNotNull);
    });

    testWidgets('MenuPage actions', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();

      bool minimalTapped = false;
      bool closeTapped = false;

      PluginManager.instance
          .registerAll([MockPluggable(), MockPluggableWithStream()]);

      final menuPage = MenuPage(
        action: (pluggable) {},
        minimalAction: () => minimalTapped = true,
        closeAction: () => closeTapped = true,
      );

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
        body: menuPage,
      )));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final Offset closeBtnPosition =
          tester.getCenter(find.byWidgetPredicate((widget) {
        return widget is InkWell &&
            (widget.child is CircleAvatar) &&
            (widget.child as CircleAvatar).backgroundColor == const Color(0xffff5a52);
      }));
      await tester.tapAt(closeBtnPosition);
      expect(closeTapped, isTrue);

      final Offset minimalBtnPosition =
          tester.getCenter(find.byWidgetPredicate((widget) {
        return widget is InkWell &&
            (widget.child is CircleAvatar) &&
            (widget.child as CircleAvatar).backgroundColor == const Color(0xffe6c029);
      }));
      await tester.tapAt(minimalBtnPosition);
      expect(minimalTapped, isTrue);
    });
  });
}
