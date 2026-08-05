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
