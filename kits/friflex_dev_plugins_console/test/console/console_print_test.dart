import 'package:flutter_test/flutter_test.dart';
import 'package:friflex_dev_plugins_console/console/console_manager.dart';
import 'package:friflex_dev_plugins_console/friflex_dev_plugins_console.dart';

const testMessage = 'Lorem ipsum dolor sit ame';

void main() {
  test('consolePrint', () async {
    consolePrint(testMessage);
    await Future.delayed(Duration.zero);

    final lastLog = ConsoleManager.logData.last.$2;
    expect(lastLog, testMessage);
  });
}
