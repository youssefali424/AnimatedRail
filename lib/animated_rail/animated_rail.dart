import 'package:flutter/material.dart';
import 'rail_item.dart';
import 'animated_rail_raw.dart';

class AnimatedRail extends StatefulWidget {
  /// the width of the rail when it is opened default to 100
  final double width;

  /// the max width the rai will snap to, active when [expand] is equal true
  final double maxWidth;

  /// direction of rail if it is on the right or left
  final TextDirection direction;

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

  /// custom builder for each item
  final ItemBuilder? builder;

  /// dragable cursor size for the rail
  final Size? cursorSize;

  /// config for rail tile
  final RailTileConfig? railTileConfig;

  /// the type of cursor action to use
  /// default to [CursorActionType.drag] only
  final CursorActionTrigger cursorActionType;

  const AnimatedRail({
    Key? key,
    this.width = 100,
    this.maxWidth = 350,
    this.direction = TextDirection.ltr,
    this.items = const [],
    this.selectedIndex,
    this.background,
    this.expand = true,
    this.isStatic = false,
    this.builder,
    this.cursorSize,
    this.railTileConfig,
    this.cursorActionType = CursorActionTrigger.drag,
  })  : assert(expand && maxWidth > width),
        super(key: key);

  @override
  AnimatedRailState createState() => AnimatedRailState();
}

class AnimatedRailState extends State<AnimatedRail> {
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
    if (selectedIndexNotifier.value >= widget.items.length) {
      selectedIndexNotifier.value = 0;
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
                  background: widget.background,
                  direction: widget.direction,
                  maxWidth: widget.maxWidth,
                  selectedIndex: widget.selectedIndex,
                  onTap: _changeIndex,
                  expand: widget.expand,
                  isStatic: widget.isStatic,
                  railTileConfig: widget.railTileConfig,
                  builder: widget.builder,
                  cursorSize: widget.cursorSize,
                  cursorActionType: widget.cursorActionType,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
