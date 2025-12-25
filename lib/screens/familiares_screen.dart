import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/familiar_provider.dart';
import '../providers/medicamento_provider.dart';
import '../models/familiar.dart';
import 'detalle_familiar_screen.dart';

class FamiliaresScreen extends StatelessWidget {
  const FamiliaresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final familiarProvider = Provider.of<FamiliarProvider>(context);
    final medicamentoProvider = Provider.of<MedicamentoProvider>(context);
    final familiares = familiarProvider.familiares;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
      ),
      body: familiares.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: familiares.length,
              itemBuilder: (context, index) {
                final familiar = familiares[index];
                final medicamentos = medicamentoProvider
                    .getMedicamentosPorFamiliar(familiar.id);
                return _buildFamiliarCard(context, familiar, medicamentos.length);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAgregarFamiliarDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildFamiliarCard(BuildContext context, Familiar familiar, int cantidadMedicamentos) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleFamiliarScreen(familiar: familiar),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      familiar.nombre.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                familiar.nombreCompleto,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (familiar.esPrincipal)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Principal',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          familiar.relacion ?? 'Sin relación especificada',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showFamiliarOptions(context, familiar);
                    },
                  ),
                ],
              ),
              if (cantidadMedicamentos > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medication,
                        size: 20,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$cantidadMedicamentos medicamento${cantidadMedicamentos > 1 ? 's' : ''} asignado${cantidadMedicamentos > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.blue[700],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes familiares registrados',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar un familiar',
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

  void _showAgregarFamiliarDialog(BuildContext context, [Familiar? familiar]) {
    final nombreController = TextEditingController(text: familiar?.nombre);
    final apellidoController = TextEditingController(text: familiar?.apellido);
    final relacionController = TextEditingController(text: familiar?.relacion);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(familiar == null ? 'Nuevo Familiar' : 'Editar Familiar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: apellidoController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: relacionController,
                  decoration: const InputDecoration(
                    labelText: 'Relación (opcional)',
                    hintText: 'Ej: Padre, Madre, Hijo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nombreController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El nombre es requerido'),
                    ),
                  );
                  return;
                }

                final nuevoFamiliar = Familiar(
                  id: familiar?.id,
                  nombre: nombreController.text,
                  apellido: apellidoController.text.isEmpty
                      ? null
                      : apellidoController.text,
                  relacion: relacionController.text.isEmpty
                      ? null
                      : relacionController.text,
                  esPrincipal: familiar?.esPrincipal ?? false,
                );

                if (familiar == null) {
                  Provider.of<FamiliarProvider>(context, listen: false)
                      .agregarFamiliar(nuevoFamiliar);
                } else {
                  Provider.of<FamiliarProvider>(context, listen: false)
                      .actualizarFamiliar(nuevoFamiliar);
                }

                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showFamiliarOptions(BuildContext context, Familiar familiar) {
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
                  _showAgregarFamiliarDialog(context, familiar);
                },
              ),
              if (!familiar.esPrincipal)
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('Marcar como principal'),
                  onTap: () {
                    Navigator.pop(context);
                    Provider.of<FamiliarProvider>(context, listen: false)
                        .establecerPrincipal(familiar.id);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarEliminar(context, familiar);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarEliminar(BuildContext context, Familiar familiar) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar familiar'),
          content: Text(
              '¿Estás seguro de que quieres eliminar a "${familiar.nombreCompleto}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<FamiliarProvider>(context, listen: false)
                    .eliminarFamiliar(familiar.id);
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
