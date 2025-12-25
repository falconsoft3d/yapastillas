import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicamento_provider.dart';
import '../models/medicamento.dart';
import 'detalle_medicamento_screen.dart';
import 'agregar_medicamento_screen.dart';

class ListaMedicamentosScreen extends StatefulWidget {
  const ListaMedicamentosScreen({super.key});

  @override
  State<ListaMedicamentosScreen> createState() =>
      _ListaMedicamentosScreenState();
}

class _ListaMedicamentosScreenState extends State<ListaMedicamentosScreen> {
  String _searchQuery = '';
  bool _showOnlyActive = true;

  @override
  Widget build(BuildContext context) {
    final medicamentoProvider = Provider.of<MedicamentoProvider>(context);
    var medicamentos = _showOnlyActive
        ? medicamentoProvider.medicamentosActivos
        : medicamentoProvider.medicamentos;

    if (_searchQuery.isNotEmpty) {
      medicamentos = medicamentoProvider.buscarMedicamentos(_searchQuery);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicamentos'),
        actions: [
          IconButton(
            icon: Icon(_showOnlyActive
                ? Icons.visibility
                : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showOnlyActive = !_showOnlyActive;
              });
            },
            tooltip: _showOnlyActive
                ? 'Mostrar todos'
                : 'Mostrar solo activos',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar medicamento...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Lista de medicamentos
          Expanded(
            child: medicamentos.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: medicamentos.length,
                    itemBuilder: (context, index) {
                      final medicamento = medicamentos[index];
                      return _buildMedicamentoCard(context, medicamento);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarMedicamentoScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildMedicamentoCard(BuildContext context, Medicamento medicamento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetalleMedicamentoScreen(medicamento: medicamento),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del medicamento
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: medicamento.activo
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medication,
                  color: medicamento.activo
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Información del medicamento
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            medicamento.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!medicamento.activo)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Inactivo',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicamento.dosis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (medicamento.presentacion != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        medicamento.presentacion!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Botón de opciones
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showMedicamentoOptions(context, medicamento);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron medicamentos'
                  : 'No tienes medicamentos registrados',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (_searchQuery.isEmpty)
              Text(
                'Toca el botón + para agregar tu primer medicamento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMedicamentoOptions(BuildContext context, Medicamento medicamento) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgregarMedicamentoScreen(
                        medicamento: medicamento,
                      ),
                    ),
                  );
                },
              ),
              if (medicamento.activo)
                ListTile(
                  leading: const Icon(Icons.pause_circle_outline),
                  title: const Text('Desactivar'),
                  onTap: () {
                    Navigator.pop(context);
                    Provider.of<MedicamentoProvider>(context, listen: false)
                        .desactivarMedicamento(medicamento.id);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: const Text('Activar'),
                  onTap: () {
                    Navigator.pop(context);
                    Provider.of<MedicamentoProvider>(context, listen: false)
                        .actualizarMedicamento(
                            medicamento.copyWith(activo: true));
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarEliminar(context, medicamento);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarEliminar(BuildContext context, Medicamento medicamento) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar medicamento'),
          content: Text(
              '¿Estás seguro de que quieres eliminar "${medicamento.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<MedicamentoProvider>(context, listen: false)
                    .eliminarMedicamento(medicamento.id);
                Navigator.pop(context);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
