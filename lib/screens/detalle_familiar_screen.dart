import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/familiar.dart';
import '../models/medicamento.dart';
import '../providers/medicamento_provider.dart';
import '../providers/toma_provider.dart';
import '../providers/horario_provider.dart';
import '../providers/familiar_provider.dart';
import '../models/familiar.dart';
import '../models/medicamento.dart';
import '../models/toma.dart';
import 'detalle_medicamento_screen.dart';
import 'agregar_medicamento_screen.dart';
import 'configurar_horario_dialog.dart';

class DetalleFamiliarScreen extends StatelessWidget {
  final Familiar familiar;

  const DetalleFamiliarScreen({
    super.key,
    required this.familiar,
  });

  @override
  Widget build(BuildContext context) {
    final medicamentoProvider = Provider.of<MedicamentoProvider>(context);
    final tomaProvider = Provider.of<TomaProvider>(context);
    final horarioProvider = Provider.of<HorarioProvider>(context);
    
    final todosMedicamentos = medicamentoProvider.getMedicamentosPorFamiliar(familiar.id);
    final medicamentos = todosMedicamentos.where((m) => m.activo).toList();
    final medicamentosActivos = medicamentos.length;
    
    // Calcular tomas totales de todos los medicamentos del familiar
    int tomasTotales = 0;
    int tomasTomadas = 0;
    
    for (var medicamento in medicamentos) {
      final tomasMedicamento = tomaProvider.getTomasPorMedicamento(medicamento.id);
      tomasTotales += tomasMedicamento.length;
      tomasTomadas += tomasMedicamento.where((t) => t.tomada).length;
    }
    
    final adherencia = tomasTotales > 0 ? (tomasTomadas / tomasTotales * 100) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Contacto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editarFamiliar(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del familiar
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
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: Text(
                      familiar.nombre.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    familiar.nombreCompleto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (familiar.relacion != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      familiar.relacion!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  if (familiar.esPrincipal) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white),
                      ),
                      child: const Text(
                        'Usuario Principal',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
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
                      'Medicamentos\nActivos',
                      medicamentosActivos.toString(),
                      Icons.medication,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Adherencia\nGeneral',
                      '${adherencia.toStringAsFixed(0)}%',
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total\nTomas',
                      tomasTotales.toString(),
                      Icons.event_available,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ),

            // Próximas tomas
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Próximas Tomas',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._getProximasTomas(medicamentos, horarioProvider),
                    ],
                  ),
                ),
              ),
            ),

            // Calendario de horas del día
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Cronograma del Día',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCalendarioHoras(context, medicamentos, horarioProvider),
                    ],
                  ),
                ),
              ),
            ),

            // Información adicional
            if (familiar.fechaNacimiento != null || familiar.notas != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        if (familiar.fechaNacimiento != null)
                          _buildInfoRow(
                            'Fecha de nacimiento',
                            '${familiar.fechaNacimiento!.day}/${familiar.fechaNacimiento!.month}/${familiar.fechaNacimiento!.year}',
                            Icons.cake,
                          ),
                        if (familiar.notas != null) ...[
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
                            familiar.notas!,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            // Lista de medicamentos
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Medicamentos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () => _mostrarSelectorMedicamentos(context, medicamentoProvider),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (medicamentos.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.medication_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No hay medicamentos asignados',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...medicamentos.map((medicamento) {
                      final tomasMedicamento = tomaProvider
                          .getTomasPorMedicamento(medicamento.id);
                      final tomadasMed = tomasMedicamento
                          .where((t) => t.tomada)
                          .length;
                      final adherenciaMed = tomasMedicamento.isEmpty
                          ? 0.0
                          : (tomadasMed / tomasMedicamento.length * 100);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleMedicamentoScreen(
                                  medicamento: medicamento,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: medicamento.activo
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
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
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert, size: 20),
                                            onSelected: (value) {
                                              if (value == 'desasignar') {
                                                _desasignarMedicamento(context, medicamento, medicamentoProvider);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'desasignar',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.remove_circle_outline, size: 18, color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Desasignar', style: TextStyle(color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
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
                                      if (tomasMedicamento.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.trending_up,
                                              size: 16,
                                              color: adherenciaMed >= 80
                                                  ? Colors.green
                                                  : adherenciaMed >= 50
                                                      ? Colors.orange
                                                      : Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Adherencia: ${adherenciaMed.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarTomaManual(context, medicamentos),
        icon: const Icon(Icons.medication_liquid),
        label: const Text('Registrar Toma'),
        tooltip: 'Registrar toma manual',
      ),
    );
  }

  List<Widget> _getProximasTomas(List<Medicamento> medicamentos, HorarioProvider horarioProvider) {
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final List<Map<String, dynamic>> proximasTomas = [];

    for (var medicamento in medicamentos) {
      final horarios = horarioProvider.getHorariosPorMedicamento(medicamento.id);
      
      for (var horario in horarios) {
        if (!horario.activo) continue;
        
        if (horario.horasTomas != null) {
          for (var horaStr in horario.horasTomas!) {
            final parts = horaStr.split(':');
            final hora = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
            
            // Calcular minutos desde medianoche
            final currentMinutes = currentTime.hour * 60 + currentTime.minute;
            final tomaMinutes = hora.hour * 60 + hora.minute;
            final diff = tomaMinutes - currentMinutes;
            
            // Mostrar las próximas 4 horas (240 minutos) o las que ya pasaron hace menos de 30 minutos
            if (diff >= -30 && diff <= 240) {
              proximasTomas.add({
                'medicamento': medicamento,
                'hora': hora,
                'diff': diff,
                'horaStr': horaStr,
              });
            }
          }
        }
      }
    }

    // Ordenar por diferencia de tiempo
    proximasTomas.sort((a, b) => a['diff'].compareTo(b['diff']));

    if (proximasTomas.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[300], size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'No hay tomas programadas en las próximas horas',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return proximasTomas.take(5).map((toma) {
      final medicamento = toma['medicamento'] as Medicamento;
      final hora = toma['hora'] as TimeOfDay;
      final diff = toma['diff'] as int;
      final horaStr = toma['horaStr'] as String;
      
      final isPast = diff < 0;
      final isNow = diff >= 0 && diff <= 30;
      
      String timeText;
      Color color;
      IconData icon;
      
      if (isPast) {
        timeText = 'Hace ${(-diff)} min';
        color = Colors.red;
        icon = Icons.alarm_off;
      } else if (isNow) {
        timeText = '¡Ahora!';
        color = Colors.orange;
        icon = Icons.alarm_on;
      } else if (diff < 60) {
        timeText = 'En $diff min';
        color = Colors.orange;
        icon = Icons.alarm;
      } else {
        final hours = diff ~/ 60;
        final minutes = diff % 60;
        timeText = 'En ${hours}h ${minutes}min';
        color = Colors.blue;
        icon = Icons.schedule;
      }

      return Builder(
        builder: (builderContext) => GestureDetector(
          onTap: () => _mostrarRegistroToma(builderContext, medicamento, horaStr),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicamento.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      medicamento.dosis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    horaStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.touch_app, color: color.withOpacity(0.5), size: 20),
            ],
          ),
        ),
        ),
      );
    }).toList();
  }

  Widget _buildCalendarioHoras(BuildContext context, List<Medicamento> medicamentos, HorarioProvider horarioProvider) {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Agrupar todas las tomas por hora
    Map<int, List<Map<String, dynamic>>> tomasPorHora = {};
    
    for (var medicamento in medicamentos) {
      final horarios = horarioProvider.getHorariosPorMedicamento(medicamento.id);
      
      for (var horario in horarios) {
        if (!horario.activo) continue;
        
        if (horario.horasTomas != null) {
          for (var horaStr in horario.horasTomas!) {
            final parts = horaStr.split(':');
            final hora = int.parse(parts[0]);
            
            if (!tomasPorHora.containsKey(hora)) {
              tomasPorHora[hora] = [];
            }
            
            tomasPorHora[hora]!.add({
              'medicamento': medicamento,
              'horaStr': horaStr,
              'minuto': int.parse(parts[1]),
            });
          }
        }
      }
    }
    
    if (tomasPorHora.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No hay tomas programadas',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }
    
    // Ordenar las horas
    final horasOrdenadas = tomasPorHora.keys.toList()..sort();
    
    return Column(
      children: horasOrdenadas.map((hora) {
        final tomas = tomasPorHora[hora]!;
        final isPast = hora < currentHour;
        final isCurrent = hora == currentHour;
        
        // Ordenar las tomas de esa hora por minuto
        tomas.sort((a, b) => a['minuto'].compareTo(b['minuto']));
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna de hora
              Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Theme.of(context).primaryColor
                      : isPast
                          ? Colors.grey[300]
                          : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent
                        ? Theme.of(context).primaryColor
                        : isPast
                            ? Colors.grey[400]!
                            : Colors.blue[200]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${hora.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isCurrent ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Actual',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Columna de medicamentos
              Expanded(
                child: Column(
                  children: tomas.map((toma) {
                    final medicamento = toma['medicamento'] as Medicamento;
                    final horaStr = toma['horaStr'] as String;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPast
                            ? Colors.grey[100]
                            : isCurrent
                                ? Colors.orange[50]
                                : Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPast
                              ? Colors.grey[300]!
                              : isCurrent
                                  ? Colors.orange[200]!
                                  : Colors.blue[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(int.parse(medicamento.color ?? '0xFF6366F1')).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.medication,
                              color: Color(int.parse(medicamento.color ?? '0xFF6366F1')),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicamento.nombre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isPast ? Colors.grey[600] : Colors.black87,
                                  ),
                                ),
                                Text(
                                  medicamento.dosis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isPast ? Colors.grey[500] : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            horaStr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isPast
                                  ? Colors.grey[500]
                                  : isCurrent
                                      ? Colors.orange[700]
                                      : Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

  void _mostrarSelectorMedicamentos(BuildContext context, MedicamentoProvider medicamentoProvider) {
    // Obtener medicamentos activos que NO están asignados a este familiar
    final medicamentosDisponibles = medicamentoProvider.medicamentosActivos
        .where((m) => m.familiarId != familiar.id)
        .toList();

    if (medicamentosDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay medicamentos disponibles para asignar'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.medication, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  const Text(
                    'Seleccionar Medicamento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: medicamentosDisponibles.length,
                itemBuilder: (context, index) {
                  final medicamento = medicamentosDisponibles[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(int.parse(medicamento.color ?? '0xFF6366F1')),
                        child: Icon(
                          _getIconoForma(medicamento.forma ?? 'tableta'),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        medicamento.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${medicamento.dosis} - ${medicamento.presentacion}'),
                          if (medicamento.descripcion != null)
                            Text(
                              medicamento.descripcion!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _asignarMedicamento(context, medicamento, medicamentoProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Asignar'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _asignarMedicamento(BuildContext context, Medicamento medicamento, MedicamentoProvider medicamentoProvider) async {
    // Validar que no esté ya asignado
    if (medicamento.familiarId == familiar.id) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este medicamento ya está asignado'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final medicamentoActualizado = medicamento.copyWith(
      familiarId: familiar.id,
    );
    
    medicamentoProvider.actualizarMedicamento(medicamentoActualizado);
    
    Navigator.pop(context);
    
    // Mostrar diálogo para configurar horarios
    final configurado = await showDialog<bool>(
      context: context,
      builder: (context) => ConfigurarHorarioDialog(
        medicamento: medicamentoActualizado,
      ),
    );
    
    if (configurado == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicamento.nombre} asignado a ${familiar.nombreCompleto}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicamento.nombre} asignado sin horarios'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  IconData _getIconoForma(String forma) {
    switch (forma.toLowerCase()) {
      case 'tableta':
      case 'comprimido':
        return Icons.medication;
      case 'cápsula':
        return Icons.medication_liquid;
      case 'jarabe':
      case 'líquido':
        return Icons.water_drop;
      case 'inyección':
        return Icons.vaccines;
      case 'crema':
      case 'ungüento':
        return Icons.healing;
      default:
        return Icons.medical_services;
    }
  }

  void _mostrarTomaManual(BuildContext context, List<Medicamento> medicamentos) {
    final medicamentoProvider = Provider.of<MedicamentoProvider>(context, listen: false);
    final todosMedicamentos = medicamentoProvider.medicamentosActivos;
    
    if (todosMedicamentos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay medicamentos disponibles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.medication_liquid, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  const Text(
                    'Registrar Toma Manual',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Selecciona el medicamento que acabas de tomar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: todosMedicamentos.length,
                itemBuilder: (context, index) {
                  final medicamento = todosMedicamentos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(int.parse(medicamento.color ?? '0xFF6366F1')),
                        child: const Icon(
                          Icons.medication,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        medicamento.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(medicamento.dosis),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _registrarTomaManual(context, medicamento);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Registrar'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _registrarTomaManual(BuildContext context, Medicamento medicamento) {
    final tomaProvider = Provider.of<TomaProvider>(context, listen: false);
    final notasController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(int.parse(medicamento.color ?? '0xFF6366F1')).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.medication,
                color: Color(int.parse(medicamento.color ?? '0xFF6366F1')),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Toma Manual',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medicamento.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                medicamento.dosis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Toma sin programación. Se registrará con la hora actual.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Ej: Por dolor de cabeza',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final now = DateTime.now();
              
              final toma = Toma(
                medicamentoId: medicamento.id,
                fechaHoraProgramada: now,
                fechaHoraReal: now,
                tomada: true,
                notas: notasController.text.isEmpty 
                    ? 'Toma manual' 
                    : 'Toma manual: ${notasController.text}',
              );
              
              tomaProvider.agregarToma(toma);
              Navigator.pop(dialogContext);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ ${medicamento.nombre} registrado'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            label: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarRegistroToma(BuildContext context, Medicamento medicamento, String hora) {
    final tomaProvider = Provider.of<TomaProvider>(context, listen: false);
    final notasController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(int.parse(medicamento.color ?? '0xFF6366F1')).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.medication,
                color: Color(int.parse(medicamento.color ?? '0xFF6366F1')),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Registrar Toma',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medicamento.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                medicamento.dosis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Hora programada: $hora',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Ej: Con comida, sin efectos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              // Crear toma como omitida
              final now = DateTime.now();
              final parts = hora.split(':');
              final fechaProgramada = DateTime(
                now.year,
                now.month,
                now.day,
                int.parse(parts[0]),
                int.parse(parts[1]),
              );
              
              final toma = Toma(
                medicamentoId: medicamento.id,
                fechaHoraProgramada: fechaProgramada,
                omitida: true,
                notas: notasController.text.isEmpty ? 'Omitida' : notasController.text,
              );
              
              tomaProvider.agregarToma(toma);
              Navigator.pop(dialogContext);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toma omitida'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.cancel, color: Colors.orange),
            label: const Text('Omitir', style: TextStyle(color: Colors.orange)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Crear y registrar toma
              final now = DateTime.now();
              final parts = hora.split(':');
              final fechaProgramada = DateTime(
                now.year,
                now.month,
                now.day,
                int.parse(parts[0]),
                int.parse(parts[1]),
              );
              
              final toma = Toma(
                medicamentoId: medicamento.id,
                fechaHoraProgramada: fechaProgramada,
                fechaHoraReal: now,
                tomada: true,
                notas: notasController.text.isEmpty ? null : notasController.text,
              );
              
              tomaProvider.agregarToma(toma);
              Navigator.pop(dialogContext);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ ${medicamento.nombre} registrado'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            label: const Text('Tomado'),
          ),
        ],
      ),
    );
  }

  void _editarFamiliar(BuildContext context) {
    final nombreController = TextEditingController(text: familiar.nombre);
    final apellidoController = TextEditingController(text: familiar.apellido);
    final relacionController = TextEditingController(text: familiar.relacion);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar Familiar'),
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
              onPressed: () => Navigator.pop(dialogContext),
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

                final familiarActualizado = familiar.copyWith(
                  nombre: nombreController.text,
                  apellido: apellidoController.text.isEmpty ? null : apellidoController.text,
                  relacion: relacionController.text.isEmpty ? null : relacionController.text,
                );

                Provider.of<FamiliarProvider>(context, listen: false)
                    .actualizarFamiliar(familiarActualizado);

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Familiar actualizado'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _desasignarMedicamento(BuildContext context, Medicamento medicamento, MedicamentoProvider medicamentoProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desasignar Medicamento'),
        content: Text('¿Deseas desasignar "${medicamento.nombre}" de ${familiar.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final medicamentoActualizado = medicamento.copyWith(
                clearFamiliarId: true,
              );
              
              medicamentoProvider.actualizarMedicamento(medicamentoActualizado);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${medicamento.nombre} desasignado'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desasignar'),
          ),
        ],
      ),
    );
  }
}
