# IntelliMate - 智能个人助手应用

IntelliMate是一款功能强大的个人助手应用，旨在帮助用户管理日常生活中的各种任务、目标、笔记和日程安排。应用采用Flutter框架开发，支持Android和iOS平台。

## 功能特点

### 目标管理
- 创建和跟踪个人目标
- 设置目标完成日期和优先级
- 查看目标完成进度
- 为目标添加详细描述和子任务

### 笔记管理
- 创建和编辑笔记
- 为笔记添加标签和分类
- 支持富文本编辑
- 搜索和筛选笔记

### 任务管理
- 创建日常任务和待办事项
- 设置任务优先级和截止日期
- 标记任务完成状态
- 查看任务完成情况统计

### 日常点滴
- 记录每日心情和活动
- 添加图片和位置信息
- 支持天气记录
- 查看历史日记

### 日程安排
- 创建和管理日程事件
- 设置提醒和重复规则
- 查看日/周/月视图
- 与系统日历集成

### 备忘录
- 快速记录想法和信息
- 设置备忘录优先级和分类
- 支持置顶重要备忘录
- 按分类筛选和搜索备忘录

### 旅行计划
- 创建和管理旅行计划
- 记录旅行目的地和日期
- 添加旅行预算和行程安排
- 查看旅行历史记录

### 财务管理
- 记录收入和支出
- 设置预算和财务目标
- 查看财务报表和统计
- 按类别分析消费习惯

### 照片管理
- 整理和分类照片
- 创建相册和收藏
- 为照片添加标签和描述
- 搜索和筛选照片

## 技术架构

IntelliMate采用Clean Architecture架构设计，将应用分为以下几层：

- **表现层(Presentation)**: 包含UI组件、页面和状态管理
- **领域层(Domain)**: 包含业务逻辑、实体和用例
- **数据层(Data)**: 包含数据源、仓库实现和模型
- **应用层(App)**: 包含应用配置、依赖注入和路由

### 主要技术栈
- Flutter框架
- Provider状态管理
- SQLite本地数据存储
- Clean Architecture架构模式
- 依赖注入(Service Locator)

## 安装和使用

### 系统要求
- Flutter 3.0.0或更高版本
- Dart 2.17.0或更高版本
- Android 5.0+或iOS 11.0+

### 安装步骤
1. 克隆仓库：`git clone https://github.com/yourusername/intellimate.git`
2. 进入项目目录：`cd intellimate`
3. 安装依赖：`flutter pub get`
4. 运行应用：`flutter run`

## 详细项目结构

