import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicamento_provider.dart';
import '../providers/familiar_provider.dart';
import '../providers/horario_provider.dart';
import '../models/horario.dart';
import '../models/medicamento.dart';

class ConfiguracionTomasScreen extends StatefulWidget {
  const ConfiguracionTomasScreen({super.key});

  @override
  State<ConfiguracionTomasScreen> createState() =>
      _ConfiguracionTomasScreenState();
}

class _ConfiguracionTomasScreenState extends State<ConfiguracionTomasScreen> {
  String? _familiarSeleccionado;

  @override
  Widget build(BuildContext context) {
    final medicamentoProvider = Provider.of<MedicamentoProvider>(context);
    final familiarProvider = Provider.of<FamiliarProvider>(context);
    final horarioProvider = Provider.of<HorarioProvider>(context);

    final familiares = familiarProvider.familiares;
    final medicamentos = _familiarSeleccionado == null
        ? medicamentoProvider.medicamentosActivos
        : medicamentoProvider.getMedicamentosPorFamiliar(_familiarSeleccionado!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Tomas'),
      ),
      body: Column(
        children: [
          // Selector de familiar
          if (familiares.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: _familiarSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Filtrar por familiar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Todos'),
                  ),
                  ...familiares.map((familiar) {
                    return DropdownMenuItem<String>(
                      value: familiar.id,
                      child: Text(familiar.nombreCompleto),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _familiarSeleccionado = value;
                  });
                },
              ),
            ),

          // Lista de medicamentos con sus horarios
          Expanded(
            child: medicamentos.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: medicamentos.length,
                    itemBuilder: (context, index) {
                      final medicamento = medicamentos[index];
                      final horarios = horarioProvider
                          .getHorariosPorMedicamento(medicamento.id);
                      return _buildMedicamentoCard(
                        context,
                        medicamento,
                        horarios,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentoCard(
    BuildContext context,
    Medicamento medicamento,
    List<Horario> horarios,
  ) {
    final horariosActivos = horarios.where((h) => h.activo).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.medication,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              medicamento.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(medicamento.dosis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (horariosActivos > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$horariosActivos horario${horariosActivos > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    _mostrarConfiguracionHorario(context, medicamento);
                  },
                  tooltip: 'Agregar horario',
                ),
              ],
            ),
          ),
          if (horarios.isNotEmpty)
            Column(
              children: horarios.map((horario) {
                return _buildHorarioItem(context, horario, medicamento);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHorarioItem(
    BuildContext context,
    Horario horario,
    Medicamento medicamento,
  ) {
    String descripcion = '';
    
    switch (horario.frecuencia) {
      case FrecuenciaType.diaria:
        final horas = horario.horasTomas?.join(', ') ?? '';
        descripcion = 'Diariamente a las $horas';
        break;
      case FrecuenciaType.intervalo:
        descripcion = 'Cada ${horario.intervaloHoras} horas';
        break;
      case FrecuenciaType.diasEspecificos:
        final dias = horario.diasSemana?.map((d) {
          const nombresDias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
          return nombresDias[d - 1];
        }).join(', ') ?? '';
        final horas = horario.horasTomas?.join(', ') ?? '';
        descripcion = '$dias a las $horas';
        break;
      case FrecuenciaType.segunNecesidad:
        descripcion = 'Según necesidad';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ListTile(
        leading: Icon(
          horario.activo ? Icons.schedule : Icons.schedule_outlined,
          color: horario.activo ? Colors.green : Colors.grey,
        ),
        title: Text(
          descripcion,
          style: TextStyle(
            fontSize: 14,
            color: horario.activo ? Colors.black87 : Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: horario.activo,
              onChanged: (value) {
                final provider =
                    Provider.of<HorarioProvider>(context, listen: false);
                if (value) {
                  provider.activarHorario(horario.id);
                } else {
                  provider.desactivarHorario(horario.id);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmarEliminarHorario(context, horario);
              },
            ),
          ],
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
              Icons.schedule,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay medicamentos activos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega medicamentos para configurar sus horarios de toma',
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

  void _mostrarConfiguracionHorario(BuildContext context, Medicamento medicamento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigurarHorarioScreen(medicamento: medicamento),
      ),
    );
  }

  void _confirmarEliminarHorario(BuildContext context, Horario horario) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar horario'),
          content: const Text('¿Estás seguro de que quieres eliminar este horario?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<HorarioProvider>(context, listen: false)
                    .eliminarHorario(horario.id);
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

class ConfigurarHorarioScreen extends StatefulWidget {
  final Medicamento medicamento;
  final Horario? horario;

  const ConfigurarHorarioScreen({
    super.key,
    required this.medicamento,
    this.horario,
  });

  @override
  State<ConfigurarHorarioScreen> createState() =>
      _ConfigurarHorarioScreenState();
}

class _ConfigurarHorarioScreenState extends State<ConfigurarHorarioScreen> {
  FrecuenciaType _frecuenciaSeleccionada = FrecuenciaType.diaria;
  int _intervaloHoras = 8;
  final List<int> _diasSeleccionados = [];
  final List<TimeOfDay> _horasSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    if (widget.horario != null) {
      _frecuenciaSeleccionada = widget.horario!.frecuencia;
      _intervaloHoras = widget.horario!.intervaloHoras ?? 8;
      _diasSeleccionados.addAll(widget.horario!.diasSemana ?? []);
      
      if (widget.horario!.horasTomas != null) {
        for (var horaStr in widget.horario!.horasTomas!) {
          final parts = horaStr.split(':');
          _horasSeleccionadas.add(TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Horario'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información del medicamento
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medication,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                widget.medicamento.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(widget.medicamento.dosis),
            ),
          ),
          const SizedBox(height: 24),

          // Tipo de frecuencia
          Text(
            'Frecuencia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<FrecuenciaType>(
            value: _frecuenciaSeleccionada,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.repeat),
            ),
            items: const [
              DropdownMenuItem(
                value: FrecuenciaType.diaria,
                child: Text('Diariamente'),
              ),
              DropdownMenuItem(
                value: FrecuenciaType.intervalo,
                child: Text('Cada X horas'),
              ),
              DropdownMenuItem(
                value: FrecuenciaType.diasEspecificos,
                child: Text('Días específicos'),
              ),
              DropdownMenuItem(
                value: FrecuenciaType.segunNecesidad,
                child: Text('Según necesidad'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _frecuenciaSeleccionada = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          // Configuración según tipo de frecuencia
          if (_frecuenciaSeleccionada == FrecuenciaType.intervalo)
            _buildIntervaloConfig(),
          if (_frecuenciaSeleccionada == FrecuenciaType.diasEspecificos)
            _buildDiasEspecificosConfig(),
          if (_frecuenciaSeleccionada == FrecuenciaType.diaria ||
              _frecuenciaSeleccionada == FrecuenciaType.diasEspecificos)
            _buildHorasConfig(),
          
          if (_frecuenciaSeleccionada != FrecuenciaType.segunNecesidad)
            const SizedBox(height: 24),

          // Botón guardar
          ElevatedButton(
            onPressed: _guardarHorario,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Guardar Horario'),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervaloConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intervalo de horas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
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
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_intervaloHoras h',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiasEspecificosConfig() {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Días de la semana',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final diaNumero = index + 1;
            final seleccionado = _diasSeleccionados.contains(diaNumero);
            
            return FilterChip(
              label: Text(dias[index]),
              selected: seleccionado,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _diasSeleccionados.add(diaNumero);
                  } else {
                    _diasSeleccionados.remove(diaNumero);
                  }
                  _diasSeleccionados.sort();
                });
              },
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHorasConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Horarios de toma',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () async {
                final hora = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (hora != null) {
                  setState(() {
                    _horasSeleccionadas.add(hora);
                    _horasSeleccionadas.sort((a, b) {
                      final aMinutos = a.hour * 60 + a.minute;
                      final bMinutos = b.hour * 60 + b.minute;
                      return aMinutos.compareTo(bMinutos);
                    });
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_horasSeleccionadas.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No hay horarios configurados',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _horasSeleccionadas.map((hora) {
              return Chip(
                label: Text(
                  '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
                ),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _horasSeleccionadas.remove(hora);
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  void _guardarHorario() {
    // Validaciones
    if (_frecuenciaSeleccionada == FrecuenciaType.diasEspecificos &&
        _diasSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un día')),
      );
      return;
    }

    if ((_frecuenciaSeleccionada == FrecuenciaType.diaria ||
            _frecuenciaSeleccionada == FrecuenciaType.diasEspecificos) &&
        _horasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un horario')),
      );
      return;
    }

    final horario = Horario(
      id: widget.horario?.id,
      medicamentoId: widget.medicamento.id,
      frecuencia: _frecuenciaSeleccionada,
      intervaloHoras: _frecuenciaSeleccionada == FrecuenciaType.intervalo
          ? _intervaloHoras
          : null,
      diasSemana: _frecuenciaSeleccionada == FrecuenciaType.diasEspecificos
          ? _diasSeleccionados
          : null,
      horasTomas: (_frecuenciaSeleccionada == FrecuenciaType.diaria ||
              _frecuenciaSeleccionada == FrecuenciaType.diasEspecificos)
          ? _horasSeleccionadas
              .map((h) =>
                  '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}')
              .toList()
          : null,
      activo: true,
    );

    final provider = Provider.of<HorarioProvider>(context, listen: false);
    if (widget.horario == null) {
      provider.agregarHorario(horario);
    } else {
      provider.actualizarHorario(horario);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Horario guardado correctamente')),
    );
  }
}
