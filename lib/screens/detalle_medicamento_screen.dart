import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/medicamento.dart';
import '../providers/medicamento_provider.dart';
import '../providers/toma_provider.dart';
import 'agregar_medicamento_screen.dart';

class DetalleMedicamentoScreen extends StatelessWidget {
  final Medicamento medicamento;

  const DetalleMedicamentoScreen({
    super.key,
    required this.medicamento,
  });

  @override
  Widget build(BuildContext context) {
    final tomaProvider = Provider.of<TomaProvider>(context);
    final tomas = tomaProvider.getTomasPorMedicamento(medicamento.id);
    final tomasTomadas = tomas.where((t) => t.tomada).length;
    final tomasOmitidas = tomas.where((t) => t.omitida).length;
    final adherencia = tomas.isEmpty
        ? 0.0
        : (tomasTomadas / tomas.length * 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Medicamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.medication,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    medicamento.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (medicamento.descripcion != null && medicamento.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      medicamento.descripcion!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    medicamento.dosis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Estadísticas
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Adherencia',
                      '${adherencia.toStringAsFixed(0)}%',
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Tomadas',
                      tomasTomadas.toString(),
                      Icons.check_circle,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Omitidas',
                      tomasOmitidas.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Información detallada
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      if (medicamento.descripcion != null && medicamento.descripcion!.isNotEmpty)
                        _buildInfoRow(
                          'Descripción',
                          medicamento.descripcion!,
                          Icons.description,
                        ),
                      if (medicamento.presentacion != null)
                        _buildInfoRow(
                          'Presentación',
                          medicamento.presentacion!,
                          Icons.medical_services,
                        ),
                      _buildInfoRow(
                        'Inicio del tratamiento',
                        DateFormat.yMMMd().format(medicamento.fechaInicio),
                        Icons.calendar_today,
                      ),
                      if (medicamento.fechaFin != null)
                        _buildInfoRow(
                          'Fin del tratamiento',
                          DateFormat.yMMMd().format(medicamento.fechaFin!),
                          Icons.event_available,
                        ),
                      _buildInfoRow(
                        'Estado',
                        medicamento.activo ? 'Activo' : 'Inactivo',
                        medicamento.activo ? Icons.check_circle : Icons.cancel,
                      ),
                      if (medicamento.notas != null) ...[
                        const Divider(height: 32),
                        Text(
                          'Notas',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          medicamento.notas!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Historial de tomas recientes
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historial Reciente',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (tomas.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.history,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No hay historial de tomas',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...tomas.take(10).map((toma) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            toma.tomada
                                ? Icons.check_circle
                                : toma.omitida
                                    ? Icons.cancel
                                    : Icons.schedule,
                            color: toma.tomada
                                ? Colors.green
                                : toma.omitida
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                          title: Text(
                            DateFormat.yMMMd()
                                .format(toma.fechaHoraProgramada),
                          ),
                          subtitle: Text(
                            DateFormat.Hm().format(toma.fechaHoraProgramada),
                          ),
                          trailing: toma.tomada
                              ? Text(
                                  'Tomado',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : toma.omitida
                                  ? Text(
                                      'Omitido',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      'Pendiente',
                                      style: TextStyle(
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
