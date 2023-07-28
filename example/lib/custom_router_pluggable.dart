import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:friflex_dev_plugins/friflex_dev_plugins.dart';
import 'icon.dart' as icon;

class CustomRouterPluggable implements PluggableWithAnywhereDoor {
  static final CustomRouterPluggable _instance =
      CustomRouterPluggable._internal();

  factory CustomRouterPluggable() {
    return _instance;
  }

  CustomRouterPluggable._internal();

  GlobalKey<NavigatorState>? navKey;

  @override
  Widget? buildWidget(BuildContext? context) {
    return null;
  }

  @override
  String get displayName => 'ToDetail';

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(icon.iconData));

  @override
  String get name => 'ToDetail';

  @override
  NavigatorState? get navigator => navKey?.currentState;

  @override
  void onTrigger() {}

  @override
  void popResultReceive(result) {
    print(result.toString());
  }

  @override
  Route? get route => null;

  @override
  (String, Object?)? get routeNameAndArgs =>
      ('detail', {'arg': 'custom params'});
}
