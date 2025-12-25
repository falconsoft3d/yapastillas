import 'package:uuid/uuid.dart';

class Toma {
  final String id;
  final String medicamentoId;
  final DateTime fechaHoraProgramada;
  final DateTime? fechaHoraReal;
  final bool tomada;
  final String? notas;
  final bool omitida;

  Toma({
    String? id,
    required this.medicamentoId,
    required this.fechaHoraProgramada,
    this.fechaHoraReal,
    this.tomada = false,
    this.notas,
    this.omitida = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicamentoId': medicamentoId,
      'fechaHoraProgramada': fechaHoraProgramada.toIso8601String(),
      'fechaHoraReal': fechaHoraReal?.toIso8601String(),
      'tomada': tomada ? 1 : 0,
      'notas': notas,
      'omitida': omitida ? 1 : 0,
    };
  }

  factory Toma.fromMap(Map<String, dynamic> map) {
    return Toma(
      id: map['id'],
      medicamentoId: map['medicamentoId'],
      fechaHoraProgramada: DateTime.parse(map['fechaHoraProgramada']),
      fechaHoraReal: map['fechaHoraReal'] != null 
          ? DateTime.parse(map['fechaHoraReal']) 
          : null,
      tomada: map['tomada'] == 1,
      notas: map['notas'],
      omitida: map['omitida'] == 1,
    );
  }

  Toma copyWith({
    DateTime? fechaHoraProgramada,
    DateTime? fechaHoraReal,
    bool? tomada,
    String? notas,
    bool? omitida,
  }) {
    return Toma(
      id: id,
      medicamentoId: medicamentoId,
      fechaHoraProgramada: fechaHoraProgramada ?? this.fechaHoraProgramada,
      fechaHoraReal: fechaHoraReal ?? this.fechaHoraReal,
      tomada: tomada ?? this.tomada,
      notas: notas ?? this.notas,
      omitida: omitida ?? this.omitida,
    );
  }
}
