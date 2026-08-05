import 'package:floor/floor.dart';
import 'package:ride_driver_app_1/features/platform/platform_model.dart';

@dao
abstract class PlatformDao {
  @Query('SELECT * FROM platform ORDER BY name ASC')
  Future<List<PlatformModel>> getAllPlatforms();

  @Query('SELECT * FROM platform WHERE id = :id')
  Future<PlatformModel?> getPlatformById(String id);

  @insert
  Future<void> insertPlatform(PlatformModel platform);

  @update
  Future<void> updatePlatform(PlatformModel platform);

  @delete
  Future<void> deletePlatform(PlatformModel platform);
}
