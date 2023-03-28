import 'dart:math';
import 'dart:ui';

import 'package:animated_rail/animated_rail/animated_rail.dart';

import 'rail_tile.dart';
import 'interpolate.dart';
import 'package:flutter/material.dart';
import 'point_painter.dart';
import 'rail_item.dart';

typedef ItemBuilder = Widget Function(
    BuildContext context, int index, RailItem item, bool selected);

class AnimatedRailRaw extends StatefulWidget {
  /// current layout constraints required to position and calculate multiple animation values
  final BoxConstraints constraints;

  /// on any tab clicked  , called whenever a tab is clicked not tab change
  /// use [onChange] for tab change callback
  final ValueChanged<int>? onTap;

  /// the width of the rail when it is opened default to 100
  final double width;

  /// the max width the rail will snap to, active when [expand] is equal true
  final double maxWidth;

  /// direction of rail if it is on the right or left
  final TextDirection? direction;

  /// the tabs of the rail as a list of object type [RailItem]
  final List<RailItem> items;

  /// current selected Index dont use it unlessa you want to change the tabs programmatically
  final int? selectedIndex;

  /// background of the rail
  final Color? background;

  /// if true the the rail can exapnd and reach [maxWidth] and the animation for text will take effect default true
  final bool expand;

  /// if true the rail will not move vertically default to false
  final bool isStatic;

  /// on tab index changed
  final ValueChanged<int>? onChange;

  /// custom builder for each item
  final ItemBuilder? builder;

  /// dragable cursor size for the rail
  final Size? cursorSize;

  /// config for rail tile
  final RailTileConfig? railTileConfig;

  /// the type of cursor action to use
  /// default to [CursorActionType.drag] only
  final CursorActionTrigger cursorActionType;

  const AnimatedRailRaw({
    Key? key,
    this.constraints = const BoxConstraints(),
    this.width = 100,
    this.maxWidth = 350,
    this.direction,
    this.items = const [],
    this.selectedIndex,
    this.background,
    this.onTap,
    this.expand = true,
    this.isStatic = false,
    this.onChange,
    this.builder,
    this.cursorSize,
    this.railTileConfig,
    this.cursorActionType = CursorActionTrigger.drag,
  }) : super(key: key);

  @override
  _AnimatedRailRawState createState() => _AnimatedRailRawState();
}

