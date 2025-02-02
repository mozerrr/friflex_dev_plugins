import 'package:flutter/material.dart';
import 'package:friflex_dev_plugins/friflex_dev_plugins.dart';
import 'icon.dart' as icon;

class Performance extends StatelessWidget implements Pluggable {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: 20),
        child: SizedBox(
            child: PerformanceOverlay.allEnabled(),
            width: MediaQuery.of(context).size.width));
  }

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);

  @override
  String get name => 'PerfOverlay';

  @override
  String get displayName => 'PerfOverlay';

  @override
  void onTrigger() {}
}
