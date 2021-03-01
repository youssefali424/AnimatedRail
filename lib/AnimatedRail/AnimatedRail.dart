import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'AnimatedRailRaw.dart';
import 'RailItem.dart';

class AnimatedRail extends StatefulWidget {
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
  final Color? activeColor;

  /// default inactive icon and text color if the [RailItem] doesn't have one
  final Color? iconColor;

  /// current selected Index dont use it unlessa you want to change the tabs programmatically
  final int? selectedIndex;

  /// background of the rail
  final Color? background;

  /// if true the the rail can exapnd and reach [maxWidth] and the animation for text will take effect default true
  final bool expand;

  /// if true the rail will not move vertically default to false
  final bool isStatic;
  const AnimatedRail(
      {Key? key,
      this.width = 100,
      this.maxWidth = 350,
      this.direction = TextDirection.ltr,
      this.items = const [],
      this.iconBackground = Colors.white,
      this.activeColor,
      this.iconColor,
      this.selectedIndex,
      this.background,
      this.expand = true,
      this.isStatic = false})
      : super(key: key);

  @override
  _AnimatedRailState createState() => _AnimatedRailState();
}

class _AnimatedRailState extends State<AnimatedRail> {
  // int selectedIndex = 0;
  ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

  @override
  void didUpdateWidget(covariant AnimatedRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    var index = widget.selectedIndex;
    if (index != null) {
      selectedIndexNotifier.value =
          index > (widget.items.length - 1) ? 0 : index;
    }
  }

  void _changeIndex(int i) {
    selectedIndexNotifier.value = i;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.card,
      child: Container(
        child: LayoutBuilder(
          builder: (cx, constraints) {
            var items = widget.items;
            return Stack(
              alignment: widget.direction == TextDirection.ltr
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              children: [
                ValueListenableBuilder(
                  valueListenable: selectedIndexNotifier,
                  builder: (cx, int? index, _) =>
                      items.isNotEmpty ? items[index ?? 0].screen : Container(),
                ),
                AnimatedRailRaw(
                  constraints: constraints,
                  items: widget.items,
                  width: widget.width,
                  activeColor: widget.activeColor,
                  iconColor: widget.iconColor,
                  background: widget.background,
                  direction: widget.direction,
                  maxWidth: widget.maxWidth,
                  selectedIndex: widget.selectedIndex,
                  iconBackground: widget.iconBackground,
                  onTap: _changeIndex,
                  expand: widget.expand,
                  isStatic: widget.isStatic,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
