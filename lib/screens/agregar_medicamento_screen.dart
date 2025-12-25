import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicamento.dart';
import '../providers/medicamento_provider.dart';
import '../providers/familiar_provider.dart';

class AgregarMedicamentoScreen extends StatefulWidget {
  final Medicamento? medicamento;
  final String? familiarId;

  const AgregarMedicamentoScreen({
    super.key,
    this.medicamento,
    this.familiarId,
  });

  @override
  State<AgregarMedicamentoScreen> createState() =>
      _AgregarMedicamentoScreenState();
}

class _AgregarMedicamentoScreenState extends State<AgregarMedicamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _dosisController;
  late TextEditingController _notasController;

  String? _presentacionSeleccionada;
  String? _familiarSeleccionado;
  DateTime _fechaInicio = DateTime.now();
  DateTime? _fechaFin;
  late bool _activo;
  String _colorSeleccionado = '0xFF6366F1'; // Indigo por defecto
  String _formaSeleccionada = 'tableta';

  final List<String> _presentaciones = [
    'Tableta',
    'Cápsula',
    'Jarabe',
    'Suspensión',
    'Gotas',
    'Inyección',
    'Crema',
    'Ungüento',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.medicamento?.nombre);
    _descripcionController =
        TextEditingController(text: widget.medicamento?.descripcion);
    _dosisController = TextEditingController(text: widget.medicamento?.dosis);
    _notasController = TextEditingController(text: widget.medicamento?.notas);

    if (widget.medicamento != null) {
      _presentacionSeleccionada = widget.medicamento!.presentacion;
      _familiarSeleccionado = widget.medicamento!.familiarId;
      _fechaInicio = widget.medicamento!.fechaInicio;
      _fechaFin = widget.medicamento!.fechaFin;
      _activo = widget.medicamento!.activo;
      _colorSeleccionado = widget.medicamento!.color ?? '0xFF6366F1';
      _formaSeleccionada = widget.medicamento!.forma ?? 'tableta';
    } else {
      _activo = true;
      if (widget.familiarId != null) {
        _familiarSeleccionado = widget.familiarId;
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _dosisController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familiarProvider = Provider.of<FamiliarProvider>(context);
    final familiares = familiarProvider.familiares;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.medicamento == null ? 'Nuevo Medicamento' : 'Editar Medicamento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del medicamento *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosisController,
              decoration: const InputDecoration(
                labelText: 'Dosis *',
                hintText: 'Ej: 500mg, 1 tableta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.science),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La dosis es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _presentacionSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Presentación',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              items: _presentaciones.map((String presentacion) {
                return DropdownMenuItem<String>(
                  value: presentacion,
                  child: Text(presentacion),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _presentacionSeleccionada = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            // Selector de color
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.palette),
                        const SizedBox(width: 12),
                        const Text(
                          'Color de identificación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildColorOption('0xFF6366F1', 'Indigo'),
                        _buildColorOption('0xFFEF4444', 'Rojo'),
                        _buildColorOption('0xFF10B981', 'Verde'),
                        _buildColorOption('0xFF3B82F6', 'Azul'),
                        _buildColorOption('0xFFF59E0B', 'Amarillo'),
                        _buildColorOption('0xFF8B5CF6', 'Púrpura'),
                        _buildColorOption('0xFFEC4899', 'Rosa'),
                        _buildColorOption('0xFF14B8A6', 'Turquesa'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (familiares.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _familiarSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Asignar a familiar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: familiares.map((familiar) {
                  return DropdownMenuItem<String>(
                    value: familiar.id,
                    child: Text(familiar.nombreCompleto),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _familiarSeleccionado = newValue;
                  });
                },
              ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha de inicio'),
                subtitle: Text(
                  '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}',
                ),
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: _fechaInicio,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (fecha != null) {
                    setState(() {
                      _fechaInicio = fecha;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('Fecha de fin (opcional)'),
                subtitle: Text(
                  _fechaFin != null
                      ? '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'
                      : 'Sin fecha de fin',
                ),
                trailing: _fechaFin != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _fechaFin = null;
                          });
                        },
                      )
                    : null,
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: _fechaFin ?? _fechaInicio.add(const Duration(days: 30)),
                    firstDate: _fechaInicio,
                    lastDate: DateTime(2100),
                  );
                  if (fecha != null) {
                    setState(() {
                      _fechaFin = fecha;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Medicamento activo'),
              subtitle: const Text('Desactiva si ya no tomas este medicamento'),
              value: _activo,
              onChanged: (bool value) {
                setState(() {
                  _activo = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardarMedicamento,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(String colorHex, String nombre) {
    final isSelected = _colorSeleccionado == colorHex;
    final color = Color(int.parse(colorHex));
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _colorSeleccionado = colorHex;
        });
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 28)
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            nombre,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _guardarMedicamento() {
    if (_formKey.currentState!.validate()) {
      final medicamento = Medicamento(
        id: widget.medicamento?.id,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text.isEmpty
            ? null
            : _descripcionController.text,
        dosis: _dosisController.text,
        presentacion: _presentacionSeleccionada,
        color: _colorSeleccionado,
        forma: _formaSeleccionada,
        activo: _activo,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
        notas: _notasController.text.isEmpty ? null : _notasController.text,
        familiarId: _familiarSeleccionado,
      );

      final provider =
          Provider.of<MedicamentoProvider>(context, listen: false);

      if (widget.medicamento == null) {
        provider.agregarMedicamento(medicamento);
      } else {
        provider.actualizarMedicamento(medicamento);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.medicamento == null
                ? 'Medicamento agregado correctamente'
                : 'Medicamento actualizado correctamente',
          ),
        ),
      );
    }
  }
}
