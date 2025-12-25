import 'package:flutter/foundation.dart';
import '../models/familiar.dart';

class FamiliarProvider extends ChangeNotifier {
  final List<Familiar> _familiares = [];

  List<Familiar> get familiares => List.unmodifiable(_familiares);

  Familiar? get familiarPrincipal {
    try {
      return _familiares.firstWhere((f) => f.esPrincipal);
    } catch (e) {
      return _familiares.isNotEmpty ? _familiares.first : null;
    }
  }

  Familiar? getFamiliarById(String id) {
    try {
      return _familiares.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  void agregarFamiliar(Familiar familiar) {
    // Si es principal, desmarcar los demás
    if (familiar.esPrincipal) {
      for (var i = 0; i < _familiares.length; i++) {
        if (_familiares[i].esPrincipal) {
          _familiares[i] = _familiares[i].copyWith(esPrincipal: false);
        }
      }
    }
    _familiares.add(familiar);
    notifyListeners();
  }

  void actualizarFamiliar(Familiar familiar) {
    final index = _familiares.indexWhere((f) => f.id == familiar.id);
    if (index != -1) {
      // Si se marca como principal, desmarcar los demás
      if (familiar.esPrincipal) {
        for (var i = 0; i < _familiares.length; i++) {
          if (i != index && _familiares[i].esPrincipal) {
            _familiares[i] = _familiares[i].copyWith(esPrincipal: false);
          }
        }
      }
      _familiares[index] = familiar;
      notifyListeners();
    }
  }

  void eliminarFamiliar(String id) {
    _familiares.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  void establecerPrincipal(String id) {
    for (var i = 0; i < _familiares.length; i++) {
      _familiares[i] = _familiares[i].copyWith(
        esPrincipal: _familiares[i].id == id,
      );
    }
    notifyListeners();
  }
}
