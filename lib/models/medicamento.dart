import 'package:uuid/uuid.dart';

class Medicamento {
  final String id;
  final String nombre;
  final String? descripcion;
  final String dosis;
  final String? presentacion; // Tableta, jarabe, cápsula, etc.
  final String? color;
  final String? forma; // Redonda, ovalada, etc.
  final bool activo;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String? notas;
  final String? familiarId;

  Medicamento({
    String? id,
    required this.nombre,
    this.descripcion,
    required this.dosis,
    this.presentacion,
    this.color,
    this.forma,
    this.activo = true,
    required this.fechaInicio,
    this.fechaFin,
    this.notas,
    this.familiarId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'dosis': dosis,
      'presentacion': presentacion,
      'color': color,
      'forma': forma,
      'activo': activo ? 1 : 0,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'notas': notas,
      'familiarId': familiarId,
    };
  }

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      dosis: map['dosis'],
      presentacion: map['presentacion'],
      color: map['color'],
      forma: map['forma'],
      activo: map['activo'] == 1,
      fechaInicio: DateTime.parse(map['fechaInicio']),
      fechaFin: map['fechaFin'] != null ? DateTime.parse(map['fechaFin']) : null,
      notas: map['notas'],
      familiarId: map['familiarId'],
    );
  }

  Medicamento copyWith({
    String? nombre,
    String? descripcion,
    String? dosis,
    String? presentacion,
    String? color,
    String? forma,
    bool? activo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? notas,
    String? familiarId,
    bool clearFamiliarId = false,
  }) {
    return Medicamento(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      dosis: dosis ?? this.dosis,
      presentacion: presentacion ?? this.presentacion,
      color: color ?? this.color,
      forma: forma ?? this.forma,
      activo: activo ?? this.activo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      notas: notas ?? this.notas,
      familiarId: clearFamiliarId ? null : (familiarId ?? this.familiarId),
    );
  }
}
