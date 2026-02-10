#!/bin/bash

# Flutter 记账项目设置脚本

echo "📱 Flutter 记账本 - 项目设置"
echo "================================"

# 1. 安装依赖
echo "\n📦 正在安装依赖..."
flutter pub get

# 2. 生成 Drift 数据库文件
echo "\n🗄️ 正在生成 Drift 数据库文件..."
flutter pub run build_runner build --delete-conflicting-outputs

# 3. 运行项目
echo "\n🚀 启动项目..."
flutter run
