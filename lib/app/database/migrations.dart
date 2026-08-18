import 'package:floor/floor.dart';

/// Migration de v1 para v2: adiciona a tabela [extra_expenses].
///
/// Necessária para quem já tem o banco v1 em produção com dados reais.
/// Deve ser fornecida ao builder via [addMigrations].
final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS extra_expenses (
      id TEXT NOT NULL PRIMARY KEY,
      financial_history_id TEXT,
      description TEXT NOT NULL,
      amount REAL NOT NULL,
      category TEXT,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (financial_history_id) REFERENCES financial_history (id)
        ON DELETE CASCADE
    );
  ''');

  await database.execute('''
    CREATE INDEX IF NOT EXISTS idx_extra_expenses_financial_history_id
    ON extra_expenses (financial_history_id);
  ''');
});

/// Migration de v2 para v3: adiciona flags do formulário de passeio em
/// [financial_history] (hodo2_is_zero, has_images, is_finished),
/// preservando os dados existentes via defaults.
final migration2to3 = Migration(2, 3, (database) async {
  await database.execute(
    'ALTER TABLE financial_history '
    'ADD COLUMN hodo2_is_zero INTEGER NOT NULL DEFAULT 1',
  );
  await database.execute(
    'ALTER TABLE financial_history '
    'ADD COLUMN has_images INTEGER NOT NULL DEFAULT 0',
  );
  await database.execute(
    'ALTER TABLE financial_history '
    'ADD COLUMN is_finished INTEGER NOT NULL DEFAULT 0',
  );
});
