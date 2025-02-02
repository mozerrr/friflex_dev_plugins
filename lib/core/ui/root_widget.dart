// ignore_for_file: library_private_types_in_public_api
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:friflex_dev_plugins/core/pluggable_message_service.dart';
import 'package:friflex_dev_plugins/core/plugin_manager.dart';
import 'package:friflex_dev_plugins/core/red_dot.dart';
import 'package:friflex_dev_plugins/core/store_manager.dart';
import 'package:friflex_dev_plugins/core/ui/toolbar_widget.dart';
import 'package:friflex_dev_plugins/core/pluggable.dart';
import 'package:friflex_dev_plugins/util/constants.dart';
import './menu_page.dart';
import 'global.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const defaultLocalizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

/// Wrap your App widget. If [enable] is false, the function will return [child].
class FriflexDevPluginsOverlay extends StatefulWidget {
  const FriflexDevPluginsOverlay({
    Key? key,
    required this.child,
    this.enable = true,
    this.supportedLocales,
    this.localizationsDelegates = defaultLocalizationsDelegates,
  }) : super(key: key);

  final Widget child;
  final bool enable;
  final Iterable<Locale>? supportedLocales;
  final Iterable<LocalizationsDelegate> localizationsDelegates;

  /// Close the activated plugin if any.
  ///
  /// The method does not have side-effects whether the [FriflexDevPluginsOverlay]
  /// is not enabled or no plugin has been activated.
  static void closeActivatedPlugin() {
    final _ContentPageState? state =
        _fdpWidgetState?._contentPageKey.currentState;
    if (state?._currentSelected != null) {
      state?._closeActivatedPluggable();
    }
  }

  @override
  _FriflexDevPluginsOverlayState createState() =>
      _FriflexDevPluginsOverlayState();
}

/// Hold the [_FriflexDevPluginsOverlayState] as a global variable.
_FriflexDevPluginsOverlayState? _fdpWidgetState;

class _FriflexDevPluginsOverlayState extends State<FriflexDevPluginsOverlay> {
  _FriflexDevPluginsOverlayState() {
    // Make sure only a single `FriflexDevPluginsOverlay` is being used.
    assert(
      _fdpWidgetState == null,
      'Only one `FriflexDevPluginsOverlay` can be used at the same time.',
    );
    if (_fdpWidgetState != null) {
      throw StateError(
        'Only one `FriflexDevPluginsOverlay` can be used at the same time.',
      );
    }
    _fdpWidgetState = this;
  }

  final GlobalKey<_ContentPageState> _contentPageKey = GlobalKey();
  late Widget _child;
  VoidCallback? _onMetricsChanged;

  bool _overlayEntryInserted = false;
  OverlayEntry _overlayEntry = OverlayEntry(
    builder: (_) => const SizedBox.shrink(),
  );

