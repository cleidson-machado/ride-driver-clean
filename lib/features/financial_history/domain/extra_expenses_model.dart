import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/app/generic/base_model.dart';
import 'financial_history_model.dart';

/// Entidade que representa uma despesa extra avulsa (alimentação, bebidas,
/// medicamentos, etc.) decorrente do dia de trabalho como motorista.
///
/// É facultativa: ao encerrar um registro em [FinancialHistoryModel], o
/// usuário pode ou não adicionar despesas extras. Um mesmo registro diário
/// pode ter 0 ou N despesas extras associadas.
///
/// Apesar de usar a annotation [floor@Entity] para documentar o schema, a
/// persistência é feita por SQL cru via repositório (padrão da feature
/// "financial_history"), nunca por DAO do Floor.
@Entity(
  tableName: 'extra_expenses',
  foreignKeys: [
    ForeignKey(
      childColumns: ['financial_history_id'],
      parentColumns: ['id'],
      entity: FinancialHistoryModel,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
  indices: [
    Index(value: ['financial_history_id']),
  ],
)
class ExtraExpensesModel implements BaseModel {
  @override
  @primaryKey
  final String id;

  /// FK opcional para o registro diário (financial_history.id).
  ///
  /// Permite `null` para que o vínculo seja estabelecido posteriormente,
  /// ou para despesas avulsas sem vínculo direto com um dia específico.
  @ColumnInfo(name: 'financial_history_id')
  final String? financialHistoryId;

  /// Nome/descrição da despesa. Ex: "Almoço", "Café", "Gasolina extra".
  final String description;

  /// Valor da despesa em euros.
  final double amount;

  /// Categoria opcional para agrupar despesas similares.
  /// Ex: "alimentação", "bebidas", "medicamentos", "pedágio", "outros".
  final String? category;

  /// Timestamp (epoch millis) de quando a despesa foi registrada.
  @ColumnInfo(name: 'created_at')
  final int createdAt;

  const ExtraExpensesModel({
    required this.id,
    this.financialHistoryId,
    required this.description,
    required this.amount,
    this.category,
    required this.createdAt,
  });

  /// Getter de conveniência: retorna a data de criação como [DateTime].
  DateTime get createdDate => DateTime.fromMillisecondsSinceEpoch(createdAt);

  factory ExtraExpensesModel.fromMap(Map<String, dynamic> map) {
    return ExtraExpensesModel(
      id: map['id'] as String,
      financialHistoryId: map['financial_history_id'] as String?,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String?,
      createdAt: map['created_at'] as int,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'financial_history_id': financialHistoryId,
      'description': description,
      'amount': amount,
      'category': category,
      'created_at': createdAt,
    };
  }

  /// Retorna uma cópia com o [financialHistoryId] preenchido.
  ExtraExpensesModel copyWith({String? financialHistoryId}) {
    return ExtraExpensesModel(
      id: id,
      financialHistoryId: financialHistoryId ?? this.financialHistoryId,
      description: description,
      amount: amount,
      category: category,
      createdAt: createdAt,
    );
  }
}
