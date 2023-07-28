import 'package:flutter/material.dart';
import 'package:friflex_dev_plugins/friflex_dev_plugins.dart';
import 'package:friflex_dev_plugins_channel_monitor/src/ui/channel_pages.dart';
import 'dart:convert';
import 'icon.dart' as icon;

class ChannelPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext? context) {
    return const ChannelPages();
  }

  @override
  String get displayName => 'Channel Monitor';

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(icon.iconData));

  @override
  String get name => 'Channel Monitor';

  @override
  void onTrigger() {}
}
