import 'package:ride_driver_app_1/app/generic/base_model.dart';
/// Entidade que representa uma despesa extra avulsa (alimentação, bebidas,
/// medicamentos, etc.) decorrente do dia de trabalho como motorista.
///
/// É facultativa: ao encerrar um registro em [FinancialHistoryModel], o
/// usuário pode ou não adicionar despesas extras. Um mesmo registro diário
/// pode ter 0 ou N despesas extras associadas.
///
/// Modelo de domínio puro. Ainda **não há** feature de UI/repositório de
/// despesas extras implementada — a persistência desta entidade permanece
/// pendente (schema da tabela foi removido na simplificação da POC).
class ExtraExpensesModel implements BaseModel {
  @override
  final String id;

  /// FK opcional para o registro diário (financial_history.id).
  ///
  /// Permite `null` para que o vínculo seja estabelecido posteriormente,
  /// ou para despesas avulsas sem vínculo direto com um dia específico.
  final String? financialHistoryId;

  /// Nome/descrição da despesa. Ex: "Almoço", "Café", "Gasolina extra".
  final String description;

  /// Valor da despesa em euros.
  final double amount;

  /// Categoria opcional para agrupar despesas similares.
  /// Ex: "alimentação", "bebidas", "medicamentos", "pedágio", "outros".
  final String? category;

  /// Timestamp (epoch millis) de quando a despesa foi registrada.
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