  @override
  void initState() {
    super.initState();
    _injectOverlay();

    _onMetricsChanged = PlatformDispatcher.instance.onMetricsChanged;
    PlatformDispatcher.instance.onMetricsChanged = () {
      if (_onMetricsChanged != null) {
        _onMetricsChanged!();
        _replaceChild();
        setState(() {});
      }
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _replaceChild();
  }

  @override
  void didUpdateWidget(FriflexDevPluginsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.enable
        ? PluggableMessageService().resetListener()
        : PluggableMessageService().clearListener();
    if (widget.enable != oldWidget.enable && widget.enable) {
      _injectOverlay();
    }
    if (widget.child != oldWidget.child) {
      _replaceChild();
    }
    if (!widget.enable) {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    if (_onMetricsChanged != null) {
      PlatformDispatcher.instance.onMetricsChanged = _onMetricsChanged;
    }
    super.dispose();
    // Do the cleaning at last.
    _fdpWidgetState = null;
  }

  void _replaceChild() {
    final nestedWidgets =
        PluginManager.instance.pluginsMap.values.where((value) {
      return value != null && value is PluggableWithNestedWidget;
    }).toList();
    Widget layoutChild = _buildLayout(
        widget.child, widget.supportedLocales, widget.localizationsDelegates);
    for (var item in nestedWidgets) {
      if (item!.name != PluginManager.instance.activatedPluggableName) {
        continue;
      }
      if (item is PluggableWithNestedWidget) {
        layoutChild = item.buildNestedWidget(layoutChild);
        break;
      }
    }
    _child =
        Directionality(textDirection: TextDirection.ltr, child: layoutChild);
  }

  Stack _buildLayout(Widget child, Iterable<Locale>? supportedLocales,
      Iterable<LocalizationsDelegate> delegates) {
    return Stack(
      children: <Widget>[
        RepaintBoundary(key: rootKey, child: child),
        MediaQuery(
          data: MediaQueryData.fromView(
            View.of(context),
          ),
          child: Localizations(
            locale: supportedLocales?.first ?? const Locale('en', 'US'),
            delegates: delegates.toList(),
            child: ScaffoldMessenger(child: Overlay(key: overlayKey)),
          ),
        ),
      ],
    );
  }

  void _removeOverlay() {
    // Call `remove` only when the entry has been inserted.
    if (_overlayEntryInserted) {
      _overlayEntry.remove();
      _overlayEntryInserted = false;
    }
  }

  void _injectOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntryInserted) {
        return;
      }
      if (widget.enable) {
        _overlayEntry = OverlayEntry(
          builder: (_) => Material(
            type: MaterialType.transparency,
            child: _ContentPage(
              key: _contentPageKey,
              refreshChildLayout: () {
                _replaceChild();
                setState(() {});
              },
            ),
          ),
        );
        overlayKey.currentState?.insert(_overlayEntry);
        _overlayEntryInserted = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) => _child;
}

class _ContentPage extends StatefulWidget {
  const _ContentPage({Key? key, this.refreshChildLayout}) : super(key: key);

