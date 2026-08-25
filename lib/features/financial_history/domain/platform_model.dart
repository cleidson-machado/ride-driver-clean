import 'package:ride_driver_app_1/app/generic/base_model.dart';

/// Entidade que representa uma plataforma de corridas (catálogo).
///
/// Ex: UBER, BOLT, PARTICULAR (corridas avulsas) ou qualquer outra
/// adicionada pelo usuário via botão "+ PLATAFORMA".
///
/// Modelo de domínio puro: o mapeamento para a tabela `platform` é feito
/// pelo SQL cru no repositório (via [BaseModel.toMap]/[fromMap]).
class PlatformModel implements BaseModel {
  @override
  final String id;

  /// Nome da plataforma. Ex: "UBER", "BOLT", "PARTICULAR".
  final String name;

  /// Indica se a plataforma está ativa/disponível para novos registros.
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

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      // SQLite não tem BOOLEAN nativo: persiste como INTEGER 0/1.
      'is_active': isActive ? 1 : 0,
    };
  }
}

