import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicamento_provider.dart';
import '../providers/toma_provider.dart';
import '../providers/familiar_provider.dart';
import 'lista_medicamentos_screen.dart';
import 'calendario_screen.dart';
import 'familiares_screen.dart';
import 'configuracion_tomas_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    const ListaMedicamentosScreen(),
    const CalendarioScreen(),
    const ConfiguracionTomasScreen(),
    const FamiliaresScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Med.',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Horarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Contactos',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final medicamentoProvider = Provider.of<MedicamentoProvider>(context);
    final tomaProvider = Provider.of<TomaProvider>(context);
    final familiarProvider = Provider.of<FamiliarProvider>(context);

    final tomasHoy = tomaProvider.tomasHoy;
    final medicamentosActivos = medicamentoProvider.medicamentosActivos;
    final adherencia = tomaProvider.getAdherenciaHoy();

    return Scaffold(
      appBar: AppBar(
        title: const Text('YaPastillas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificaciones
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Recargar datos
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo y usuario actual
              _buildHeader(context, familiarProvider),
              const SizedBox(height: 24),

              // Tarjeta de adherencia
              _buildAdherenciaCard(adherencia),
              const SizedBox(height: 16),

              // Resumen rápido
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Medicamentos\nActivos',
                      medicamentosActivos.length.toString(),
                      Icons.medication,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Tomas\nHoy',
                      tomasHoy.length.toString(),
                      Icons.alarm,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Próximas tomas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Próximas Tomas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Ver todas las tomas
                    },
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (tomasHoy.isEmpty)
                _buildEmptyState(context, 'No tienes tomas programadas para hoy')
              else
                ...tomasHoy.take(5).map((toma) {
                  final medicamento =
                      medicamentoProvider.getMedicamentoById(toma.medicamentoId);
                  return _buildTomaCard(context, toma, medicamento);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FamiliarProvider familiarProvider) {
    final familiar = familiarProvider.familiarPrincipal;
    final hora = DateTime.now().hour;
    String saludo = 'Buenos días';
    if (hora >= 12 && hora < 18) {
      saludo = 'Buenas tardes';
    } else if (hora >= 18) {
      saludo = 'Buenas noches';
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            familiar?.nombre.substring(0, 1).toUpperCase() ?? 'U',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              saludo,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              familiar?.nombre ?? 'Usuario',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdherenciaCard(double adherencia) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Adherencia de Hoy',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${adherencia.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: adherencia / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTomaCard(BuildContext context, toma, medicamento) {
    final hora = DateFormat.Hm().format(toma.fechaHoraProgramada);
    final tomada = toma.tomada;
    final omitida = toma.omitida;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: tomada
                ? Colors.green.withOpacity(0.1)
                : omitida
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            tomada
                ? Icons.check_circle
                : omitida
                    ? Icons.cancel
                    : Icons.medication,
            color: tomada
                ? Colors.green
                : omitida
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          medicamento?.nombre ?? 'Medicamento',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${medicamento?.dosis ?? ''} - $hora'),
        trailing: !tomada && !omitida
            ? IconButton(
                icon: const Icon(Icons.check),
                color: Colors.green,
                onPressed: () {
                  Provider.of<TomaProvider>(context, listen: false)
                      .registrarToma(toma.id);
                },
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String mensaje) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
