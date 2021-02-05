import 'dart:math';
import 'dart:ui';

import 'interpolate.dart';
import 'package:flutter/material.dart';
import 'PointPainter.dart';
import 'RailItem.dart';

class AnimatedRailRaw extends StatefulWidget {
  /// current layout constraints required to position and calculate multiple animation values
  final BoxConstraints constraints;

  /// on tab clicked
  final ValueChanged<int> onTap;

  /// the width of the rail when it is opened default to 100
  final double width;

  /// the max width the rai will snap to, active when [exapnd] is equal true
  final double maxWidth;

  /// direction of rail if it is on the right or left
  final TextDirection direction;

  /// the tabs of the rail as a list of object type [RailItem]
  final List<RailItem> items;

  /// default icon background color if the [RailItem] doesn't have one
  final Color iconBackground;

  /// default active color for text and icon if the [RailItem] doesn't have one
  final Color activeColor;

  /// default inactive icon and text color if the [RailItem] doesn't have one
  final Color iconColor;

  /// current selected Index dont use it unlessa you want to change the tabs programmatically
  final int selectedIndex;

  /// background of the rail
  final Color background;

  /// if true the the rail can exapnd and reach [maxWidth] and the animation for text will take effect default true
  final bool expand;

  /// if true the rail will not move vertically default to false
  final bool isStatic;

  const AnimatedRailRaw(
      {Key key,
      @required this.constraints,
      this.width = 100,
      this.maxWidth = 350,
      this.direction = TextDirection.ltr,
      this.items = const [],
      this.iconBackground = Colors.white,
      this.activeColor,
      this.iconColor,
      this.selectedIndex,
      this.background,
      this.onTap,
      this.expand = true,
      this.isStatic = false})
      : super(key: key);

  @override
  _AnimatedRailRawState createState() => _AnimatedRailRawState();
}

