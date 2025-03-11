import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_theme.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double elevation;
  final Widget? leading;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double height;
  final bool centerTitle;

  const AppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.textColor,
    this.elevation = 0,
    this.leading,
    this.flexibleSpace,
    this.bottom,
    this.height = kToolbarHeight,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      elevation: elevation,
      leading: showBackButton
          ? leading ??
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: textColor ?? Colors.white,
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
          : leading,
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => bottom == null
      ? Size.fromHeight(height)
      : Size.fromHeight(height + bottom!.preferredSize.height);
}

// 带有搜索框的应用栏
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final ValueChanged<String> onSearch;
  final VoidCallback? onFilterPressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double height;

  const SearchAppBar({
    super.key,
    required this.title,
    required this.hintText,
    required this.onSearch,
    this.onFilterPressed,
    this.showBackButton = true,
    this.onBackPressed,
    this.height = kToolbarHeight + 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      child: SafeArea(
        child: Column(
          children: [
            // 标题栏
            SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: showBackButton ? TextAlign.left : TextAlign.center,
                    ),
                  ),
                  if (onFilterPressed != null)
                    IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                      ),
                      onPressed: onFilterPressed,
                    ),
                ],
              ),
            ),
            // 搜索框
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: AppTheme.textHintColor,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.secondaryColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
} 