  final VoidCallback? refreshChildLayout;

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<_ContentPage> {
  final _storeManager = PluginStoreManager();
  late Size _windowSize;
  double _dx = 0;
  double _dy = 0;
  bool _showedMenu = false;
  Pluggable? _currentSelected;
  Widget? _currentWidget;
  Widget? _menuPage;
  BuildContext? _context;

  bool _minimalContent = true;
  Widget? _toolbarWidget;

  @override
  void initState() {
    super.initState();
    _storeManager.fetchFloatingDotPos().then((value) {
      if (value == null || value.split(',').length != 2) {
        return;
      }
      final x = double.parse(value.split(',').first);
      final y = double.parse(value.split(',').last);
      if (MediaQuery.of(context).size.height - dotSize.height < y ||
          MediaQuery.of(context).size.width - dotSize.width < x) {
        return;
      }
      setState(() {
        _dx = x;
        _dy = y;
      });
    });
    _storeManager.fetchMinimalToolbarSwitch().then((value) {
      setState(() {
        _minimalContent = value ?? true;
      });
    });
    itemTapAction(pluginData) async {
      if (pluginData is PluggableWithAnywhereDoor) {
        dynamic result;
        if (pluginData.routeNameAndArgs != null) {
          result = await pluginData.navigator?.pushNamed(
              pluginData.routeNameAndArgs!.$1,
              arguments: pluginData.routeNameAndArgs!.$2);
        } else if (pluginData.route != null) {
          result = await pluginData.navigator?.push(pluginData.route!);
        }
        pluginData.popResultReceive(result);
      } else {
        _currentSelected = pluginData;
        if (_currentSelected != null) {
          PluginManager.instance.activatePluggable(_currentSelected!);
        }
        _handleAction(_context, pluginData!);
        if (widget.refreshChildLayout != null) {
          widget.refreshChildLayout!();
        }
        pluginData.onTrigger();
      }
    }

    _menuPage = MenuPage(
      action: itemTapAction,
      minimalAction: () {
        _minimalContent = true;
        _updatePanelWidget();
        _storeManager.storeMinimalToolbarSwitch(true);
      },
      closeAction: () {
        _showedMenu = false;
        _updatePanelWidget();
      },
    );
    _toolbarWidget = ToolBarWidget(
      action: itemTapAction,
      maximalAction: () {
        _minimalContent = false;
        _updatePanelWidget();
        _storeManager.storeMinimalToolbarSwitch(false);
      },
      closeAction: () {
        _showedMenu = false;
        _updatePanelWidget();
      },
    );
    _currentWidget = const SizedBox.shrink();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _windowSize = windowSize(context);
    _dx = _windowSize.width - dotSize.width - margin * 4;
    _dy = _windowSize.height - dotSize.height - bottomDistance;
  }

  void dragEvent(DragUpdateDetails details) {
    setState(() {
      _dx = details.globalPosition.dx - dotSize.width / 2;
      _dy = details.globalPosition.dy - dotSize.height / 2;
    });
  }

  void dragEnd(DragEndDetails details) {
    setState(() {
      if (_dx + dotSize.width / 2 < _windowSize.width / 2) {
        _dx = margin;
      } else {
        _dx = _windowSize.width - dotSize.width - margin;
      }
      if (_dy + dotSize.height > _windowSize.height) {
        _dy = _windowSize.height - dotSize.height - margin;
      } else if (_dy < 0) {
        _dy = margin;
      }

      _storeManager.storeFloatingDotPos(_dx, _dy);
    });
  }

  void onTap() {
    if (_currentSelected != null) {
      _closeActivatedPluggable();
      return;
    }
    _showedMenu = !_showedMenu;
    _updatePanelWidget();
  }

  void _closeActivatedPluggable() {
    PluginManager.instance.deactivatePluggable(_currentSelected!);
    if (widget.refreshChildLayout != null) {
      widget.refreshChildLayout!();
    }
    setState(() {
      _currentSelected = null;
      _currentWidget = const SizedBox.shrink();
      if (_minimalContent) {
        _currentWidget = _toolbarWidget;
        _showedMenu = true;
      }
    });
  }

  void _updatePanelWidget() {
    setState(() {
      _currentWidget = _showedMenu
          ? (_minimalContent ? _toolbarWidget : _menuPage)
          : const SizedBox.shrink();
    });
  }

  void _handleAction(BuildContext? context, Pluggable data) {
    setState(() {
      _currentWidget = data.buildWidget(context);
      _showedMenu = false;
    });
  }

  Widget _logoWidget() {
    Widget child;

    if (_currentSelected != null) {
      child = SizedBox(
        height: 30,
        width: 30,
        child: Image(image: _currentSelected!.iconImageProvider),
      );
    } else {
      child = SizedBox(
        height: 30,
        width: 30,
        child: _showedMenu
            ? ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1.0,
                    colors: [Colors.yellow, Colors.red],
                    tileMode: TileMode.mirror,
                  ).createShader(bounds);
                },
                child: const FlutterLogo(),
              )
            : const FlutterLogo(),
      );
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    if (_windowSize.isEmpty) {
      _dx = MediaQuery.of(context).size.width - dotSize.width - margin * 4;
      _dy =
          MediaQuery.of(context).size.height - dotSize.height - bottomDistance;
      _windowSize = MediaQuery.of(context).size;
    }
    return SizedBox(
      width: _windowSize.width,
      height: _windowSize.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _currentWidget!,
          Positioned(
            left: _dx,
            top: _dy,
            child: Tooltip(
              message: 'Open dev plugins panel',
              child: RepaintBoundary(
                child: GestureDetector(
                  onTap: onTap,
                  onVerticalDragEnd: dragEnd,
                  onHorizontalDragEnd: dragEnd,
                  onHorizontalDragUpdate: dragEvent,
                  onVerticalDragUpdate: dragEvent,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 2.0,
                          spreadRadius: 1.0,
                        )
                      ],
                    ),
                    width: dotSize.width,
                    height: dotSize.height,
                    child: Stack(
                      children: [
                        Center(
                          child: _logoWidget(),
                        ),
                        Positioned(
                          right: 6,
                          top: 8,
                          child: RedDot(
                            pluginDatas: PluginManager
                                .instance.pluginsMap.values
                                .toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