class _AnimatedRailRawState extends State<AnimatedRailRaw>
    with TickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;
  Animation<double> _cursorAnimation;
  AnimationController _cursorAnimationController;
  ValueNotifier<double> animationNotifier = ValueNotifier(0);
  double width;
  double translateY = 0;
  double velocity;
  int selectedIndex = 0;
  InterpolateConfig config;
  final GlobalKey _railKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    width = widget.width;

    if (widget.selectedIndex != null) {
      selectedIndex = widget.selectedIndex > (widget.items.length - 1)
          ? 0
          : widget.selectedIndex;
    }

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _controller.addListener(() {
      setState(() {
        width = _animation.value;
      });
    });
    _cursorAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _cursorAnimation = _cursorAnimationController.drive(
      Tween<double>(
        begin: 0.0,
        end: 1,
      ).chain(CurveTween(curve: Curves.fastOutSlowIn)),
    );
    _cursorAnimationController.addListener(() {
      animationNotifier.value = _cursorAnimation.value;
    });
    config = InterpolateConfig([
      widget.width,
      lerpDouble(widget.width, widget.maxWidth, 0.5),
      widget.maxWidth
    ], [
      0,
      0.1,
      1
    ], extrapolate: Extrapolate.CLAMP);
  }

  double snapPoint(
    double value,
    double velocity,
    List<double> points,
  ) {
    var point = value + 0.2 * velocity;
    var deltas = points.map((p) => (point - p).abs()).toList();
    var minDelta = deltas.reduce(min);
    return points.where((p) => (point - p).abs() == minDelta).toList()[0];
  }

  void _runAnimation() {
    _animation = _controller.drive(
      Tween<double>(
        begin: width,
        end: snapPoint(width, velocity,
            [.1, widget.width, if (widget.expand) widget.maxWidth]),
      ).chain(CurveTween(curve: Curves.easeInToLinear)),
    );
    _controller.reset();
    _controller.forward();
  }

  void _runCursorAnimation() {
    if (_cursorAnimationController.isAnimating) return;
    _cursorAnimationController.forward();
  }

  void _stopCursorAnimation() {
    _cursorAnimationController.stop();
    _cursorAnimationController.reverse();
  }

  @override
  void dispose() {
    _cursorAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedRailRaw oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      if (width == oldWidget.width) {
        width = widget.width;
      } else if (width == oldWidget.maxWidth) {
        if (widget.expand) {
          width = widget.maxWidth;
        } else {
          width = widget.width;
        }
      } else {
        width = 0;
      }
    }
    if (widget.selectedIndex != null) {
      selectedIndex = (widget.selectedIndex ?? 0) > (widget.items.length - 1)
          ? 0
          : widget.selectedIndex;
    }
    config = InterpolateConfig([
      widget.width,
      lerpDouble(widget.width, widget.maxWidth, 0.5),
      widget.maxWidth
    ], [
      0,
      0.1,
      1
    ], extrapolate: Extrapolate.CLAMP);
  }

  @override
  Widget build(BuildContext context) {
    var content = _buildContent(widget.constraints);
    return Positioned(
      left: widget.direction == TextDirection.ltr ? 0 : null,
      right: widget.direction == TextDirection.ltr ? null : 0,
      width: width + 30,
      child: Transform.translate(
        offset: Offset(0.0, translateY),
        child: Row(
          key: _railKey,
          mainAxisSize: MainAxisSize.max,
          children: widget.direction == TextDirection.rtl
              ? content.reversed.toList()
              : content,
        ),
      ),
    );
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    setState(() {
      if (widget.direction == TextDirection.ltr) {
        if (width + d.delta.dx > widget.width && !widget.expand) {
          return;
        }
        if (width + d.delta.dx >= 0) width += d.delta.dx;
      } else {
        if (width - d.delta.dx > widget.width && !widget.expand) {
          return;
        }
        if (width - d.delta.dx >= 0) width -= d.delta.dx;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    if (widget.direction == TextDirection.ltr) {
      velocity = d.velocity.pixelsPerSecond.dx;
    } else {
      velocity = -d.velocity.pixelsPerSecond.dx;
    }
    _runAnimation();
    _stopCursorAnimation();
  }

  void _onHorizontalDragStart(_) {
    _controller.stop();
    _runCursorAnimation();
  }

  void _onVerticalDragUpdate(
      DragUpdateDetails d, double maxHeight, double height) {
    if (widget.isStatic) {
      return;
    }
    RenderBox getBox = _railKey?.currentContext?.findRenderObject();
    var pos = getBox.localToGlobal(Offset.zero);
    var max = MediaQuery.of(context).size.height;
    if ((pos.dy + d.delta.dy) + height > max && d.delta.dy > 0) {
      return;
    }
    if ((pos.dy + d.delta.dy) <= 10 && d.delta.dy < 0) {
      return;
    }
    setState(() {
      translateY += d.delta.dy;
    });
  }

  List<Widget> _buildContent(BoxConstraints constraints) {
    var height = widget.items.length * 100.0;
    var maxHeight = min(constraints.maxHeight, height);
    var theme = Theme.of(context);
    return [
      GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onHorizontalDragStart: _onHorizontalDragStart,
        onVerticalDragUpdate: (d) =>
            _onVerticalDragUpdate(d, constraints.maxHeight, maxHeight),
        onVerticalDragEnd: (d) {
          _stopCursorAnimation();
        },
        child: PhysicalModel(
          color: Colors.black,
          elevation: 10.0,
          borderRadius: BorderRadiusDirectional.horizontal(
            end: Radius.circular(20),
          ).resolve(widget.direction),
          child: ClipRRect(
            borderRadius: BorderRadiusDirectional.horizontal(
              end: Radius.circular(20),
            ).resolve(widget.direction),
            child: Container(
                height: maxHeight,
                width: width,
                decoration: BoxDecoration(
                  color: widget.background ?? theme.primaryColor,
                ),
                child: maxHeight == height
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildTiles(widget.items, theme),
                      )
                    : ListView(
                        children: _buildTiles(widget.items, theme),
                      )),
          ),
        ),
      ),
      Flexible(
        child: GestureDetector(
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          onHorizontalDragStart: _onHorizontalDragStart,
          onVerticalDragUpdate: (d) =>
              _onVerticalDragUpdate(d, constraints.maxHeight, maxHeight),
          onVerticalDragEnd: (d) {
            _stopCursorAnimation();
          },
          onTapDown: (d) {
            _runCursorAnimation();
          },
          onTapUp: (d) {
            _stopCursorAnimation();
          },
          child: Container(
              height: 100,
              width: 100,
              child: RotatedBox(
                quarterTurns: widget.direction == TextDirection.rtl ? 2 : 0,
                child: ValueListenableBuilder(
                    valueListenable: animationNotifier,
                    builder: (cx, value, _) => CustomPaint(
                            painter: PointerPainter(
                          animation: value,
                          color: widget.background ?? theme.primaryColor,
                          arrowTintColor: widget.activeColor,
                        ))),
              )),
        ),
      ),
    ];
  }

  List<Widget> _buildTiles(List<RailItem> items, ThemeData theme) {
    var list = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      list.add(_buildTile(item, i, theme));
    }
    return list;
  }

  Widget _buildTile(RailItem item, int i, ThemeData theme) {
    var value = widget.expand ? interpolate(width, config) : 0.0;
    return FlatButton(
      onPressed: () {
        widget.onTap?.call(i);
        if (selectedIndex == i) return;
        setState(() {
          selectedIndex = i;
        });
      },
      height: 100,
      minWidth: 100,
      padding: const EdgeInsets.all(0),
      child: Container(
        width: double.infinity,
        child: Stack(
          // overflow: Overflow.visible,
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: (item.background ??
                              widget.iconBackground ??
                              theme.textSelectionColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.only(bottom: 5),
                        child: IconTheme(
                          child: item.icon,
                          data: IconThemeData(
                              color: selectedIndex == i
                                  ? (item.activeColor ??
                                      widget.activeColor ??
                                      theme.primaryColor)
                                  : (item.iconColor ??
                                      widget.iconColor ??
                                      theme.textTheme?.headline1?.color ??
                                      Colors.black),
                              size: 35),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, value * -25),
                      child: Opacity(
                        opacity: 1 - value,
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: selectedIndex == i
                                ? (item.activeColor ??
                                    widget.activeColor ??
                                    theme.primaryColor)
                                : (item.iconColor ??
                                    widget.iconColor ??
                                    theme.textTheme?.headline1?.color ??
                                    Colors.black),
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned.directional(
              child: Opacity(
                opacity: value,
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Center(
                    child: Text(
                      item.label,
                      style: TextStyle(
                          fontSize: 30,
                          color: selectedIndex == i
                              ? (item.activeColor ??
                                  widget.activeColor ??
                                  theme.primaryColor)
                              : (item.iconColor ??
                                  widget.iconColor ??
                                  theme.textTheme?.headline1?.color ??
                                  Colors.black)),
                    ),
                  ),
                ),
              ),
              start: value * 100,
              textDirection: widget.direction,
            )
          ],
        ),
      ),
    );
  }
}
