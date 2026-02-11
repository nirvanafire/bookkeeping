# CLAUDE.md

本文档为 Claude Code (claude.ai/code) 在此仓库中工作时提供指导。

## 常用命令

```bash
# 安装依赖
flutter pub get

# 生成 Drift 数据库类（修改 database.dart 后必需）
flutter pub run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run

# 运行测试
flutter test

# 运行单个测试文件
flutter test test/widget_test.dart

# 运行静态分析
flutter analyze

# 构建特定平台版本
flutter build apk --release        # Android
flutter build macos --release      # macOS
flutter build windows --release    # Windows
```

## 架构

**状态管理**：使用 Provider 模式，以 `TransactionProvider` 作为主要的 ChangeNotifier。它暴露交易数据，支持按月和类型筛选，并提供计算后的总额（收入、支出、余额）。

**数据库**：Drift (SQLite)，包含单一的 `TransactionData` 表。数据库存储在应用文档目录下的 `bookkeeping.db` 文件中。`database.g.dart` 文件是自动生成的，请勿手动编辑，修改 schema 后需重新生成。

**导航**：底部导航栏包含 3 个标签页（记账、统计、我的）。每个页面都是无状态组件，通过 `Consumer` 或 `Provider.of` 使用 `TransactionProvider`。

**核心模型**：
- `Transaction` - 领域模型，位于 `models/transaction.dart`
- `TransactionData` - Drift 表，位于 `database/database.dart`
- `TransactionType`（支出/收入）和 `TransactionCategory`（8 个支出类别 + 4 个收入类别）

**数据流**：页面 → TransactionProvider → AppDatabase → Drift → SQLite

**图表**：统计页面使用 `fl_chart` 库绘制饼图

## 项目结构

```
lib/
├── main.dart              # 应用入口，MultiProvider，带底部导航的 MainScreen
├── models/
│   └── transaction.dart   # 交易模型、枚举、扩展方法
├── database/
│   ├── database.dart      # Drift 配置，TransactionData 表
│   └── database.g.dart    # 自动生成（请勿编辑）
├── providers/
│   └── transaction_provider.dart  # CRUD 操作、筛选、计算值
├── screens/
│   ├── home/              # 交易列表、月度汇总
│   ├── add/               # 添加/编辑交易表单
│   ├── statistics/         # 使用 fl_chart 的图表
│   └── profile/           # 用户设置（语言、货币、数据导出）
└── widgets/
    └── transaction_card.dart  # 可复用的交易显示卡片
```

## CI/CD 工作流

```
.github/workflows/
├── build-all.yml      # 标签发布时的统一构建（workflow_call）
├── build-android.yml  # Android APK 构建（workflow_dispatch）
├── build-windows.yml  # Windows EXE 构建（workflow_dispatch）
└── build-macos.yml    # macOS DMG 构建（workflow_dispatch）
```
