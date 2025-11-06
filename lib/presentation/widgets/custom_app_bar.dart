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

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.textColor,
    this.elevation = 1,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.titleSpacing,
    this.titleStyle,
    this.flexibleSpace,
    this.toolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ?? TextStyle(
          color: textColor ?? Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      leading: _buildLeading(context),
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: titleSpacing,
      flexibleSpace: flexibleSpace,
      toolbarHeight: toolbarHeight,
      iconTheme: IconThemeData(
        color: textColor ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (!showBackButton) return null;
    
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      tooltip: 'Kembali',
    );
  }
}

/// Custom App Bar dengan gradient background
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Gradient gradient;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.gradient = const LinearGradient(
      colors: [Color(0xFFFE8C00), Color(0xFFF83600)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: showBackButton ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ) : null,
      actions: actions,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

/// Custom App Bar dengan search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const SearchAppBar({
    super.key,
    required this.hintText,
    required this.onSearchChanged,
    this.onBackPressed,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    widget.onSearchChanged(value);
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: _clearSearch,
                )
              : null,
        ),
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
      ),
      actions: widget.actions,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

/// Custom App Bar dengan tab navigation
class TabbedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Tab> tabs;
  final TabController? tabController;
  final List<Widget>? actions;
  final bool showBackButton;

  const TabbedAppBar({
    super.key,
    required this.title,
    required this.tabs,
    this.tabController,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: showBackButton ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ) : null,
      actions: actions,
      bottom: TabBar(
        controller: tabController,
        tabs: tabs,
        indicatorColor: Colors.white,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Custom App Bar untuk detail screen dengan hero animation
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String heroTag;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const DetailAppBar({
    super.key,
    required this.title,
    required this.heroTag,
    this.actions,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Hero(
          tag: heroTag,
          child: const Icon(Icons.arrow_back),
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Hero(
        tag: '$heroTag-title',
        child: Material(
          color: Colors.transparent,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      actions: actions,
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }
}