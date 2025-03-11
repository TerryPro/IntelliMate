# 颜色工具类使用说明

## 概述

为了解决Flutter中`withOpacity`方法已弃用的警告，我们创建了`AppColors`工具类，提供了预定义的透明度颜色常量和颜色工具方法。

## 使用方法

### 1. 导入颜色工具类

```dart
import 'package:intellimate/app/theme/app_colors.dart';
```

### 2. 使用预定义的颜色常量

```dart
// 使用主题色
Container(
  color: AppColors.primary,
  child: Text('主题色'),
)

// 使用带透明度的颜色
Container(
  decoration: const BoxDecoration(
    color: AppColors.whiteWithOpacity20, // 20%透明度的白色
    shape: BoxShape.circle,
  ),
  child: Icon(Icons.add),
)

// 使用阴影
BoxDecoration(
  boxShadow: const [
    BoxShadow(
      color: AppColors.blackWithOpacity05, // 5%透明度的黑色
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ],
)
```

### 3. 使用颜色工具方法

如果需要自定义透明度，可以使用`getColorWithOpacity`方法：

```dart
// 获取自定义透明度的颜色
Container(
  color: AppColors.getColorWithOpacity(Colors.blue, 0.3), // 30%透明度的蓝色
  child: Text('自定义透明度'),
)
```

## 可用的颜色常量

- **主题颜色**
  - `AppColors.primary`: 主题色 (#3ECABB)
  - `AppColors.primaryLight`: 浅色主题色 (#D5F5F2)
  - `AppColors.primaryWithOpacity10`: 10%透明度的主题色

- **基础颜色**
  - `AppColors.white`: 白色
  - `AppColors.black`: 黑色

- **透明度变体**
  - `AppColors.whiteWithOpacity20`: 20%透明度的白色
  - `AppColors.blackWithOpacity05`: 5%透明度的黑色
  - `AppColors.blackWithOpacity10`: 10%透明度的黑色
  - `AppColors.blackWithOpacity50`: 50%透明度的黑色

- **功能颜色**
  - `AppColors.error`: 错误色（红色）
  - `AppColors.success`: 成功色（绿色）
  - `AppColors.warning`: 警告色（琥珀色）
  - `AppColors.info`: 信息色（蓝色）

- **文本颜色**
  - `AppColors.textPrimary`: 主要文本色 (#333333)
  - `AppColors.textSecondary`: 次要文本色 (#666666)
  - `AppColors.textHint`: 提示文本色 (#999999)

- **背景颜色**
  - `AppColors.background`: 背景色 (#F5F5F5)
  - `AppColors.cardBackground`: 卡片背景色（白色）

## 注意事项

1. 尽量使用预定义的颜色常量，避免使用`withOpacity`方法
2. 使用`const`关键字优化性能
3. 如果需要自定义透明度，使用`getColorWithOpacity`方法 