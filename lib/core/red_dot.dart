// ignore_for_file: library_private_types_in_public_api
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:friflex_dev_plugins/core/pluggable_message_service.dart';
import 'package:friflex_dev_plugins/core/pluggable.dart';

class RedDot extends StatefulWidget {
  const RedDot({Key? key, required this.pluginDatas, this.size = 16})
      : super(key: key);

  final List<Pluggable?> pluginDatas;
  final double size;

  @override
  _RedDotState createState() => _RedDotState();
}

class _RedDotState extends State<RedDot> {
  int _count = 0;

  StreamSubscription? _subscription;
  @override
  void initState() {
    super.initState();
    _subscription =
        PluggableMessageService().messageStreamController.stream.listen((data) {
      if (mounted &&
          widget.pluginDatas.any((element) => element!.name == data.key)) {
        _refresh();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refresh();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  _refresh() {
    setState(() {
      _count = PluggableMessageService().countAll(widget.pluginDatas);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) {
      return const SizedBox.shrink();
    }
    return Container(
      height: widget.size,
      decoration: ShapeDecoration(
          color: Colors.red,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.size * 0.5)))),
      child: Padding(
        padding: EdgeInsets.only(
            left: widget.size * 0.28, right: widget.size * 0.28),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            _count.toString(),
            style: TextStyle(color: Colors.white, fontSize: widget.size * 0.8),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
