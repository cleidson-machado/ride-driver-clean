import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;

/// Versão do schema do banco.
///
/// POC: em vez de migrações incrementais, quando o schema (DDL de
/// [createSchema]) mudar basta **incrementar [schemaVersion]**. O
/// `onUpgrade`/`onDowngrade` descarta o banco antigo (drop de todas as
/// tabelas) e o recria do zero — como não há dados reais a preservar.
const int schemaVersion = 1;

/// Abre o banco SQLite da aplicação (uma única vez — singleton lazy).
///
/// POC: o schema completo é criado no `onCreate` (banco novo) e, quando a
/// versão muda (schema evoluído), `onUpgrade`/`onDowngrade` **regeram** o
/// banco a partir de [createSchema] (drop + recreate). Não há migrações
/// incrementais — por não haver usuários em produção nem dados a preservar.
Future<sqflite.Database> openAppDatabase() {
  return _dbFuture ??= _open();
}

Future<sqflite.Database>? _dbFuture;

Future<sqflite.Database> _open() async {
  final String path = p.join(await sqflite.getDatabasesPath(), 'app.db');
  return sqflite.openDatabase(
    path,
    options: sqflite.OpenDatabaseOptions(
      version: schemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await createSchema(db);
      },
      onUpgrade: _recreateSchema,
      onDowngrade: _recreateSchema,
    ),
  );
}

/// Estratégia "recriar" da POC: descarta o banco antigo e regera o schema.
Future<void> _recreateSchema(
  sqflite.Database db,
  int oldVersion,
  int newVersion,
) async {
  await _dropAllTables(db);
  await createSchema(db);
}

/// Remove todas as tabelas conhecidas (ordem segura para as FKs).
Future<void> _dropAllTables(sqflite.Database db) async {
  await db.execute('DROP TABLE IF EXISTS `financial_history_platform`');
  await db.execute('DROP TABLE IF EXISTS `financial_history`');
  await db.execute('DROP TABLE IF EXISTS `platform`');
}

/// Define o schema completo do banco (única fonte de verdade do DDL).
Future<void> createSchema(sqflite.Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS `financial_history` (
      `id` TEXT NOT NULL, `work_date` INTEGER NOT NULL,
      `trip_number` TEXT NOT NULL, `fuel_cost` REAL NOT NULL,
      `km_start` INTEGER NOT NULL, `km_end` INTEGER NOT NULL,
      `km_odometer` INTEGER NOT NULL, `notes` TEXT NOT NULL,
      `hodo2_is_zero` INTEGER NOT NULL DEFAULT 1,
      `has_images` INTEGER NOT NULL DEFAULT 0,
      `is_finished` INTEGER NOT NULL DEFAULT 0,
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
  await db.execute(
    'CREATE INDEX IF NOT EXISTS `idx_fhp_financial_history_id` '
    'ON `financial_history_platform` (`financial_history_id`)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS `idx_fhp_platform_id` '
    'ON `financial_history_platform` (`platform_id`)',
  );
}

