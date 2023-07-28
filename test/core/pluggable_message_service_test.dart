import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:friflex_dev_plugins/core/pluggable_message_service.dart';
import 'package:friflex_dev_plugins/core/plugin_manager.dart';

import '../utils/mock_classes.dart';

void main() {
  group('PluggableMessageService.', () {
    PluggableMessageService? service0;
    MockPluggableWithStream? plugin;

    setUp(() {
      service0 = PluggableMessageService();
      plugin = MockPluggableWithStream();
      PluginManager.instance.register(plugin!);
    });
    test('constructor', () {
      final service = service0;
      expect(service, isNotNull);
    });

    test('streamController type is instance of StreamController.', () {
      final streamController = service0!.messageStreamController;
      expect(streamController, isInstanceOf<StreamController>());
    });

    test(
        'pluggableMessageData is instance of <Map<String, PluggableMessageInfo>>.',
        () {
      final pluggableMessageData = service0!.pluggableMessageData;
      expect(pluggableMessageData,
          isInstanceOf<Map<String, PluggableMessageInfo>>());
    });

    test('A _plugin is registered just now, message count is 0.', () {
      final count = service0!.count(plugin!);
      expect(count, 0);
    });
    test(
        'A _plugin is registered just now, increase counter, message count is 1.',
        () {
      service0!.resetListener();
      service0!.pluggableMessageData[plugin!.name]!.increaseCounter();
      final count = service0!.count(plugin!);
      expect(count, 1);
    });
    test(
        'A _plugin is registered just now, increase and reset counter, message count is 0.',
        () {
      service0!.resetListener();
      service0!.pluggableMessageData[plugin!.name]!
        ..increaseCounter()
        ..resetCounter();
      final count = service0!.count(plugin!);
      expect(count, 0);
    });
    test('A _plugin is registered just now, send a message.', () async {
      service0!.resetListener();
      plugin!.streamController.sink.add('event');
      final count = service0!.count(plugin!);
      expect(count, 0);
    });
    test('Increase counter, reset counter, count is 0.', () async {
      service0!.pluggableMessageData[plugin!.name]!.increaseCounter();
      service0!.resetCounter(plugin!);
      final count = service0!.count(plugin!);
      expect(count, 0);
    });
    test('Increase counter, count all.', () async {
      service0!.pluggableMessageData[plugin!.name]!.increaseCounter();
      final count = service0!.countAll([plugin]);
      expect(count, 1);
    });

    test('PluggableMessage constructor, key.', () async {
      final pluggableMessage = PluggableMessage.create('key', 2);
      expect(pluggableMessage.key, 'key');
    });

    test('PluggableMessage constructor, counter.', () async {
      final pluggableMessage = PluggableMessage.create('key', 2);
      expect(pluggableMessage.count, 2);
    });
  });
}
