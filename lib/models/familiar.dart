import 'package:uuid/uuid.dart';

class Familiar {
  final String id;
  final String nombre;
  final String? apellido;
  final String? foto;
  final String? relacion; // Padre, madre, hijo, etc.
  final DateTime? fechaNacimiento;
  final String? notas;
  final bool esPrincipal;

  Familiar({
    String? id,
    required this.nombre,
    this.apellido,
    this.foto,
    this.relacion,
    this.fechaNacimiento,
    this.notas,
    this.esPrincipal = false,
  }) : id = id ?? const Uuid().v4();

  String get nombreCompleto => apellido != null ? '$nombre $apellido' : nombre;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'foto': foto,
      'relacion': relacion,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'notas': notas,
      'esPrincipal': esPrincipal ? 1 : 0,
    };
  }

  factory Familiar.fromMap(Map<String, dynamic> map) {
    return Familiar(
      id: map['id'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      foto: map['foto'],
      relacion: map['relacion'],
      fechaNacimiento: map['fechaNacimiento'] != null 
          ? DateTime.parse(map['fechaNacimiento']) 
          : null,
      notas: map['notas'],
      esPrincipal: map['esPrincipal'] == 1,
    );
  }

  Familiar copyWith({
    String? nombre,
    String? apellido,
    String? foto,
    String? relacion,
    DateTime? fechaNacimiento,
    String? notas,
    bool? esPrincipal,
  }) {
    return Familiar(
      id: id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      foto: foto ?? this.foto,
      relacion: relacion ?? this.relacion,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      notas: notas ?? this.notas,
      esPrincipal: esPrincipal ?? this.esPrincipal,
    );
  }
}
