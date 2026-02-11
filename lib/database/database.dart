import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

class TransactionData extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  IntColumn get category => integer()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [TransactionData])
class AppDatabase extends _$AppDatabase {
  AppDatabase.connect(super.e);

  factory AppDatabase() {
    return AppDatabase.connect(_nativeConnection());
  }

  @override
  int get schemaVersion => 1;
}

QueryExecutor _nativeConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'bookkeeping.db'));
    return NativeDatabase(file);
  });
}
