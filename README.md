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

### 日记功能
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

## 技术架构

IntelliMate采用Clean Architecture架构设计，将应用分为以下几层：

- **表现层(Presentation)**: 包含UI组件、页面和状态管理
- **领域层(Domain)**: 包含业务逻辑、实体和用例
- **数据层(Data)**: 包含数据源、仓库实现和模型

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

## 项目结构

```
lib/
├── app/                  # 应用核心配置
│   ├── di/               # 依赖注入
│   ├── routes/           # 路由配置
│   └── theme/            # 主题配置
├── data/                 # 数据层
│   ├── datasources/      # 数据源
│   ├── models/           # 数据模型
│   └── repositories/     # 仓库实现
├── domain/               # 领域层
│   ├── entities/         # 实体类
│   ├── repositories/     # 仓库接口
│   └── usecases/         # 用例类
└── presentation/         # 表现层
    ├── providers/        # 状态管理
    ├── screens/          # 页面
    └── widgets/          # UI组件
```

## 未来计划

- 添加云同步功能
- 实现多设备数据同步
- 添加统计和分析功能
- 支持更多自定义选项
- 添加黑暗模式
- 实现多语言支持

## 贡献指南

欢迎贡献代码、报告问题或提出新功能建议。请遵循以下步骤：

1. Fork项目
2. 创建功能分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -m 'Add some feature'`
4. 推送到分支：`git push origin feature/your-feature`
5. 提交Pull Request

## 许可证

本项目采用MIT许可证 - 详情请查看LICENSE文件
