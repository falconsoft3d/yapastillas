import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/toma_provider.dart';
import '../providers/medicamento_provider.dart';
import '../providers/familiar_provider.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _familiarSeleccionado;

  @override
  Widget build(BuildContext context) {
    final tomaProvider = Provider.of<TomaProvider>(context);
    final medicamentoProvider = Provider.of<MedicamentoProvider>(context);
    final familiarProvider = Provider.of<FamiliarProvider>(context);
    
    final familiares = familiarProvider.familiares;
    final tomasDelDia = tomaProvider.getTomasPorFecha(_selectedDay);
    
    // Filtrar tomas por familiar si está seleccionado
    final tomasFiltradas = _familiarSeleccionado == null
        ? tomasDelDia
        : tomasDelDia.where((toma) {
            final medicamento = medicamentoProvider.getMedicamentoById(toma.medicamentoId);
            return medicamento?.familiarId == _familiarSeleccionado;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
      ),
      body: Column(
        children: [
          // Selector de contacto
          if (familiares.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: _familiarSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Filtrar por contacto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  suffixIcon: _familiarSeleccionado != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _familiarSeleccionado = null;
                            });
                          },
                        )
                      : null,
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Todos los contactos'),
                  ),
                  ...familiares.map((familiar) {
                    return DropdownMenuItem<String>(
                      value: familiar.id,
                      child: Text(familiar.nombreCompleto),
                    );
                  }).toList(),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _familiarSeleccionado = newValue;
                  });
                },
              ),
            ),
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  DateFormat('EEEE, d MMMM').format(_selectedDay),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${tomasFiltradas.length} tomas',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tomasFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay tomas programadas',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tomasFiltradas.length,
                    itemBuilder: (context, index) {
                      final toma = tomasFiltradas[index];
                      final medicamento = medicamentoProvider
                          .getMedicamentoById(toma.medicamentoId);
                      final hora =
                          DateFormat.Hm().format(toma.fechaHoraProgramada);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: toma.tomada
                                  ? Colors.green.withOpacity(0.1)
                                  : toma.omitida
                                      ? Colors.red.withOpacity(0.1)
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              toma.tomada
                                  ? Icons.check_circle
                                  : toma.omitida
                                      ? Icons.cancel
                                      : Icons.medication,
                              color: toma.tomada
                                  ? Colors.green
                                  : toma.omitida
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            medicamento?.nombre ?? 'Medicamento',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${medicamento?.dosis ?? ''} - $hora',
                          ),
                          trailing: !toma.tomada && !toma.omitida
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      color: Colors.green,
                                      onPressed: () {
                                        tomaProvider.registrarToma(toma.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      color: Colors.red,
                                      onPressed: () {
                                        tomaProvider.omitirToma(toma.id);
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
