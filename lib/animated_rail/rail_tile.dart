import 'package:flutter/material.dart';

class RailTile extends StatelessWidget {
  final TextDirection direction;
  final void Function()? onTap;
  final Color? backgroundColor;
  final Widget icon;
  final Color? iconColor;
  final String? label;
  final TextStyle? expandedTextStyle;
  final TextStyle? collapsedTextStyle;
  final double? iconSize;
  final double minWidth;
  final double widthPercentage;
  const RailTile({
    Key? key,
    required this.direction,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.backgroundColor,
    this.label,
    this.collapsedTextStyle,
    this.expandedTextStyle,
    this.iconSize,
    required this.minWidth,
    required this.widthPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(widthPercentage);
    return TextButton(
      style: TextButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.all(0),
          minimumSize: Size(100, 100) // foreground
          ),
      onPressed: () {
        onTap?.call();
      },
      child: Container(
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: minWidth,
              // height: 100,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        // height: 100,
                        constraints: BoxConstraints(minHeight: 60),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.only(bottom: 5),
                        child: IconTheme(
                          child: icon,
                          data: IconThemeData(
                              color: iconColor, size: iconSize ?? 35),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, widthPercentage * -25),
                      child: Opacity(
                        opacity: 1 - widthPercentage,
                        child: Text(
                          label ?? '',
                          style: collapsedTextStyle?.merge(TextStyle(
                                  fontSize: collapsedTextStyle?.fontSize ?? 15,
                                  color: collapsedTextStyle?.color ??
                                      iconColor)) ??
                              TextStyle(
                                color: iconColor,
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
                opacity: widthPercentage,
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Center(
                    child: Text(
                      label ?? '',
                      style: expandedTextStyle?.merge(TextStyle(
                              fontSize: expandedTextStyle?.fontSize ?? 30,
                              color: expandedTextStyle?.color ?? iconColor)) ??
                          TextStyle(fontSize: 30, color: iconColor),
                    ),
                  ),
                ),
              ),
              start: widthPercentage * minWidth,
              textDirection: direction,
            )
          ],
        ),
      ),
    );
  }
}
