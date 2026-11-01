import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Modal bottom sheet wrapper with solid paper background, top hairline border, and drag handle.
class NotaBottomSheet extends StatelessWidget {
  final Widget child;
  final bool showHandle;
  final EdgeInsetsGeometry padding;

  const NotaBottomSheet({
    super.key,
    required this.child,
    this.showHandle = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
  });

  /// Displays a modal bottom sheet guaranteed to have a solid Paper background,
  /// top border, drag handle, and proper safe-area padding.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    bool showHandle = true,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: AppColors.paper,
      barrierColor: AppColors.scrim,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        side: BorderSide(color: AppColors.hairline, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (ctx) => NotaBottomSheet(
        showHandle: showHandle,
        padding: padding,
        child: builder(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        side: BorderSide(color: AppColors.hairline, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHandle)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: AppColors.cardEdge,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            Flexible(
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
