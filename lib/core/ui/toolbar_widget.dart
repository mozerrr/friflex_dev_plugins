// ignore_for_file: library_private_types_in_public_api, unused_element
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:friflex_dev_plugins/core/ui/icon_cache.dart';
import 'package:friflex_dev_plugins/core/pluggable_message_service.dart';
import 'package:friflex_dev_plugins/core/ui/panel_action_define.dart';
import 'package:friflex_dev_plugins/core/plugin_manager.dart';
import 'package:friflex_dev_plugins/core/red_dot.dart';
import 'package:friflex_dev_plugins/core/store_manager.dart';
import 'package:friflex_dev_plugins/core/pluggable.dart';
import 'package:friflex_dev_plugins/util/constants.dart';

class ToolBarWidget extends StatefulWidget {
  const ToolBarWidget(
      {super.key, this.action, this.maximalAction, this.closeAction});

  final MenuAction? action;
  final CloseAction? closeAction;
  final MaximalAction? maximalAction;

  @override
  _ToolBarWidgetState createState() => _ToolBarWidgetState();
}

const double _dragBarHeight = 32;
const double _minimalHeight = 80;

class _ToolBarWidgetState extends State<ToolBarWidget> {
  late final double _maxDy;
  double _dy = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bottomPadding = View.of(context).padding.bottom / ratio(context);
    _maxDy = windowSize(context).height -
        _minimalHeight -
        _dragBarHeight -
        bottomPadding;
    _dy = _maxDy;
  }

  void _dragEvent(DragUpdateDetails details) {
    setState(() {
      _dy += details.delta.dy;
      _dy = min(max(0, _dy), _maxDy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: _dy,
      child: _ToolBarContent(
        action: widget.action,
        dragCallback: _dragEvent,
        maximalAction: widget.maximalAction,
        closeAction: widget.closeAction,
      ),
    );
  }
}

class _ToolBarContent extends StatefulWidget {
  const _ToolBarContent({
    super.key,
    this.action,
    this.dragCallback,
    this.maximalAction,
    this.closeAction,
  });

  final MenuAction? action;
  final Function? dragCallback;
  final CloseAction? closeAction;
  final MaximalAction? maximalAction;

  @override
  __ToolBarContentState createState() => __ToolBarContentState();
}

class __ToolBarContentState extends State<_ToolBarContent> {
  final PluginStoreManager _storeManager = PluginStoreManager();

  List<Pluggable?> _dataList = [];

  @override
  void initState() {
    super.initState();
    _handleData();
  }

  _dragCallback(DragUpdateDetails details) {
    if (widget.dragCallback != null) widget.dragCallback!(details);
  }

  Future<void> _handleData() async {
    List<Pluggable?> dataList = [];
    List<String>? list = await _storeManager.fetchStorePlugins();
    if (!mounted) return;
    if (list == null || list.isEmpty) {
      dataList = PluginManager.instance.pluginsMap.values.toList();
    } else {
      for (final f in list) {
        bool contain = PluginManager.instance.pluginsMap.containsKey(f);
        if (contain) {
          dataList.add(PluginManager.instance.pluginsMap[f]);
        }
      }
      for (final key in PluginManager.instance.pluginsMap.keys) {
        if (!list.contains(key)) {
          dataList.add(PluginManager.instance.pluginsMap[key]);
        }
      }
    }
    _saveData(dataList);
    setState(() {
      _dataList = dataList;
    });
  }

  Future<void> _saveData(List<Pluggable?> data) async {
    List l = data.map((f) => f!.name).toList();
    if (l.isEmpty) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500), () {
      _storeManager.storePlugins(l as List<String>);
    });
  }

  @override
  Widget build(BuildContext context) {
    const cornerRadius = Radius.circular(10);
    return Material(
      borderRadius: const BorderRadius.only(
          topLeft: cornerRadius, topRight: cornerRadius),
      elevation: 20,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius:
              BorderRadius.only(topLeft: cornerRadius, topRight: cornerRadius),
          color: Color(0xffd0d0d0),
        ),
        width: MediaQuery.of(context).size.width,
        height: _minimalHeight + _dragBarHeight,
        child: Column(
          children: [
            Container(
              height: _dragBarHeight,
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        if (widget.closeAction != null) {
                          widget.closeAction!();
                        }
                      },
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(0xffff5a52),
                      )),
                  const SizedBox(
                    width: 8,
                  ),
                  InkWell(
                      onTap: () {
                        if (widget.maximalAction != null) {
                          widget.maximalAction!();
                        }
                      },
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(0xff53c22b),
                      )),
                  Expanded(
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) => _dragCallback(details),
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
            _PluginScrollContainer(
              dataList: _dataList,
              action: widget.action,
            ),
          ],
        ),
      ),
    );
  }
}

class _PluginScrollContainer extends StatelessWidget {
  const _PluginScrollContainer({Key? key, required this.dataList, this.action})
      : super(key: key);

  final List<Pluggable?> dataList;
  final MenuAction? action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _minimalHeight,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: dataList
              .map((data) => _MenuCell(pluginData: data, action: action))
              .toList(),
        ),
      ),
    );
  }
}

class _MenuCell extends StatelessWidget {
  const _MenuCell({super.key, this.pluginData, this.action});

  final Pluggable? pluginData;
  final MenuAction? action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        PluggableMessageService().resetCounter(pluginData!);
        action?.call(pluginData);
      },
      child: Stack(
        children: [
          Container(
            height: _minimalHeight,
            width: _minimalHeight,
            color: Colors.white,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 28,
                  width: 28,
                  child: IconCache.icon(pluggableInfo: pluginData!),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    pluginData!.name,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    maxLines: 1,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: RedDot(
              pluginDatas: [pluginData],
            ),
          ),
        ],
      ),
    );
  }
}