```
lib/
├── app/                  # 应用核心配置
│   ├── di/               # 依赖注入
│   │   └── service_locator.dart  # 服务定位器
│   ├── routes/           # 路由配置
│   │   └── app_routes.dart       # 应用路由表
│   └── theme/            # 主题配置
│       └── app_theme.dart        # 应用主题定义
│       └── app_colors.dart       # 应用颜色定义
├── data/                 # 数据层
│   ├── datasources/      # 数据源
│   │   └── database_helper.dart  # 数据库助手
│   │   └── memo_datasource.dart  # 备忘录数据源
│   │   └── task_datasource.dart  # 任务数据源
│   │   └── goal_datasource.dart  # 目标数据源
│   │   └── note_datasource.dart  # 笔记数据源
│   │   └── daily_note_datasource.dart  # 日常点滴数据源
│   │   └── schedule_datasource.dart    # 日程数据源
│   │   └── finance_datasource.dart     # 财务数据源
│   │   └── travel_datasource.dart      # 旅行数据源
│   │   └── photo_datasource.dart       # 照片数据源
│   ├── models/           # 数据模型
│   │   └── memo_model.dart       # 备忘录模型
│   │   └── task_model.dart       # 任务模型
│   │   └── goal_model.dart       # 目标模型
│   │   └── note_model.dart       # 笔记模型
│   │   └── daily_note_model.dart # 日常点滴模型
│   │   └── schedule_model.dart   # 日程模型
│   │   └── finance_model.dart    # 财务模型
│   │   └── travel_model.dart     # 旅行模型
│   │   └── photo_model.dart      # 照片模型
│   │   └── user_model.dart       # 用户模型
│   ├── repositories/     # 仓库实现
│   │   └── memo_repository_impl.dart    # 备忘录仓库实现
│   │   └── task_repository_impl.dart    # 任务仓库实现
│   │   └── goal_repository_impl.dart    # 目标仓库实现
│   │   └── note_repository_impl.dart    # 笔记仓库实现
│   │   └── daily_note_repository_impl.dart  # 日常点滴仓库实现
│   │   └── schedule_repository_impl.dart    # 日程仓库实现
│   │   └── finance_repository_impl.dart     # 财务仓库实现
│   │   └── travel_repository_impl.dart      # 旅行仓库实现
│   │   └── photo_repository_impl.dart       # 照片仓库实现
│   │   └── user_repository_impl.dart        # 用户仓库实现
│   └── services/         # 服务实现
│       └── notification_service.dart    # 通知服务
│       └── storage_service.dart         # 存储服务
│       └── location_service.dart        # 位置服务
├── domain/               # 领域层
│   ├── entities/         # 实体类
│   │   └── memo.dart             # 备忘录实体
│   │   └── task.dart             # 任务实体
│   │   └── goal.dart             # 目标实体
│   │   └── note.dart             # 笔记实体
│   │   └── daily_note.dart       # 日常点滴实体
│   │   └── schedule.dart         # 日程实体
│   │   └── finance.dart          # 财务实体
│   │   └── travel.dart           # 旅行实体
│   │   └── photo.dart            # 照片实体
│   │   └── user.dart             # 用户实体
│   ├── repositories/     # 仓库接口
│   │   └── memo_repository.dart  # 备忘录仓库接口
│   │   └── task_repository.dart  # 任务仓库接口
│   │   └── goal_repository.dart  # 目标仓库接口
│   │   └── note_repository.dart  # 笔记仓库接口
│   │   └── daily_note_repository.dart   # 日常点滴仓库接口
│   │   └── schedule_repository.dart     # 日程仓库接口
│   │   └── finance_repository.dart      # 财务仓库接口
│   │   └── travel_repository.dart       # 旅行仓库接口
│   │   └── photo_repository.dart        # 照片仓库接口
│   │   └── user_repository.dart         # 用户仓库接口
│   └── usecases/         # 用例类
│       ├── memo/         # 备忘录用例
│       │   └── create_memo.dart         # 创建备忘录
│       │   └── update_memo.dart         # 更新备忘录
│       │   └── delete_memo.dart         # 删除备忘录
│       │   └── get_memo_by_id.dart      # 获取单个备忘录
│       │   └── get_all_memos.dart       # 获取所有备忘录
│       │   └── get_memos_by_category.dart  # 按类别获取备忘录
│       │   └── search_memos.dart        # 搜索备忘录
│       ├── task/         # 任务用例
│       ├── goal/         # 目标用例
│       ├── note/         # 笔记用例
│       ├── daily_note/   # 日常点滴用例
│       ├── schedule/     # 日程用例
│       ├── finance/      # 财务用例
│       ├── travel/       # 旅行用例
│       ├── photo/        # 照片用例
│       └── user/         # 用户用例
└── presentation/         # 表现层
    ├── providers/        # 状态管理
    │   └── memo_provider.dart    # 备忘录提供者
    │   └── task_provider.dart    # 任务提供者
    │   └── goal_provider.dart    # 目标提供者
    │   └── note_provider.dart    # 笔记提供者
    │   └── daily_note_provider.dart  # 日常点滴提供者
    │   └── schedule_provider.dart    # 日程提供者
    │   └── finance_provider.dart     # 财务提供者
    │   └── travel_provider.dart      # 旅行提供者
    │   └── photo_provider.dart       # 照片提供者
    │   └── user_provider.dart        # 用户提供者
    │   └── password_provider.dart    # 密码提供者
    ├── screens/          # 页面
    │   ├── memo/         # 备忘录页面
    │   │   └── memo_screen.dart      # 备忘录列表页面
    │   │   └── edit_memo_screen.dart # 编辑备忘录页面
    │   ├── task/         # 任务页面
    │   │   └── task_screen.dart      # 任务列表页面
    │   │   └── add_task_screen.dart  # 添加任务页面
    │   ├── goal/         # 目标页面
    │   │   └── goal_screen.dart      # 目标列表页面
    │   │   └── add_goal_screen.dart  # 添加目标页面
    │   ├── note/         # 笔记页面
    │   │   └── note_screen.dart      # 笔记列表页面
    │   │   └── write_note_screen.dart # 编写笔记页面
    │   ├── daily_note/   # 日常点滴页面
    │   │   └── daily_note_screen.dart    # 日常点滴列表页面
    │   │   └── add_daily_note_screen.dart # 添加日常点滴页面
    │   ├── schedule/     # 日程页面
    │   │   └── schedule_screen.dart      # 日程列表页面
    │   │   └── add_schedule_screen.dart  # 添加日程页面
    │   ├── finance/      # 财务页面
    │   │   └── finance_screen.dart       # 财务列表页面
    │   │   └── add_finance_screen.dart   # 添加财务记录页面
    │   ├── travel/       # 旅行页面
    │   │   └── travel_screen.dart        # 旅行列表页面
    │   │   └── travel_detail_screen.dart # 旅行详情页面
    │   ├── photo/        # 照片页面
    │   │   └── photo_gallery_screen.dart # 照片库页面
    │   │   └── album_detail_screen.dart  # 相册详情页面
    │   ├── home/         # 主页
    │   │   └── home_screen.dart          # 主页面
    │   ├── settings/     # 设置页面
    │   │   └── settings_screen.dart      # 设置页面
    │   │   └── profile_edit_screen.dart  # 个人资料编辑页面
    │   │   └── password_change_screen.dart # 密码修改页面
    │   ├── login/        # 登录页面
    │   │   └── login_screen.dart         # 登录页面
    │   ├── splash/       # 启动页面
    │   │   └── splash_screen.dart        # 启动页面
    │   └── assistant/    # 助手页面
    │       └── assistant_screen.dart     # 智能助手页面
    ├── widgets/          # UI组件
    │   └── custom_app_bar.dart           # 自定义应用栏
    │   └── app_bar_widget.dart           # 应用栏组件
    │   └── loading_indicator.dart        # 加载指示器
    │   └── empty_state_widget.dart       # 空状态组件
    │   └── error_widget.dart             # 错误组件
    │   └── custom_button.dart            # 自定义按钮
    │   └── custom_text_field.dart        # 自定义文本输入框
    │   └── date_picker_widget.dart       # 日期选择器
    │   └── time_picker_widget.dart       # 时间选择器
    │   └── category_selector.dart        # 类别选择器
    │   └── priority_selector.dart        # 优先级选择器
    └── helpers/          # 辅助类
        └── date_helper.dart              # 日期辅助类
        └── string_helper.dart            # 字符串辅助类
        └── validation_helper.dart        # 验证辅助类
        └── format_helper.dart            # 格式化辅助类
```

