import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/platform_model.dart';

abstract class FinancialHistoryRepositoryInterface {
  
  Future<List<FinancialHistoryModel>> getAll();

  Future<FinancialHistoryModel?> getById(String id);

  Future<void> insert(FinancialHistoryModel model);

  Future<void> update(FinancialHistoryModel model);

  Future<void> deleteById(String id);

  Future<List<FinancialHistoryPlatformModel>>
  getPlatformLinksByFinancialHistoryId(String financialHistoryId);

  Future<void> deletePlatformLinksByFinancialHistoryId(
    String financialHistoryId,
  );

  Future<void> insertPlatformLink(FinancialHistoryPlatformModel model);

  Future<void> updatePlatformLink(FinancialHistoryPlatformModel model);
  
  Future<void> deletePlatformLink(String id);

  Future<PlatformModel?> getPlatformById(String id);

  Future<List<PlatformModel>> getAllPlatforms();

  Future<void> insertPlatform(PlatformModel model);

  /// Renomeia uma plataforma existente do catálogo (tabela `platform`).
  Future<void> updatePlatformName(String id, String name);

  /// Soft delete do catálogo: marca a plataforma como inativa (`is_active = 0`).
  ///
  /// Escolha deliberada em vez de `DELETE` físico: preserva a integridade dos
  /// reports antigos que referenciam a plataforma (FK não é apagada) e apenas
  /// a deixa de oferecer em novos reports (os filtros de catálogo já leem
  /// `is_active`).
  Future<void> deactivatePlatform(String id);
}

