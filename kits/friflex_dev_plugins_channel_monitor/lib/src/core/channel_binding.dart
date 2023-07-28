import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friflex_dev_plugins_channel_monitor/src/core/ume_binary_messenger.dart';

class ChannelBinding extends WidgetsFlutterBinding {
  @override
  @protected
  // 替换 BinaryMessenger
  BinaryMessenger createBinaryMessenger() {
    return UmeBinaryMessenger.binaryMessenger;
  }
}
