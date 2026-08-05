import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:ride_driver_app_1/app/database/daos_impl.dart';
import 'package:ride_driver_app_1/features/extra_expenses/extra_expenses_dao.dart';
import 'package:ride_driver_app_1/features/financial_history/financial_history_dao.dart';
import 'package:ride_driver_app_1/features/financial_history/financial_history_platform_dao.dart';
import 'package:ride_driver_app_1/features/platform/platform_dao.dart';

/// Interface abstrata do banco de dados.
///
/// Cada DAO é acessado como getter. A implementação concreta é provida por
/// [AppDatabaseBuilder.build].
abstract class AppDatabase {
  FinancialHistoryDao get financialHistoryDao;
  FinancialHistoryPlatformDao get financialHistoryPlatformDao;
  PlatformDao get platformDao;
  ExtraExpensesDao get extraExpensesDao;

  Future<void> close();
}

/// Builder manual do [AppDatabase] usando sqflite diretamente.
///
/// Contorna uma limitação do floor_generator 1.5.x que não processa
/// a annotation `@Database` em projetos com SDK >= 3.12.0.
///
/// Exemplo:
/// ```dart
/// final db = await AppDatabaseBuilder()
///     .addMigrations([migration1to2])
///     .build();
/// ```
class AppDatabaseBuilder {
  final List<Migration> _migrations = [];
  Callback? _callback;

  AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  Future<AppDatabase> build() async {
    final path = await sqfliteDatabaseFactory.getDatabasePath('app.db');
    final database = await sqfliteDatabaseFactory.openDatabase(
      path,
      options: sqflite.OpenDatabaseOptions(
        version: 2,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
          await _callback?.onConfigure?.call(db);
        },
        onOpen: (db) async {
          await _callback?.onOpen?.call(db);
        },
        onUpgrade: (db, startVersion, endVersion) async {
          await MigrationAdapter.runMigrations(
              db, startVersion, endVersion, _migrations);
          await _callback?.onUpgrade?.call(db, startVersion, endVersion);
        },
        onCreate: (db, version) async {
          await _createTables(db);
          await _callback?.onCreate?.call(db, version);
        },
      ),
    );
    return _AppDatabase(database);
  }

  Future<void> _createTables(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS `financial_history` (
        `id` TEXT NOT NULL, `work_date` INTEGER NOT NULL,
        `trip_number` TEXT NOT NULL, `fuel_cost` REAL NOT NULL,
        `km_start` INTEGER NOT NULL, `km_end` INTEGER NOT NULL,
        `km_odometer` INTEGER NOT NULL, `notes` TEXT NOT NULL,
        PRIMARY KEY (`id`)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS `financial_history_platform` (
        `id` TEXT NOT NULL,
        `financial_history_id` TEXT NOT NULL,
        `platform_id` TEXT NOT NULL,
        `daily_earnings` REAL NOT NULL,
        `daily_trip_count` INTEGER NOT NULL,
        FOREIGN KEY (`financial_history_id`)
          REFERENCES `financial_history` (`id`)
          ON UPDATE NO ACTION ON DELETE CASCADE,
        FOREIGN KEY (`platform_id`)
          REFERENCES `platform` (`id`)
          ON UPDATE NO ACTION ON DELETE CASCADE,
        PRIMARY KEY (`id`)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS `platform` (
        `id` TEXT NOT NULL, `name` TEXT NOT NULL,
        `is_active` INTEGER NOT NULL, PRIMARY KEY (`id`)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS `extra_expenses` (
        `id` TEXT NOT NULL, `financial_history_id` TEXT,
        `description` TEXT NOT NULL, `amount` REAL NOT NULL,
        `category` TEXT, `created_at` INTEGER NOT NULL,
        FOREIGN KEY (`financial_history_id`)
          REFERENCES `financial_history` (`id`)
          ON UPDATE NO ACTION ON DELETE CASCADE,
        PRIMARY KEY (`id`)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS `idx_fhp_financial_history_id` '
      'ON `financial_history_platform` (`financial_history_id`)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS `idx_fhp_platform_id` '
      'ON `financial_history_platform` (`platform_id`)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS `idx_ee_financial_history_id` '
      'ON `extra_expenses` (`financial_history_id`)',
    );
  }
}

class _AppDatabase implements AppDatabase {
  final sqflite.Database _db;

  _AppDatabase(this._db);

  @override
  late final FinancialHistoryDao financialHistoryDao =
      FinancialHistoryDaoImpl(_db);

  @override
  late final FinancialHistoryPlatformDao financialHistoryPlatformDao =
      FinancialHistoryPlatformDaoImpl(_db);

  @override
  late final PlatformDao platformDao = PlatformDaoImpl(_db);

  @override
  late final ExtraExpensesDao extraExpensesDao = ExtraExpensesDaoImpl(_db);

  @override
  Future<void> close() => _db.close();
}

