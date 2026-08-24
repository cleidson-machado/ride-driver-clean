import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/features/financial_history/domain/financial_history_platform_model.dart';

@dao
abstract class FinancialHistoryPlatformDao {
  @Query(
    'SELECT * FROM financial_history_platform WHERE financial_history_id = :financialHistoryId',
  )
  Future<List<FinancialHistoryPlatformModel>> getPlatformsByFinancialHistoryId(
    String financialHistoryId,
  );

  @Query('SELECT * FROM financial_history_platform WHERE id = :id')
  Future<FinancialHistoryPlatformModel?> getFinancialHistoryPlatformById(
    String id,
  );

  @insert
  Future<void> insertFinancialHistoryPlatform(
    FinancialHistoryPlatformModel financialHistoryPlatform,
  );

  @update
  Future<void> updateFinancialHistoryPlatform(
    FinancialHistoryPlatformModel financialHistoryPlatform,
  );

  @delete
  Future<void> deleteFinancialHistoryPlatform(
    FinancialHistoryPlatformModel financialHistoryPlatform,
  );
}
