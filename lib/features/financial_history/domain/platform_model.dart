import 'package:ride_driver_app_1/app/generic/base_model.dart';

class PlatformModel implements BaseModel {

  @override
  final String id;
  final String name;
  final bool isActive;

  const PlatformModel({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  factory PlatformModel.fromMap(Map<String, dynamic> map) {
    return PlatformModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isActive: (map['is_active'] as int) == 1,
    );
  }

  PlatformModel copyWith({
    String? id,
    String? name,
    bool? isActive,
  }) {
    return PlatformModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive ? 1 : 0, 
      // SQLite não tem BOOLEAN nativo: persiste como INTEGER 0/1.
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is PlatformModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

