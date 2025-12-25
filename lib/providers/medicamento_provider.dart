import 'package:flutter/foundation.dart';
import '../models/medicamento.dart';

class MedicamentoProvider extends ChangeNotifier {
  final List<Medicamento> _medicamentos = [];

  List<Medicamento> get medicamentos => List.unmodifiable(_medicamentos);

  List<Medicamento> get medicamentosActivos =>
      _medicamentos.where((m) => m.activo).toList();

  Medicamento? getMedicamentoById(String id) {
    try {
      return _medicamentos.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  void agregarMedicamento(Medicamento medicamento) {
    _medicamentos.add(medicamento);
    notifyListeners();
  }

  void actualizarMedicamento(Medicamento medicamento) {
    final index = _medicamentos.indexWhere((m) => m.id == medicamento.id);
    if (index != -1) {
      _medicamentos[index] = medicamento;
      notifyListeners();
    }
  }

  void eliminarMedicamento(String id) {
    _medicamentos.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void desactivarMedicamento(String id) {
    final medicamento = getMedicamentoById(id);
    if (medicamento != null) {
      actualizarMedicamento(medicamento.copyWith(activo: false));
    }
  }

  List<Medicamento> buscarMedicamentos(String query) {
    final lowerQuery = query.toLowerCase();
    return _medicamentos.where((m) {
      return m.nombre.toLowerCase().contains(lowerQuery) ||
          (m.descripcion?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<Medicamento> getMedicamentosPorFamiliar(String familiarId) {
    return _medicamentos.where((m) => m.familiarId == familiarId).toList();
  }
}
