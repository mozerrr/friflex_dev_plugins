import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friflex_dev_plugins/friflex_dev_plugins.dart';
import 'package:friflex_dev_plugins_dio/friflex_dev_plugins_dio.dart';

import 'mock_classes.dart';

final Dio _dio = Dio();

void main() {
  group('ConsolePanel', () {
    test('Pluggable', () {
      final DioInspector pluggable = DioInspector(dio: _dio);
      final Widget widget = pluggable.buildWidget(MockContext());
      final String name = pluggable.name;
      final VoidCallback onTrigger = pluggable.onTrigger..call();
      final ImageProvider imageProvider = pluggable.iconImageProvider;

      expect(widget, isA<Widget>());
      expect(name, isNotEmpty);
      expect(onTrigger, isA<Function>());
      expect(imageProvider, isNotNull);
    });

    testWidgets('DioInspector pump widget', (tester) async {
      final DioInspector inspector = DioInspector(dio: _dio);
      await tester.pumpWidget(
        MaterialApp(key: rootKey, home: Scaffold(body: inspector)),
      );
      await tester.pumpAndSettle();
      expect(inspector, isNotNull);
    });
  });
}
