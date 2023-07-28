// ignore_for_file: library_private_types_in_public_api
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:friflex_dev_plugins/core/ui/panel_action_define.dart';
import 'package:friflex_dev_plugins/util/constants.dart';
import 'package:friflex_dev_plugins/util/store_mixin.dart';

typedef ToolbarAction = void Function();

class FloatingWidget extends StatefulWidget {
  const FloatingWidget({
    Key? key,
    this.contentWidget,
    this.closeAction,
    this.toolbarActions,
    this.minimalHeight = 120,
  }) : super(key: key);

  final Widget? contentWidget;
  final CloseAction? closeAction;
  final List<(String, Widget, ToolbarAction)>? toolbarActions;
  final double minimalHeight;

  @override
  _FloatingWidgetState createState() => _FloatingWidgetState();
}

const double _dragBarHeight = 32;
const double _toolBarHeight = 32;

class _FloatingWidgetState extends State<FloatingWidget> with StoreMixin {
  late Size _windowSize;
  bool _wasInitialized = false;
  double _dy = 0;
  bool _fullScreen = false;

  double get toolBarHeight =>
      (widget.toolbarActions != null && widget.toolbarActions!.isNotEmpty)
          ? _toolBarHeight
          : 0;

  @override
  void initState() {
    super.initState();
    fetchWithKey('floating_widget').then((value) {
      if (value != null) {
        setState(() {
          _dy = value;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _windowSize = windowSize(context);
    if (!_wasInitialized) {
      _dy = _windowSize.height -
          widget.minimalHeight -
          _dragBarHeight -
          toolBarHeight;
      _wasInitialized = true;
    }
  }

  void _dragEvent(DragUpdateDetails details) {
    setState(() {
      _dy += details.delta.dy;
      _dy = min(
          max(0, _dy),
          MediaQuery.of(context).size.height -
              widget.minimalHeight -
              _dragBarHeight -
              toolBarHeight -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom);
    });
  }

  void _dragEnd(DragEndDetails details) async {
    await storeWithKey('floating_widget', _dy);
  }

  @override
  Widget build(BuildContext context) {
    if (_windowSize.isEmpty) {
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
          Positioned(
            left: 0,
            top: _fullScreen ? 0 : _dy,
            child: _ToolBarContent(
              minimalHeight: widget.minimalHeight,
              contentWidget: widget.contentWidget,
              dragCallback: _dragEvent,
              dragEnd: _dragEnd,
              maximalAction: () {
                setState(() {
                  _fullScreen = !_fullScreen;
                });
              },
              closeAction: widget.closeAction,
              toolbarActions: widget.toolbarActions,
            ),
          )
        ],
      ),
    );
  }
}

class _ToolBarContent extends StatefulWidget {
  const _ToolBarContent(
      {Key? key,
      this.contentWidget,
      this.dragCallback,
      this.dragEnd,
      this.maximalAction,
      this.closeAction,
      this.toolbarActions,
      required this.minimalHeight})
      : super(key: key);

  final Widget? contentWidget;
  final Function? dragCallback;
  final Function? dragEnd;
  final CloseAction? closeAction;
  final MaximalAction? maximalAction;
  final List<(String, Widget, ToolbarAction)>? toolbarActions;
  final double minimalHeight;

  @override
  __ToolBarContentState createState() => __ToolBarContentState();
}

class __ToolBarContentState extends State<_ToolBarContent> {
  late Size _windowSize;
  bool _fullScreen = false;

  double get toolBarHeight =>
      (widget.toolbarActions != null && widget.toolbarActions!.isNotEmpty)
          ? _toolBarHeight
          : 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _windowSize = windowSize(context);
  }

  _dragCallback(DragUpdateDetails details) {
    if (widget.dragCallback != null) widget.dragCallback!(details);
  }

  _dragEnd(DragEndDetails details) {
    if (widget.dragEnd != null) widget.dragEnd!(details);
  }

  @override
  Widget build(BuildContext context) {
    if (_windowSize.isEmpty) {
      _windowSize = MediaQuery.sizeOf(context);
    }
    const cornerRadius = Radius.circular(10);
    return SafeArea(
      child: Material(
        borderRadius: const BorderRadius.only(
          topLeft: cornerRadius,
          topRight: cornerRadius,
        ),
        elevation: 20,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: cornerRadius,
              topRight: cornerRadius,
            ),
            color: Color(0xffd0d0d0),
          ),
          width: MediaQuery.sizeOf(context).width,
          height: _fullScreen
              ? _windowSize.height
              : widget.minimalHeight + _dragBarHeight + toolBarHeight,
          child: Column(
            children: [
              Container(
                height: _dragBarHeight,
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        widget.closeAction?.call();
                      },
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(0xffff5a52),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        widget.maximalAction?.call();
                        setState(() {
                          _fullScreen = !_fullScreen;
                        });
                      },
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: _fullScreen
                            ? const Color(0xffe6c029)
                            : const Color(0xff53c22b),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) =>
                            _dragCallback(details),
                        onVerticalDragEnd: _dragEnd,
                        child: Container(
                          height: _dragBarHeight,
                          color: const Color(0xffd0d0d0),
                          child: const Center(
                            child: Text(
                              'Friflex dev plugins',
                              style: TextStyle(
                                color: Color(0xff575757),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: _fullScreen
                    ? _windowSize.height -
                        _dragBarHeight -
                        toolBarHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom
                    : widget.minimalHeight,
                child: widget.contentWidget,
              ),
              if (widget.toolbarActions != null &&
                  widget.toolbarActions!.isNotEmpty)
                Container(
                  alignment: Alignment.centerLeft,
                  height: _toolBarHeight,
                  child: SingleChildScrollView(
                    // padding: const EdgeInsets.only(left: 80),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: widget.toolbarActions!.map((tuple) {
                        final title = tuple.$1;
                        final widget = tuple.$2;
                        final action = tuple.$3;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6, right: 6),
                          child: GestureDetector(
                            onTap: action,
                            child: Row(
                              children: [
                                widget,
                                Text(title),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
