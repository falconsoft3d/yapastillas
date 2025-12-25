import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicamento.dart';
import '../models/horario.dart';
import '../providers/horario_provider.dart';
import 'package:uuid/uuid.dart';

class ConfigurarHorarioDialog extends StatefulWidget {
  final Medicamento medicamento;

  const ConfigurarHorarioDialog({
    super.key,
    required this.medicamento,
  });

  @override
  State<ConfigurarHorarioDialog> createState() => _ConfigurarHorarioDialogState();
}

class _ConfigurarHorarioDialogState extends State<ConfigurarHorarioDialog> {
  FrecuenciaType _frecuenciaSeleccionada = FrecuenciaType.diaria;
  int _intervaloHoras = 8;
  List<int> _diasSeleccionados = [];
  List<TimeOfDay> _horasSeleccionadas = [const TimeOfDay(hour: 8, minute: 0)];

  final List<String> _diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(int.parse(widget.medicamento.color ?? '0xFF6366F1')),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configurar Horario',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        widget.medicamento.nombre,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de frecuencia
                    Text(
                      'Frecuencia',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<FrecuenciaType>(
                      segments: const [
                        ButtonSegment(
                          value: FrecuenciaType.diaria,
                          label: Text('Diaria'),
                          icon: Icon(Icons.today),
                        ),
                        ButtonSegment(
                          value: FrecuenciaType.intervalo,
                          label: Text('Intervalo'),
                          icon: Icon(Icons.access_time),
                        ),
                        ButtonSegment(
                          value: FrecuenciaType.diasEspecificos,
                          label: Text('Días'),
                          icon: Icon(Icons.calendar_month),
                        ),
                      ],
                      selected: {_frecuenciaSeleccionada},
                      onSelectionChanged: (Set<FrecuenciaType> selection) {
                        setState(() {
                          _frecuenciaSeleccionada = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Configuración según tipo de frecuencia
                    if (_frecuenciaSeleccionada == FrecuenciaType.intervalo)
                      _buildIntervaloConfig(),
                    
                    if (_frecuenciaSeleccionada == FrecuenciaType.diasEspecificos)
                      _buildDiasEspecificosConfig(),
                    
                    // Horarios de toma
                    if (_frecuenciaSeleccionada != FrecuenciaType.intervalo) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Horarios de Toma',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton.icon(
                            onPressed: _agregarHorario,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agregar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._horasSeleccionadas.asMap().entries.map((entry) {
                        final index = entry.key;
                        final hora = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.schedule,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            title: Text(
                              hora.format(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _editarHorario(index),
                                ),
                                if (_horasSeleccionadas.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _eliminarHorario(index),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _guardarHorario,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervaloConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cada cuántas horas',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _intervaloHoras.toDouble(),
                min: 1,
                max: 24,
                divisions: 23,
                label: '$_intervaloHoras horas',
                onChanged: (value) {
                  setState(() {
                    _intervaloHoras = value.toInt();
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_intervaloHoras h',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiasEspecificosConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar días',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (index) {
            final isSelected = _diasSeleccionados.contains(index);
            return FilterChip(
              label: Text(_diasSemana[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _diasSeleccionados.add(index);
                  } else {
                    _diasSeleccionados.remove(index);
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
            );
          }),
        ),
      ],
    );
  }

  void _agregarHorario() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horasSeleccionadas.last,
    );
    
    if (hora != null) {
      setState(() {
        _horasSeleccionadas.add(hora);
      });
    }
  }

  void _editarHorario(int index) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horasSeleccionadas[index],
    );
    
    if (hora != null) {
      setState(() {
        _horasSeleccionadas[index] = hora;
      });
    }
  }

  void _eliminarHorario(int index) {
    setState(() {
      _horasSeleccionadas.removeAt(index);
    });
  }

  void _guardarHorario() {
    final horarioProvider = Provider.of<HorarioProvider>(context, listen: false);
    
    // Validar según tipo de frecuencia
    if (_frecuenciaSeleccionada == FrecuenciaType.diasEspecificos && _diasSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un día'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_frecuenciaSeleccionada != FrecuenciaType.intervalo && _horasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un horario de toma'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Crear horario
    final horario = Horario(
      id: const Uuid().v4(),
      medicamentoId: widget.medicamento.id,
      frecuencia: _frecuenciaSeleccionada,
      intervaloHoras: _frecuenciaSeleccionada == FrecuenciaType.intervalo ? _intervaloHoras : null,
      diasSemana: _frecuenciaSeleccionada == FrecuenciaType.diasEspecificos ? _diasSeleccionados : null,
      horasTomas: _frecuenciaSeleccionada != FrecuenciaType.intervalo
          ? _horasSeleccionadas.map((h) => '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}').toList()
          : null,
      activo: true,
    );
    
    horarioProvider.agregarHorario(horario);
    
    Navigator.pop(context, true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Horario configurado para ${widget.medicamento.nombre}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
