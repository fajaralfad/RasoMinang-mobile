import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? textColor;
  final double elevation;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? titleSpacing;
  final TextStyle? titleStyle;
  final Widget? flexibleSpace;
  final double? toolbarHeight;
  final bool showDivider;
  final Gradient? gradient;
  final Widget? titleWidget;
  final double? leadingWidth;
  final ShapeBorder? shape;
  final bool transparent;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.textColor,
    this.elevation = 0,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.titleSpacing,
    this.titleStyle,
    this.flexibleSpace,
    this.toolbarHeight,
    this.showDivider = false,
    this.gradient,
    this.titleWidget,
    this.leadingWidth,
    this.shape,
    this.transparent = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title:
          titleWidget ??
          Text(
            title,
            style:
                titleStyle ??
                TextStyle(
                  color: textColor ?? (isDark ? Colors.white : Colors.black87),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
          ),
      leading: _buildLeading(context),
      actions: _buildActions(),
      centerTitle: centerTitle,
      backgroundColor: _getBackgroundColor(theme),
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: titleSpacing,
      flexibleSpace: _buildFlexibleSpace(),
      toolbarHeight: toolbarHeight,
      iconTheme: IconThemeData(
        color: textColor ?? (isDark ? Colors.white : Colors.black87),
      ),
      leadingWidth: leadingWidth,
      shape:
          shape ??
          (showDivider
              ? Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  width: 0.5,
                ),
              )
              : null),
      surfaceTintColor: Colors.transparent,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!showBackButton) return null;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Kembali',
        iconSize: 20,
        padding: EdgeInsets.zero,
      ),
    );
  }

  List<Widget>? _buildActions() {
    if (actions == null) return null;

    return actions!.map((action) {
      return Container(margin: const EdgeInsets.only(right: 8), child: action);
    }).toList();
  }

  Color? _getBackgroundColor(ThemeData theme) {
    if (transparent) return Colors.transparent;
    if (gradient != null) return Colors.transparent;
    return backgroundColor ??
        theme.appBarTheme.backgroundColor ??
        theme.scaffoldBackgroundColor;
  }

  Widget? _buildFlexibleSpace() {
    if (gradient != null) {
      return Container(decoration: BoxDecoration(gradient: gradient));
    }
    return flexibleSpace;
  }
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Gradient? gradient;

  const HomeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.gradient,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomAppBar(
      title: title,
      showBackButton: false,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      gradient:
          gradient ??
          (isDark
              ? LinearGradient(
                colors: [Colors.grey.shade900, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
              : const LinearGradient(
                colors: [Color(0xFFFE8C00), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
      textColor: Colors.white,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: -0.5,
      ),
    );
  }
}

/// App Bar dengan gradient background profesional
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Gradient? gradient;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double? height;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.gradient,
    this.showBackButton = true,
    this.onBackPressed,
    this.height,
  });

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomAppBar(
      title: title,
      actions: actions,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: height ?? kToolbarHeight,
      gradient:
          gradient ??
          (isDark
              ? LinearGradient(
                colors: [Colors.grey.shade800, Colors.grey.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
              : const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
      textColor: Colors.white,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: -0.5,
      ),
    );
  }
}
