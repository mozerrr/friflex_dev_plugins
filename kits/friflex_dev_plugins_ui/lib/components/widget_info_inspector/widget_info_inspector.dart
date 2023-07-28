// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:friflex_dev_plugins/friflex_dev_plugins.dart';
import 'package:friflex_dev_plugins_ui/components/hit_test.dart';
import 'icon.dart' as icon;
import 'package:flutter/rendering.dart';
import 'package:friflex_dev_plugins/util/constants.dart';

class WidgetInfoInspector extends StatefulWidget implements Pluggable {
  const WidgetInfoInspector({super.key});

  @override
  _WidgetInfoInspectorState createState() => _WidgetInfoInspectorState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  String get name => 'WidgetInfo';

  @override
  String get displayName => 'WidgetInfo';

  @override
  void onTrigger() {}

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(icon.iconBytes);
}

class _WidgetInfoInspectorState extends State<WidgetInfoInspector>
    with WidgetsBindingObserver {
  _WidgetInfoInspectorState()
      : selection = WidgetInspectorService.instance.selection;

  Offset? _lastPointerLocation;
  OverlayEntry _overlayEntry = OverlayEntry(builder: (ctx) => Container());

  final InspectorSelection selection;

  void _inspectAt(Offset? position) {
    final List<RenderObject> selected =
        HitTest.hitTest(position, edgeHitMargin: 2.0);
    setState(() {
      selection.candidates = selected;
    });
  }

  void _handlePanDown(DragDownDetails event) {
    _lastPointerLocation = event.globalPosition;
    _inspectAt(event.globalPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    final window = View.of(context);
    final Rect bounds =
        (Offset.zero & (window.physicalSize / window.devicePixelRatio))
            .deflate(1.0);
    if (!bounds.contains(_lastPointerLocation!)) {
      setState(() {
        selection.clear();
      });
    }
  }

  void _handleTap() {
    if (_lastPointerLocation != null) {
      _inspectAt(_lastPointerLocation);
    }
  }

  @override
  void initState() {
    super.initState();
    selection.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _overlayEntry = OverlayEntry(builder: (_) => _DebugPaintButton());
      overlayKey.currentState?.insert(_overlayEntry);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    GestureDetector gesture = GestureDetector(
      onTap: _handleTap,
      onPanDown: _handlePanDown,
      onPanEnd: _handlePanEnd,
      behavior: HitTestBehavior.opaque,
      child: IgnorePointer(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height)),
    );
    children.add(gesture);
    children.add(InspectorOverlay(selection: selection));
    return Stack(children: children, textDirection: TextDirection.ltr);
  }

  @override
  void dispose() {
    super.dispose();
    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    }
  }
}

class _DebugPaintButton extends StatefulWidget {
  const _DebugPaintButton({super.key});

  @override
  State<StatefulWidget> createState() => _DebugPaintButtonState();
}

class _DebugPaintButtonState extends State<_DebugPaintButton> {
  late double _dx;
  late double _dy;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dx = windowSize(context).width - dotSize.width - margin * 2;
    _dy = windowSize(context).width - dotSize.width - bottomDistance;
  }

  void _buttonPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dx = details.globalPosition.dx - dotSize.width / 2;
      _dy = details.globalPosition.dy - dotSize.width / 2;
    });
  }

  void _showAllSize() async {
    debugPaintSizeEnabled = !debugPaintSizeEnabled;
    setState(() {
      late RenderObjectVisitor visitor;
      visitor = (RenderObject child) {
        child.markNeedsPaint();
        child.visitChildren(visitor);
      };
      RendererBinding.instance.renderView.visitChildren(visitor);
    });
  }

  @override
  void dispose() {
    debugPaintSizeEnabled = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      late RenderObjectVisitor visitor;
      visitor = (RenderObject child) {
        child.markNeedsPaint();
        child.visitChildren(visitor);
      };
      RendererBinding.instance.renderView.visitChildren(visitor);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _dx,
      top: _dy,
      child: SizedBox(
        width: dotSize.width,
        height: dotSize.width,
        child: GestureDetector(
          onPanUpdate: _buttonPanUpdate,
          child: FloatingActionButton(
            elevation: 10,
            child: Icon(Icons.all_out_sharp),
            onPressed: _showAllSize,
          ),
        ),
      ),
    );
  }
}