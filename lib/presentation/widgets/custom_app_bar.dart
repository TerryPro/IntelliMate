import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';

/// 统一的应用导航栏，用于所有功能页面
class UnifiedAppBar extends StatelessWidget {
  final String title;
  final bool showHomeButton;
  final VoidCallback? onHomeTap;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final Color backgroundColor;
  final Color textColor;

  const UnifiedAppBar({
    super.key,
    required this.title,
    this.showHomeButton = true,
    this.onHomeTap,
    this.actions,
    this.showBackButton = false,
    this.onBackTap,
    this.backgroundColor = const Color(0xFF3ECABB),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showHomeButton)
                GestureDetector(
                  onTap: onHomeTap ?? () {
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.home,
                      color: textColor,
                      size: 18,
                    ),
                  ),
                ),
              if (showHomeButton)
                const SizedBox(width: 12),
              if (showBackButton)
                GestureDetector(
                  onTap: onBackTap ?? () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: textColor,
                      size: 18,
                    ),
                  ),
                ),
              if (showBackButton)
                const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (actions != null && actions!.isNotEmpty)
            Row(
              children: actions!,
            ),
        ],
      ),
    );
  }
}

/// 应用栏添加按钮
class AppBarAddButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const AppBarAddButton({
    super.key,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xFF3ECABB),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.add,
          color: iconColor,
          size: 20,
        ),
        onPressed: onTap,
      ),
    );
  }
}

/// 应用栏刷新按钮
class AppBarRefreshButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const AppBarRefreshButton({
    super.key,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.refresh,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }
}

/// 应用栏搜索按钮
class AppBarSearchButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const AppBarSearchButton({
    super.key,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.search,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }
}

/// 应用栏更多选项按钮
class AppBarMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const AppBarMoreButton({
    super.key,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_vert,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }
}

/// 管理页面的自定义导航栏
class CustomManagementAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onHomeTap;
  final VoidCallback onRefreshTap;
  final VoidCallback onAddTap;

  const CustomManagementAppBar({
    super.key,
    required this.title,
    required this.onHomeTap,
    required this.onRefreshTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF3ECABB),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onHomeTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onRefreshTap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xFF3ECABB),
                    size: 20,
                  ),
                  onPressed: onAddTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 添加/编辑页面的自定义导航栏
class CustomEditorAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBackTap;
  final VoidCallback onSaveTap;
  final bool isLoading;
  final List<Widget>? actions;

  const CustomEditorAppBar({
    super.key,
    required this.title,
    required this.onBackTap,
    required this.onSaveTap,
    this.isLoading = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF3ECABB),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBackTap,
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (actions != null) ...actions!,
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isLoading ? null : onSaveTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3ECABB),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '保存',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 