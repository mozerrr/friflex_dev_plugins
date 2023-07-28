import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friflex_dev_plugins/core/plugin_manager.dart';
import 'package:friflex_dev_plugins/core/ui/root_widget.dart';

import '../../utils/mock_classes.dart';

void main() {
  setUp(() {
    const plugin0 = 'MockPluggable';
    const plugin1 = 'MockPluggableWithStream';
    SharedPreferences.setMockInitialValues({
      'PluginStoreKey': [plugin0, plugin1],
      'MinimalToolbarSwitch': true,
    });
  });

  group('RootWidget', () {
    testWidgets('RootWidget assert constructor', (tester) async {
      await tester.pumpWidget(UMEWidget(
        enable: false,
        child: Container(),
      ));
      expect(find.byType(UMEWidget), isOnstage);
      expect(find.byType(Container), isOnstage);
      expect(find.byType(Overlay), findsOneWidget);
    });

    testWidgets('RootWidget pump widget', (tester) async {
      PluginManager.instance
          .registerAll([MockPluggable(), MockPluggableWithStream()]);
      final umeRoot = UMEWidget(
          enable: true,
          child: MaterialApp(
              home: Scaffold(
            body: Container(),
          )));

      await tester.pumpWidget(umeRoot);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(umeRoot, isNotNull);
    });

    testWidgets('Floating dot position', (tester) async {
      const plugin0 = 'MockPluggable';
      const plugin1 = 'MockPluggableWithStream';
      MethodChannel channel = const MethodChannel('bd_shared_preferences');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (MethodCall methodCall) async {
        if (methodCall.method == 'commit') {
          return Map<String, dynamic>.from(methodCall.arguments);
        } else if (methodCall.method == 'getAll') {
          return {
            'PluginStoreKey': [plugin0, plugin1],
            'MinimalToolbarSwitch': true,
            'FloatingDotPos': '123,123',
          };
        } else {
          return null;
        }
      });

      PluginManager.instance.registerAll([
        MockPluggable(),
        MockPluggableWithStream(),
        MockPluggableWithNestedWidget()
      ]);
      final umeRoot = UMEWidget(
          enable: true,
          child: MaterialApp(
              home: Scaffold(
            body: Container(),
          )));
      await tester.pumpWidget(umeRoot);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
    });

    testWidgets('RootWidget flutter logo drag', (tester) async {
      PluginManager.instance
          .registerAll([MockPluggable(), MockPluggableWithStream()]);
      final umeRoot = UMEWidget(
          enable: true,
          child: MaterialApp(
              home: Scaffold(
            body: Container(),
          )));
      await tester.pumpWidget(umeRoot);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final fl = find.byType(FlutterLogo);
      await tester.drag(fl, const Offset(-100, -100));
      await tester.pump(const Duration(seconds: 1));
      await tester.drag(fl, const Offset(-2000, -2000));
      await tester.pump(const Duration(seconds: 1));
      await tester.drag(fl, const Offset(2000, 2000));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('RootWidget flutter logo drag', (tester) async {
      PluginManager.instance
          .registerAll([MockPluggable(), MockPluggableWithStream()]);
      final umeRoot = UMEWidget(
          enable: true,
          child: MaterialApp(
              home: Scaffold(
            body: Container(),
          )));
      await tester.pumpWidget(umeRoot);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final Offset flutterLogoPosition =
          tester.getCenter(find.byType(FlutterLogo));
      await tester.dragFrom(flutterLogoPosition, const Offset(-100, -100));
      await tester.pump();
      await tester.pumpAndSettle();
    });

    testWidgets('RootWidget flutter logo tap', (tester) async {
      PluginManager.instance
          .registerAll([MockPluggable(), MockPluggableWithStream()]);
      final umeRoot = UMEWidget(
          enable: true,
          child: MaterialApp(
              home: Scaffold(
            body: Container(),
          )));
      await tester.pumpWidget(umeRoot);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final Offset flutterLogoPosition =
          tester.getCenter(find.byType(FlutterLogo));
      await tester.tapAt(flutterLogoPosition);
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tapAt(flutterLogoPosition);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('RootWidget actions', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();

      PluginManager.instance
          .registerAll([MockPluggable(), MockPluggableWithStream()]);

      final umeRoot = UMEWidget(
          enable: true,
          child: MaterialApp(
              home: Scaffold(
            body: Container(),
          )));
      await tester.pumpWidget(umeRoot);
      await tester.pump(const Duration(seconds: 1));

      final Offset flutterLogoPosition =
          tester.getCenter(find.byType(FlutterLogo));
      await tester.tapAt(flutterLogoPosition);
      await tester.pump(const Duration(seconds: 1));

      final Offset maximalBtnPosition =
          tester.getCenter(find.byWidgetPredicate((widget) {
        return widget is InkWell &&
            (widget.child is CircleAvatar) &&
            (widget.child as CircleAvatar).backgroundColor == const Color(0xff53c22b);
      }));
      await tester.tapAt(maximalBtnPosition);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(const Duration(seconds: 1));

      await tester.tapAt(flutterLogoPosition);
      await tester.pump(const Duration(seconds: 1));

      final Offset minimalBtnPosition =
          tester.getCenter(find.byWidgetPredicate((widget) {
        return widget is InkWell &&
            (widget.child is CircleAvatar) &&
            (widget.child as CircleAvatar).backgroundColor == const Color(0xffe6c029);
      }));
      await tester.tapAt(minimalBtnPosition);
      await tester.pump(const Duration(seconds: 1));

      final Offset closeBtnPosition =
          tester.getCenter(find.byWidgetPredicate((widget) {
        return widget is InkWell &&
            (widget.child is CircleAvatar) &&
            (widget.child as CircleAvatar).backgroundColor == const Color(0xffff5a52);
      }));
      await tester.tapAt(closeBtnPosition);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Build nested widget', (tester) async {
      PluginManager.instance.registerAll([MockPluggableWithNestedWidget()]);
      final umeRoot = UMEWidget(
          enable: true,
          child: MaterialApp(
              home: Scaffold(
            body: Container(),
          )));
      await tester.pumpWidget(umeRoot);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final Offset flutterLogoPosition =
          tester.getCenter(find.byType(FlutterLogo));
      await tester.tapAt(flutterLogoPosition);
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('MockPluggableWithNestedWidget'));
      await tester.pumpAndSettle();

      await tester.tapAt(flutterLogoPosition);
    });
  });
}
