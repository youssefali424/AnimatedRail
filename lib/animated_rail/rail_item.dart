import 'package:animated_rail/animated_rail/animated_rail_raw.dart';
import 'package:flutter/material.dart';

/// rail item used by the Animated rail as a tab
/// values like [background],[activeColor] and [iconColor]
/// overrides default values in the [AnimatedRailRaw]
class RailItem {
  /// tab icon to use prefered to be an [Icon]
  Widget icon;

  /// string label
  String? label;

  /// `required` screen to show when this [RailItem] is selected
  Widget screen;

  /// default icon background color
  /// overrides [AnimatedRailRaw.iconBackground]
  final Color? background;

  /// default active color for text and icon
  /// overrides [AnimatedRailRaw.activeColor]
  final Color? activeColor;

  /// default inactive icon and text color
  /// overrides [AnimatedRailRaw.iconColor]
  final Color? iconColor;

  RailItem({
    this.icon = const SizedBox(),
    this.screen = const SizedBox(),
    this.label,
    this.background,
    this.activeColor,
    this.iconColor,
  });
}

class RailTileConfig {
  final EdgeInsetsGeometry? iconPadding;

  /// style of text when the rail is expanded
  final TextStyle? expandedTextStyle;

  /// style of text when the rail is collapsed
  final TextStyle? collapsedTextStyle;

  /// icon size for each tile
  final double? iconSize;

  /// default icon background color if the [RailItem] doesn't have one
  final Color? iconBackground;

  /// default active color for text and icon if the [RailItem] doesn't have one
  final Color? activeColor;

  /// default inactive icon and text color if the [RailItem] doesn't have one
  final Color? iconColor;

  /// hide [RailItem.label] label when the rail is collapsed
  final bool? hideCollapsedText;

  const RailTileConfig({
    this.iconBackground,
    this.activeColor,
    this.iconColor,
    this.collapsedTextStyle,
    this.expandedTextStyle,
    this.iconSize,
    this.iconPadding,
    this.hideCollapsedText,
  });
}

enum CursorActionTrigger {
  ///when expanded or totally collapsed
  ///use click to toggle the rail as well as dragging
  clickAndDrag,
  ///only user dragging to toggle the rail
  drag,
}
