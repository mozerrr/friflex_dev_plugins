import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

const int maxLine = 1000;

class ConsoleManager {
  static final Queue<(DateTime, String)> _logData = Queue();
  // ignore: close_sinks
  static StreamController? _logStreamController;

  static Queue<(DateTime, String)> get logData => _logData;

  static StreamController? get streamController => _getLogStreamController();

  static DebugPrintCallback? _originalDebugPrint;

  static StreamController? _getLogStreamController() {
    if (_logStreamController == null) {
      _logStreamController = StreamController.broadcast();
      var transformer =
          StreamTransformer<dynamic, (DateTime, String)>.fromHandlers(
              handleData: (str, sink) {
        final now = DateTime.now();
        if (str is String) {
          sink.add((now, str));
        } else {
          sink.add((now, str.toString()));
        }
      });

      _logStreamController!.stream.transform(transformer).listen((value) {
        if (_logData.length < maxLine) {
          _logData.addFirst(value);
        } else {
          _logData.removeLast();
        }
      });
    }
    return _logStreamController;
  }

  static redirectDebugPrint() {
    if (_originalDebugPrint != null) return;
    _originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      ConsoleManager.streamController!.sink.add(message);
      if (_originalDebugPrint != null) {
        _originalDebugPrint!(message, wrapWidth: wrapWidth);
      }
    };
  }

  static clearLog() {
    logData.clear();
    _logStreamController!.add('UME CONSOLE == ClearLog');
  }

  @visibleForTesting
  static clearRedirect() {
    debugPrint = _originalDebugPrint!;
    _originalDebugPrint = null;
  }
}
