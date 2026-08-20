import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/app/generic/base_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

/// ENTIDADE-DETALHE (associativa) — tabela `financial_history_platform`
/// (N linhas por dia).
///
/// Liga o registro-pai [FinancialHistory] a uma [PlatformModel] do catálogo:
/// cada linha guarda o faturamento e o nº de corridas de UMA plataforma em
/// UM dia (Uber, Bolt, particulares avulsas, etc.). Diferente da entidade-pai,
/// não tem lógica de domínio — só FKs e valores persistidos.
///
/// Não confundir com `FinancialHistoryPlatform` (domain/): aquela NÃO é
/// entidade — é a visão resolvida (nome + totais) usada pela UI/controller.
/// O repositório converte entre as duas ao carregar/salvar.
@Entity(
  tableName: 'financial_history_platform',
  foreignKeys: [
    ForeignKey(
      childColumns: ['financial_history_id'],
      parentColumns: ['id'],
      entity: FinancialHistory,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['platform_id'],
      parentColumns: ['id'],
      entity: PlatformModel,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
  indices: [
    Index(value: ['financial_history_id']),
    Index(value: ['platform_id']),
  ],
)
class FinancialHistoryPlatformModel implements BaseModel {
  @override
  @primaryKey
  final String id;

  /// FK para o registro diário (financial_history.id).
  @ColumnInfo(name: 'financial_history_id')
  final String financialHistoryId;

  /// FK para a plataforma (platform.id).
  @ColumnInfo(name: 'platform_id')
  final String platformId;

  /// Faturamento total do dia nessa plataforma, em euros.
  @ColumnInfo(name: 'daily_earnings')
  final double dailyEarnings;

  /// Quantidade total de corridas do dia nessa plataforma.
  @ColumnInfo(name: 'daily_trip_count')
  final int dailyTripCount;

  const FinancialHistoryPlatformModel({
    required this.id,
    required this.financialHistoryId,
    required this.platformId,
    required this.dailyEarnings,
    required this.dailyTripCount,
  });

  factory FinancialHistoryPlatformModel.fromMap(Map<String, dynamic> map) {
    return FinancialHistoryPlatformModel(
      id: map['id'] as String,
      financialHistoryId: map['financial_history_id'] as String,
      platformId: map['platform_id'] as String,
      dailyEarnings: (map['daily_earnings'] as num).toDouble(),
      dailyTripCount: map['daily_trip_count'] as int,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'financial_history_id': financialHistoryId,
      'platform_id': platformId,
      'daily_earnings': dailyEarnings,
      'daily_trip_count': dailyTripCount,
    };
  }
}
