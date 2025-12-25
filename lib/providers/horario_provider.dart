import 'package:flutter/foundation.dart';
import '../models/horario.dart';

class HorarioProvider extends ChangeNotifier {
  final List<Horario> _horarios = [];

  List<Horario> get horarios => List.unmodifiable(_horarios);

  List<Horario> getHorariosPorMedicamento(String medicamentoId) {
    return _horarios.where((h) => h.medicamentoId == medicamentoId).toList();
  }

  Horario? getHorarioById(String id) {
    try {
      return _horarios.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  void agregarHorario(Horario horario) {
    _horarios.add(horario);
    notifyListeners();
  }

  void actualizarHorario(Horario horario) {
    final index = _horarios.indexWhere((h) => h.id == horario.id);
    if (index != -1) {
      _horarios[index] = horario;
      notifyListeners();
    }
  }

  void eliminarHorario(String id) {
    _horarios.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  void activarHorario(String id) {
    final horario = getHorarioById(id);
    if (horario != null && !horario.activo) {
      final index = _horarios.indexWhere((h) => h.id == id);
      if (index != -1) {
        _horarios[index] = Horario(
          id: horario.id,
          medicamentoId: horario.medicamentoId,
          frecuencia: horario.frecuencia,
          intervaloHoras: horario.intervaloHoras,
          diasSemana: horario.diasSemana,
          horasTomas: horario.horasTomas,
          activo: true,
        );
        notifyListeners();
      }
    }
  }

  void desactivarHorario(String id) {
    final horario = getHorarioById(id);
    if (horario != null && horario.activo) {
      final index = _horarios.indexWhere((h) => h.id == id);
      if (index != -1) {
        _horarios[index] = Horario(
          id: horario.id,
          medicamentoId: horario.medicamentoId,
          frecuencia: horario.frecuencia,
          intervaloHoras: horario.intervaloHoras,
          diasSemana: horario.diasSemana,
          horasTomas: horario.horasTomas,
          activo: false,
        );
        notifyListeners();
      }
    }
  }
}
