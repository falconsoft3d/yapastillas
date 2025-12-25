import 'package:uuid/uuid.dart';

enum FrecuenciaType {
  diaria,
  intervalo,
  diasEspecificos,
  segunNecesidad,
}

class Horario {
  final String id;
  final String medicamentoId;
  final FrecuenciaType frecuencia;
  final int? intervaloHoras; // Para frecuencia por intervalo
  final List<int>? diasSemana; // 1=Lunes, 7=Domingo
  final List<String>? horasTomas; // HH:mm formato
  final bool activo;

  Horario({
    String? id,
    required this.medicamentoId,
    required this.frecuencia,
    this.intervaloHoras,
    this.diasSemana,
    this.horasTomas,
    this.activo = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicamentoId': medicamentoId,
      'frecuencia': frecuencia.name,
      'intervaloHoras': intervaloHoras,
      'diasSemana': diasSemana?.join(','),
      'horasTomas': horasTomas?.join(','),
      'activo': activo ? 1 : 0,
    };
  }

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'],
      medicamentoId: map['medicamentoId'],
      frecuencia: FrecuenciaType.values.firstWhere(
        (e) => e.name == map['frecuencia'],
      ),
      intervaloHoras: map['intervaloHoras'],
      diasSemana: map['diasSemana'] != null
          ? (map['diasSemana'] as String).split(',').map(int.parse).toList()
          : null,
      horasTomas: map['horasTomas'] != null
          ? (map['horasTomas'] as String).split(',')
          : null,
      activo: map['activo'] == 1,
    );
  }
}
