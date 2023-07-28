import 'package:flutter/foundation.dart';

class FdpSwitch with ChangeNotifier {
  bool _enable = true;
  bool get enable => _enable;

  void trigger() {
    _enable = !_enable;
    notifyListeners();
  }
}
