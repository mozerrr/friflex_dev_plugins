import 'package:dio/dio.dart';
import 'package:example/custom_router_pluggable.dart';
import 'package:example/detail_page.dart';
import 'package:example/home_page.dart';
import 'package:example/fdp_switch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:friflex_dev_plugins/friflex_dev_plugins.dart';
import 'package:friflex_dev_plugins_ui/friflex_dev_plugins_ui.dart';
import 'package:friflex_dev_plugins_dio/friflex_dev_plugins_dio.dart';
import 'package:friflex_dev_plugins_console/friflex_dev_plugins_console.dart';
import 'package:friflex_dev_plugins_channel_monitor/friflex_dev_plugins_channel_monitor.dart';
import 'package:provider/provider.dart';

final Dio dio = Dio()
  ..options = BaseOptions(
    connectTimeout: Duration(seconds: 10),
  );

final navigatorKey = GlobalKey<NavigatorState>();

void main() => runApp(const UMEApp());

class UMEApp extends StatefulWidget {
  const UMEApp({Key? key}) : super(key: key);

  @override
  State<UMEApp> createState() => _UMEAppState();
}

class _UMEAppState extends State<UMEApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomRouterPluggable().navKey = navigatorKey;
    });
    if (kDebugMode) {
      PluginManager.instance
        ..register(WidgetInfoInspector())
        ..register(WidgetDetailInspector())
        ..register(ColorSucker())
        ..register(AlignRuler())
        ..register(ColorPicker())
        ..register(Console())
        ..register(DioInspector(dio: dio))
        ..register(CustomRouterPluggable())
        ..register(ChannelPlugin());
    }
  }

  Widget _buildApp(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'FDP Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(title: 'FDP Demo Home Page'),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'detail':
            return MaterialPageRoute(builder: (_) => const DetailPage());
          default:
            return null;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = _buildApp(context);
    if (kDebugMode) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FdpSwitch()),
        ],
        builder: (BuildContext context, _) => FriflexDevPluginsOverlay(
          enable: context.watch<FdpSwitch>().enable,
          child: body,
        ),
      );
    }
    return body;
  }
}
