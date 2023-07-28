import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friflex_dev_plugins/core/ui/global.dart';
import 'package:friflex_dev_plugins/util/floating_widget.dart';

void main() {
  group('FloatingWidget', () {
    testWidgets('FloatingWidget pump widget', (tester) async {
      const floatingWidget = FloatingWidget();
      await tester.pumpWidget(MaterialApp(
          key: rootKey,
          home: const Scaffold(
            body: floatingWidget,
          )));
      await tester.pumpAndSettle();
      expect(floatingWidget, isNotNull);
    });

    testWidgets('FloatingWidget pump widget, drag window', (tester) async {
      const floatingWidget = FloatingWidget();
      await tester.pumpWidget(MaterialApp(
          key: rootKey,
          home: const Scaffold(
            body: floatingWidget,
          )));
      await tester.pumpAndSettle();

      final toolbarTitle = find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == 'UME');

      await tester.drag(toolbarTitle, const Offset(0, -100));
    });

    testWidgets('FloatingWidget pump widget, fullscreen action',
        (tester) async {
      const floatingWidget = FloatingWidget();
      await tester.pumpWidget(MaterialApp(
          key: rootKey,
          home: const Scaffold(
            body: floatingWidget,
          )));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate((widget) =>
          widget is CircleAvatar &&
          widget.backgroundColor == const Color(0xff53c22b)));
      await tester.pumpAndSettle();
      await tester.tap(find.byWidgetPredicate((widget) =>
          widget is CircleAvatar &&
          widget.backgroundColor == const Color(0xffe6c029)));
    });

    testWidgets('FloatingWidget pump widget, toolbar actions', (tester) async {
      var a = 1;
      toolbarAction() {
        a = 2;
      }

      final floatingWidget = FloatingWidget(
        toolbarActions: [('test', const Icon(Icons.search), toolbarAction)],
      );
      await tester.pumpWidget(MaterialApp(
          key: rootKey,
          home: Scaffold(
            body: floatingWidget,
          )));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(a, 2);
    });

    testWidgets('FloatingWidget pump widget, close action', (tester) async {
      var a = 1;
      closeAction() {
        a = 2;
      }

      final floatingWidget = FloatingWidget(
        closeAction: closeAction,
      );
      await tester.pumpWidget(MaterialApp(
          key: rootKey,
          home: Scaffold(
            body: floatingWidget,
          )));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate((widget) =>
          widget is CircleAvatar &&
          widget.backgroundColor == const Color(0xffff5a52)));
      await tester.pumpAndSettle();

      expect(a, 2);
    });
  });
}
