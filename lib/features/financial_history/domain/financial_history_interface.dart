import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

/// Contrato de persistência da feature de histórico financeiro.
///
/// Concentra todas as operações de leitura/escrita do histórico financeiro,
/// seus vínculos com plataformas e o catálogo de plataformas. A
/// [FinancialHistoryService] depende apenas desta abstração — nunca de uma
/// implementação concreta (SQLite hoje, REST no futuro).
///
/// A localização nesta camada de domínio garante que nenhuma implementação
/// traga dependências de infraestrutura (ex.: `sqflite`) para este contrato.
abstract class FinancialHistoryInterface {
  // INICIO CRUD do histórico financeiro ######################################
  Future<List<FinancialHistoryModel>> getAll();

  Future<FinancialHistoryModel?> getById(String id);

  Future<void> insert(FinancialHistoryModel model);

  Future<void> update(FinancialHistoryModel model);

  Future<void> deleteById(String id);
  // FIM CRUD do histórico financeiro #########################################

  // INICIO Vínculos histórico ↔ plataforma ####################################
  Future<List<FinancialHistoryPlatformModel>>
  getPlatformLinksByFinancialHistoryId(String financialHistoryId);

  Future<void> deletePlatformLinksByFinancialHistoryId(
    String financialHistoryId,
  );

  Future<void> insertPlatformLink(FinancialHistoryPlatformModel model);
  // FIM Vínculos histórico ↔ plataforma ######################################

  // INICIO Catálogo de plataformas ############################################
  Future<PlatformModel?> getPlatformById(String id);

  Future<List<PlatformModel>> getAllPlatforms();

  Future<void> insertPlatform(PlatformModel model);
  // FIM Catálogo de plataformas ###############################################
}