class _AnimatedRailRawState extends State<AnimatedRailRaw>
    with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;
  late Animation<double> _cursorAnimation;
  late AnimationController _cursorAnimationController;
  ValueNotifier<double> animationNotifier = ValueNotifier(0);
  late double width;
  double translateY = 0;
  double? velocity;
  ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);
  late InterpolateConfig config;
  final GlobalKey _railKey = GlobalKey();
  final GlobalKey _containerKey = GlobalKey();

  late TextDirection? direction;
  @override
  void initState() {
    super.initState();
    width = widget.width;
    direction = widget.direction;
    var index = widget.selectedIndex;
    if (index != null) {
      selectedIndexNotifier.value =
          index > (widget.items.length - 1) ? 0 : index;
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
      lerpDouble(widget.width, widget.maxWidth, 0.5)!,
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
    return points.firstWhere((p) => (point - p).abs() == minDelta);
  }

  void _runAnimation() {
    _animation = _controller.drive(
      Tween<double>(
        begin: width,
        end: snapPoint(width, velocity ?? 0.0,
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
    animationNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedRailRaw oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      if (oldWidget.direction != widget.direction) {
        // width = widget.width;
        direction = widget.direction;
      }
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
    var index = widget.selectedIndex;
    if (index != null) {
      selectedIndexNotifier.value =
          index > (widget.items.length - 1) ? 0 : index;
    }
    if (selectedIndexNotifier.value >= widget.items.length) {
      selectedIndexNotifier.value = 0;
    }
    config = InterpolateConfig([
      widget.width,
      lerpDouble(widget.width, widget.maxWidth, 0.5)!,
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
    var translateX = width.clamp(0, widget.width) - widget.width;
    var direction = widget.direction ?? Directionality.of(context);
    return Positioned(
      left: direction == TextDirection.ltr ? 0 : null,
      right: direction == TextDirection.ltr ? null : 0,
      width: width.clamp(widget.width, double.infinity) + 30,
      key: _containerKey,
      child: Transform.translate(
        offset: Offset(translateX, translateY),
        child: Row(
          key: _railKey,
          mainAxisSize: MainAxisSize.max,
          children: direction == TextDirection.rtl
              ? content.reversed.toList()
              : content,
        ),
      ),
    );
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    var direction = widget.direction ?? Directionality.of(context);
    setState(() {
      if (direction == TextDirection.ltr) {
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
    var direction = widget.direction ?? Directionality.of(context);
    if (direction == TextDirection.ltr) {
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

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    if (widget.isStatic) {
      return;
    }
    var getBox = _railKey.currentContext?.findRenderObject() as RenderBox?;
    var pos = getBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    double? parentSize;
    Element? parentElement;
    Offset global = Offset.zero;
    _containerKey.currentContext?.visitAncestorElements((element) {
      parentSize = element.size?.height;
      var traverse = parentElement?.widget is! AnimatedRail;
      if (!traverse) {
        global = (parentElement?.renderObject as RenderBox?)
                ?.localToGlobal(Offset.zero) ??
            Offset.zero;
      } else {
        parentElement = element;
      }
      return traverse;
    });
    parentElement = null;
    var max = global.dy + (parentSize ?? 0);
    var height = (getBox?.size.height ?? 0);
    if ((pos.dy + d.delta.dy) + height > max && d.delta.dy > 0) {
      return;
    }
    if ((pos.dy + d.delta.dy) < global.dy && d.delta.dy < 0) {
      return;
    }
    setState(() {
      translateY += d.delta.dy;
    });
  }

  List<Widget> _buildContent(BoxConstraints constraints) {
    var theme = Theme.of(context);
    var direction = widget.direction ?? Directionality.of(context);
    return [
      GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onHorizontalDragStart: _onHorizontalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: (d) {
          _stopCursorAnimation();
        },
        child: PhysicalModel(
          color: Colors.black,
          elevation: 10.0,
          borderRadius: BorderRadiusDirectional.horizontal(
            end: Radius.circular(20),
          ).resolve(direction),
          child: ClipRRect(
            borderRadius: BorderRadiusDirectional.horizontal(
              end: Radius.circular(20),
            ).resolve(direction),
            child: Container(
                constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                width: width.clamp(widget.width, double.infinity),
                decoration: BoxDecoration(
                  color: widget.background ?? theme.primaryColor,
                ),
                child: _buildTiles(widget.items, theme)),
          ),
        ),
      ),
      Flexible(
        child: GestureDetector(
          onTap: () {
            if (widget.cursorActionType == CursorActionTrigger.clickAndDrag) {
              if (width <= 0.1) {
                velocity = widget.width * 5;
                _runAnimation();
              } else if (width == widget.width) {
                velocity = -widget.width * 5;
                _runAnimation();
              } else if (width == widget.maxWidth) {
                velocity = (widget.width - widget.maxWidth) * 5;
                _runAnimation();
              }
            }
          },
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          onHorizontalDragStart: _onHorizontalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
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
              height: widget.cursorSize?.height ?? 100,
              width: widget.cursorSize?.width ?? 100,
              child: RotatedBox(
                quarterTurns: direction == TextDirection.rtl ? 2 : 0,
                child: ValueListenableBuilder(
                    valueListenable: animationNotifier,
                    builder: (cx, double value, _) => CustomPaint(
                            painter: PointerPainter(
                          pointerHeight: widget.cursorSize?.height ?? 100,
                          animation: value,
                          color: widget.background ?? theme.primaryColor,
                          arrowTintColor: widget.railTileConfig?.activeColor ??
                              theme.secondaryHeaderColor,
                        ))),
              )),
        ),
      ),
    ];
  }

  Widget _buildTiles(List<RailItem> items, ThemeData theme) {
    var direction = widget.direction ?? Directionality.of(context);
    var percentage = widget.expand ? interpolate(width, config) : 0.0;

    return ValueListenableBuilder<int>(
        valueListenable: selectedIndexNotifier,
        builder: (context, currentSelectedIndex, _) {
          return ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: items.asMap().entries.map((entry) {
              var item = entry.value;
              var index = entry.key;
              if (widget.builder != null) {
                return widget.builder!(
                    context, index, item, currentSelectedIndex == index);
              }
              return RailTile(
                widthPercentage: percentage,
                direction: direction,
                icon: item.icon,
                backgroundColor: (item.background ??
                    widget.railTileConfig?.iconBackground ??
                    theme.textSelectionTheme.selectionColor),
                iconColor: currentSelectedIndex == index
                    ? (item.activeColor ??
                        widget.railTileConfig?.activeColor ??
                        theme.primaryColor)
                    : (item.iconColor ??
                        widget.railTileConfig?.iconColor ??
                        theme.textTheme.headline1?.color ??
                        Colors.black),
                onTap: () {
                  widget.onTap?.call(index);
                  if (currentSelectedIndex == index) return;
                  widget.onChange?.call(index);
                  selectedIndexNotifier.value = index;
                },
                label: item.label,
                collapsedTextStyle: widget.railTileConfig?.collapsedTextStyle,
                expandedTextStyle: widget.railTileConfig?.expandedTextStyle,
                iconSize: widget.railTileConfig?.iconSize,
                minWidth: widget.width,
                iconPadding: widget.railTileConfig?.iconPadding,
                hideCollapsedText:
                    widget.railTileConfig?.hideCollapsedText ?? false,
              );
            }).toList(),
          );
        });
  }
}
