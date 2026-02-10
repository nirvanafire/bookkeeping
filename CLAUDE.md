# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Generate Drift database classes (required after modifying database.dart)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run lint analysis
flutter analyze
```

## Architecture

**State Management**: Provider pattern with `TransactionProvider` as the main ChangeNotifier. It exposes transactions, filtered by month and type, along with computed totals (income, expense, balance).

**Database**: Drift (SQLite) with a single `TransactionData` table. Database stored at `bookkeeping.db` in app's documents directory. The `database.g.dart` file is auto-generated - never edit manually, regenerate after schema changes.

**Navigation**: Bottom Navigation Bar with 3 tabs (记账/Record, 统计/Statistics, 我的/Profile). Each screen is a stateless widget that consumes `TransactionProvider` via `Consumer` or `Provider.of`.

**Key Models**:
- `Transaction` - domain model in `models/transaction.dart`
- `TransactionData` - Drift table in `database/database.dart`
- `TransactionType` (income/expense) and `TransactionCategory` (12 categories)

**Data Flow**: Screens → TransactionProvider → AppDatabase → Drift → SQLite

## Project Structure

```
lib/
├── main.dart              # App entry, MultiProvider, MainScreen with bottom nav
├── models/
│   └── transaction.dart   # Transaction model, enums
├── database/
│   ├── database.dart      # Drift config, TransactionData table
│   └── database.g.dart    # Generated (DO NOT EDIT)
├── providers/
│   └── transaction_provider.dart  # CRUD ops, filtering, computed values
├── screens/
│   ├── home/             # Transaction list, monthly summary
│   ├── add/               # Add/edit transaction form
│   ├── statistics/        # Charts with fl_chart
│   └── profile/           # User settings
└── widgets/
    └── transaction_card.dart  # Reusable transaction display card
```
