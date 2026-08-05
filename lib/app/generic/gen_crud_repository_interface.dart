import 'package:ride_driver_app_1/app/generic/base_model.dart';

abstract class GenCrudRepositoryInterface<T extends BaseModel> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<bool> destroy(String id);
}