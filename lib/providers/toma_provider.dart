import 'package:flutter/foundation.dart';
import '../models/toma.dart';

class TomaProvider extends ChangeNotifier {
  final List<Toma> _tomas = [];

  List<Toma> get tomas => List.unmodifiable(_tomas);

  List<Toma> get tomasPendientes =>
      _tomas.where((t) => !t.tomada && !t.omitida).toList();

  List<Toma> get tomasHoy {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final manana = hoy.add(const Duration(days: 1));

    return _tomas.where((t) {
      return t.fechaHoraProgramada.isAfter(hoy) &&
          t.fechaHoraProgramada.isBefore(manana);
    }).toList();
  }

  Toma? getTomaById(String id) {
    try {
      return _tomas.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  void agregarToma(Toma toma) {
    _tomas.add(toma);
    notifyListeners();
  }

  void registrarToma(String id, {String? notas}) {
    final index = _tomas.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tomas[index] = _tomas[index].copyWith(
        tomada: true,
        fechaHoraReal: DateTime.now(),
        notas: notas,
      );
      notifyListeners();
    }
  }

  void omitirToma(String id, {String? notas}) {
    final index = _tomas.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tomas[index] = _tomas[index].copyWith(
        omitida: true,
        notas: notas,
      );
      notifyListeners();
    }
  }

  void actualizarToma(Toma toma) {
    final index = _tomas.indexWhere((t) => t.id == toma.id);
    if (index != -1) {
      _tomas[index] = toma;
      notifyListeners();
    }
  }

  void eliminarToma(String id) {
    _tomas.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  List<Toma> getTomasPorMedicamento(String medicamentoId) {
    return _tomas.where((t) => t.medicamentoId == medicamentoId).toList();
  }

  List<Toma> getTomasPorFecha(DateTime fecha) {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));

    return _tomas.where((t) {
      return t.fechaHoraProgramada.isAfter(inicio) &&
          t.fechaHoraProgramada.isBefore(fin);
    }).toList();
  }

  double getAdherenciaHoy() {
    final tomasHoyList = tomasHoy;
    if (tomasHoyList.isEmpty) return 0;

    final tomadasOmitidas =
        tomasHoyList.where((t) => t.tomada || t.omitida).length;
    return (tomadasOmitidas / tomasHoyList.length) * 100;
  }

  Map<String, int> getEstadisticasSemana() {
    final ahora = DateTime.now();
    final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    final finSemana = inicioSemana.add(const Duration(days: 7));

    final tomasSemana = _tomas.where((t) {
      return t.fechaHoraProgramada.isAfter(inicioSemana) &&
          t.fechaHoraProgramada.isBefore(finSemana);
    });

    return {
      'total': tomasSemana.length,
      'tomadas': tomasSemana.where((t) => t.tomada).length,
      'omitidas': tomasSemana.where((t) => t.omitida).length,
      'pendientes': tomasSemana.where((t) => !t.tomada && !t.omitida).length,
    };
  }
}
