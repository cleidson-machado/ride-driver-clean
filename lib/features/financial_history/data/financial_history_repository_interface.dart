import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_model.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_model.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

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

  Future<PlatformModel?> getPlatformById(String id);

  Future<List<PlatformModel>> getAllPlatforms();

  Future<void> insertPlatform(PlatformModel model);
}
