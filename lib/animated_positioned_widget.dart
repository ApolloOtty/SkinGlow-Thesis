import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AnimatedPositionedWidget extends StatefulWidget {
  final double? left;
  final double? right;
  final double top;
  final double width;
  final double height;
  final String imagePath;
  final int index;

  const AnimatedPositionedWidget({
    Key? key,
    this.left,
    this.right,
    this.top = 0,
    required this.width,
    required this.height,
    required this.imagePath,
    required this.index,
  }) : super(key: key);

  @override
  _AnimatedPositionedWidgetState createState() =>
      _AnimatedPositionedWidgetState();
}

class _AnimatedPositionedWidgetState extends State<AnimatedPositionedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween<double>(begin: 200, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Timer(Duration(milliseconds: widget.index * 300), () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.left,
          right: widget.right,
          top: widget.top + _animation.value,
          width: widget.width,
          height: widget.height,
          child: child!,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.imagePath),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