## 模块说明

### 备忘录模块
备忘录模块允许用户创建、编辑和管理简短的备忘信息。用户可以为备忘录设置类别，并通过类别进行筛选。备忘录支持标题、内容和类别属性，并记录创建和更新时间。

### 任务模块
任务模块用于管理用户的待办事项。用户可以创建任务，设置截止日期、优先级和状态。任务可以标记为已完成，并支持按状态和优先级筛选。

### 目标模块
目标模块帮助用户设定和跟踪长期目标。用户可以创建目标，设置目标类型（周目标、月目标、年目标）、完成日期和进度。目标可以包含子任务，并支持进度跟踪。

### 笔记模块
笔记模块提供更丰富的文本编辑功能，适合记录详细信息。用户可以创建笔记，添加标题、内容和标签。笔记支持富文本编辑，并可以通过标签进行组织和搜索。

### 日常点滴模块
日常点滴模块用于记录用户的日常生活和心情。用户可以添加文字内容、图片和位置信息。日常点滴按时间线展示，支持按日期查看历史记录。

### 日程模块
日程模块帮助用户管理时间和安排活动。用户可以创建日程事件，设置开始和结束时间、地点和提醒。日程支持日/周/月视图，并可以设置重复规则。

### 财务模块
财务模块用于记录和管理用户的收入和支出。用户可以添加财务记录，设置金额、类别和日期。财务模块提供收支统计和预算管理功能。

### 旅行模块
旅行模块帮助用户规划和记录旅行。用户可以创建旅行计划，设置目的地、日期和预算。旅行模块支持添加行程安排和旅行笔记。

### 照片模块
照片模块用于管理用户的照片。用户可以创建相册，上传和组织照片。照片可以添加标签和描述，并支持按相册和标签查看。

## 数据库设计

IntelliMate使用SQLite数据库存储用户数据。主要表结构如下：

- **memo**: 存储备忘录数据
- **task**: 存储任务数据
- **goal**: 存储目标数据
- **note**: 存储笔记数据
- **daily_note**: 存储日常点滴数据
- **schedule**: 存储日程数据
- **finance**: 存储财务数据
- **travel**: 存储旅行数据
- **photo**: 存储照片数据
- **user**: 存储用户数据

## 未来计划

- 添加云同步功能
- 实现多设备数据同步
- 添加统计和分析功能
- 支持更多自定义选项
- 添加黑暗模式
- 实现多语言支持
- 添加AI助手功能
- 优化性能和用户体验
- 添加数据导入导出功能
- 实现备份和恢复功能

## 贡献指南

欢迎贡献代码、报告问题或提出新功能建议。请遵循以下步骤：

1. Fork项目
2. 创建功能分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -m 'Add some feature'`
4. 推送到分支：`git push origin feature/your-feature`
5. 提交Pull Request

## 许可证

本项目采用MIT许可证 - 详情请查看LICENSE文件
