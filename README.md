# YaPastillas 💊

Aplicación móvil para gestionar medicamentos y recordatorios de tomas, desarrollada con Flutter.

## Características

✨ **Gestión de Medicamentos**
- Agregar, editar y eliminar medicamentos
- Información detallada: dosis, presentación, fechas de tratamiento
- Búsqueda y filtrado de medicamentos
- Estados activo/inactivo

📅 **Calendario de Tomas**
- Vista de calendario mensual
- Tomas programadas por día
- Historial completo de medicación

👥 **Gestión de Familiares**
- Administrar medicamentos de múltiples personas
- Asignar medicamentos a familiares específicos
- Marcar familiar principal

📊 **Dashboard Intuitivo**
- Resumen diario de tomas
- Estadísticas de adherencia
- Próximas tomas pendientes
- Vista rápida de medicamentos activos

✅ **Registro de Administración**
- Marcar tomas como completadas
- Omitir tomas con notas
- Historial detallado por medicamento

## Estructura del Proyecto

```
lib/
├── main.dart                   # Punto de entrada
├── models/                     # Modelos de datos
│   ├── medicamento.dart
│   ├── familiar.dart
│   ├── toma.dart
│   └── horario.dart
├── providers/                  # Estado de la aplicación
│   ├── medicamento_provider.dart
│   ├── familiar_provider.dart
│   └── toma_provider.dart
└── screens/                    # Pantallas
    ├── dashboard_screen.dart
    ├── lista_medicamentos_screen.dart
    ├── detalle_medicamento_screen.dart
    ├── agregar_medicamento_screen.dart
    ├── calendario_screen.dart
    └── familiares_screen.dart
```

## Instalación

### Requisitos previos
- Flutter SDK (versión 3.0 o superior)
- Dart SDK
- Android Studio / Xcode (para emuladores)

### Pasos

1. **Instalar dependencias**
```bash
flutter pub get
```

2. **Ejecutar la aplicación**
```bash
flutter run
```

## Dependencias Principales

- **provider**: State management
- **sqflite**: Base de datos local (preparado para implementar)
- **table_calendar**: Widget de calendario
- **google_fonts**: Tipografías personalizadas
- **intl**: Internacionalización y formato de fechas

## Próximas Características

🚀 **En desarrollo:**
- [ ] Notificaciones push para recordatorios
- [ ] Persistencia de datos con SQLite
- [ ] Exportar/importar datos
- [ ] Estadísticas avanzadas de adherencia
- [ ] Modo oscuro
- [ ] Sincronización en la nube
- [ ] Recordatorios personalizables por medicamento
- [ ] Widget de inicio rápido

## Pantallas Principales

### 🏠 Dashboard
Vista principal con resumen diario, adherencia y próximas tomas.

### 💊 Lista de Medicamentos
Todos tus medicamentos con búsqueda y filtros.

### 📅 Calendario
Vista mensual con todas las tomas programadas.

### 👤 Familiares
Gestiona medicamentos de toda la familia.

### 📝 Detalle de Medicamento
Información completa y historial de cada medicamento.

## Uso

### Agregar un medicamento
1. Ve a la pestaña "Medicamentos"
2. Toca el botón "+"
3. Completa la información
4. Guarda

### Registrar una toma
1. Desde el Dashboard, toca el botón ✓ en la toma
2. Se marcará como completada automáticamente

### Agregar un familiar
1. Ve a la pestaña "Familiares"
2. Toca el botón "+"
3. Ingresa el nombre y relación
4. Guarda

## Personalización

Los colores principales se pueden modificar en [main.dart](lib/main.dart):

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF6366F1), // Cambia este color
),
```

## Licencia

Este proyecto está bajo la licencia MIT.

---

**Nota**: Esta aplicación no reemplaza el consejo médico profesional. Siempre consulta con tu médico sobre tu tratamiento.
