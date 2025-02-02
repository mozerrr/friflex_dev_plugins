import 'package:shared_preferences/shared_preferences.dart';

class PluginStoreManager {
  final String _pluginStoreKey = 'PluginStoreKey';
  final String _minimalToolbarSwitch = 'MinimalToolbarSwitch';
  final String _floatingDotPos = 'FloatingDotPos';

  final _sharedPref = SharedPreferences.getInstance();

  Future<List<String>?> fetchStorePlugins() async {
    final SharedPreferences prefs = await _sharedPref;
    return prefs.getStringList(_pluginStoreKey);
  }

  Future<void> storePlugins(List<String> plugins) async {
    if (plugins.isEmpty) {
      return;
    }
    final SharedPreferences prefs = await _sharedPref;
    await prefs.setStringList(_pluginStoreKey, plugins);
  }

  Future<bool?> fetchMinimalToolbarSwitch() async {
    final SharedPreferences prefs = await _sharedPref;
    return prefs.getBool(_minimalToolbarSwitch);
  }

  Future<void> storeMinimalToolbarSwitch(bool value) async {
    final SharedPreferences prefs = await _sharedPref;
    await prefs.setBool(_minimalToolbarSwitch, value);
  }

  Future<String?> fetchFloatingDotPos() async {
    final SharedPreferences prefs = await _sharedPref;
    return prefs.getString(_floatingDotPos);
  }

  Future<void> storeFloatingDotPos(double x, double y) async {
    final SharedPreferences prefs = await _sharedPref;
    await prefs.setString(_floatingDotPos, "$x,$y");
  }
}
