import 'package:flutter/widgets.dart';

abstract class Pluggable {
  String get name;
  String get displayName;
  void onTrigger();
  Widget? buildWidget(BuildContext? context);
  ImageProvider get iconImageProvider;
}

typedef StreamFilter = bool Function(dynamic);

abstract class PluggableWithStream extends Pluggable {
  Stream get stream;
  StreamFilter get streamFilter;
}

abstract class PluggableWithNestedWidget extends Pluggable {
  Widget buildNestedWidget(Widget child);
}

abstract class PluggableWithAnywhereDoor extends Pluggable {
  NavigatorState? get navigator;

  (String, Object?)? get routeNameAndArgs;
  Route? get route;

  void popResultReceive(dynamic result);
}
