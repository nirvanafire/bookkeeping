# Flutter 轻量级记账本

一个简洁的移动端记账应用，支持支出/收入记录、分类统计。

## 功能特性

- 记录支出和收入
- 12 种分类（餐饮、交通、购物、娱乐等）
- 按月筛选查看
- 支出/收入统计图表
- 日期排序的交易列表
- 左滑删除记录

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/
│   └── transaction.dart         # 数据模型
├── database/
│   ├── database.dart            # Drift 数据库配置
│   └── database.g.dart          # 自动生成（运行 build_runner）
├── providers/
│   └── transaction_provider.dart # 状态管理
├── screens/
│   ├── home/
│   │   └── home_screen.dart    # 首页
│   ├── add/
│   │   └── add_transaction_screen.dart  # 添加记录
│   └── statistics/
│       └── statistics_screen.dart       # 统计页面
└── widgets/
    └── transaction_card.dart    # 交易卡片组件
```

## 快速开始

1. 确保 Flutter SDK 已安装（3.0+）

2. 安装依赖并生成数据库文件：
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

3. 运行项目：
```bash
flutter run
```

## 技术栈

- **框架**: Flutter
- **数据库**: Drift (SQLite)
- **状态管理**: Provider
- **图表**: fl_chart
