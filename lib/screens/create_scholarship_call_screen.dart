import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Pantalla que permite a los administradores crear una nueva convocatoria de beca.
///
/// Incluye un formulario completo con validaciones para el título, descripción,
/// requisitos y fechas. Destaca por su "Generador de Código de Periodo", que
/// crea un identificador único para la convocatoria (ej. BA-AGO-DIC24)
/// basado en selecciones dinámicas.
class CreateScholarshipCallScreen extends StatefulWidget {
  const CreateScholarshipCallScreen({super.key});

  @override
  State<CreateScholarshipCallScreen> createState() =>
      _CreateScholarshipCallScreenState();
}

class _CreateScholarshipCallScreenState
    extends State<CreateScholarshipCallScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _yearController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isPublishing = false;

  // --- Campos para el generador de código ---
  String? _selectedBecaType;
  String? _selectedStartMonth;
  String? _selectedEndMonth;
  String _generatedPeriodCode = '';

  final Map<String, String> _becaTypeMap = {
    'Beca Alimenticia': 'BA',
    // Se pueden agregar otros tipos de beca y sus prefijos aquí.
  };

  final Map<String, String> _monthMap = {
    'Enero': 'ENE',
    'Febrero': 'FEB',
    'Marzo': 'MAR',
    'Abril': 'ABR',
    'Mayo': 'MAY',
    'Junio': 'JUN',
    'Julio': 'JUL',
    'Agosto': 'AGO',
    'Septiembre': 'SEP',
    'Octubre': 'OCT',
    'Noviembre': 'NOV',
    'Diciembre': 'DIC',
  };

  @override
  void initState() {
    super.initState();
    _yearController.text = DateTime.now().year.toString();
    _yearController.addListener(_generateCode);
    _generateCode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  /// Genera dinámicamente el código de periodo basado en las selecciones del formulario.
  /// El código se forma con: [Tipo Beca]-[Mes Inicio]-[Mes Fin][Año]
  void _generateCode() {
    if (!mounted) return;

    if (_selectedBecaType == null ||
        _selectedStartMonth == null ||
        _selectedEndMonth == null ||
        _yearController.text.isEmpty) {
      setState(() {
        _generatedPeriodCode = '';
      });
      return;
    }

    final becaCode = _becaTypeMap[_selectedBecaType!] ?? '';
    final startMonthCode = _monthMap[_selectedStartMonth!] ?? '';
    final endMonthCode = _monthMap[_selectedEndMonth!] ?? '';
    final year = _yearController.text;
    final yearCode = year.length >= 2 ? year.substring(year.length - 2) : year;

    setState(() {
      _generatedPeriodCode = '$becaCode-$startMonthCode-$endMonthCode$yearCode';
    });
  }

  /// Muestra un `showDatePicker` y actualiza el estado y el controlador de texto.
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat(
            'dd/MM/yyyy',
            'es_ES',
          ).format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat(
            'dd/MM/yyyy',
            'es_ES',
          ).format(picked);
        }
      });
    }
  }

  /// Valida el formulario y publica la nueva convocatoria en Firestore.
  Future<void> _publishCall() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona las fechas de inicio y fin.'),
        ),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha de fin no puede ser anterior a la fecha de inicio.',
          ),
        ),
      );
      return;
    }
    if (_generatedPeriodCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, complete todos los campos para generar el código de periodo.',
          ),
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      await FirebaseFirestore.instance.collection('scholarship_calls').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirementsController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'period_code': _generatedPeriodCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Convocatoria publicada con éxito!')),
      );
      context.go('/admin-dashboard/admin-scholarship-calls');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar la convocatoria: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Convocatoria'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go('/admin-dashboard/admin-scholarship-calls'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildPeriodGeneratorSection(context),
              const Divider(height: 48, thickness: 1),
              const Text(
                'Detalles de la Convocatoria',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildTextFormField(
                controller: _titleController,
                label: 'Nombre de la Beca',
                icon: Icons.title,
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Descripción',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _requirementsController,
                label: 'Requisitos',
                icon: Icons.rule_folder_outlined,
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 24),
              _buildDateFields(context),
              const SizedBox(height: 32),
              _isPublishing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.publish_outlined),
                      label: const Text('Publicar Convocatoria'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _publishCall,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la sección del UI para el generador de código de periodo.
  Widget _buildPeriodGeneratorSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Generador de Código de Periodo',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Define el código único para la convocatoria actual.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        _buildDropdown(
          items: _becaTypeMap.keys.toList(),
          label: 'Tipo de Beca',
          onChanged: (val) {
            setState(() {
              _selectedBecaType = val;
            });
            _generateCode();
          },
          value: _selectedBecaType,
          validator: (v) => v == null ? 'Seleccione un tipo' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                items: _monthMap.keys.toList(),
                label: 'Mes de Inicio',
                onChanged: (val) {
                  setState(() {
                    _selectedStartMonth = val;
                  });
                  _generateCode();
                },
                value: _selectedStartMonth,
                validator: (v) => v == null ? 'Seleccione un mes' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(
                items: _monthMap.keys.toList(),
                label: 'Mes de Fin',
                onChanged: (val) {
                  setState(() {
                    _selectedEndMonth = val;
                  });
                  _generateCode();
                },
                value: _selectedEndMonth,
                validator: (v) => v == null ? 'Seleccione un mes' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _yearController,
          decoration: const InputDecoration(
            labelText: 'Año',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_view_day),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Ingrese un año';
            if (int.tryParse(value) == null || value.length != 4)
              return 'Año inválido';
            return null;
          },
        ),
        const SizedBox(height: 24),
        if (_generatedPeriodCode.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'Código de Periodo Generado:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _generatedPeriodCode,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Widget reutilizable para construir un `DropdownButtonFormField` estilizado.
  Widget _buildDropdown(
    List<String> items,
    String label,
    ValueChanged<String?> onChanged,
    String? value, {
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  /// Widget reutilizable para construir un `TextFormField` estilizado.
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      validator: validator,
    );
  }

  /// Construye la fila con los campos de selección de fecha.
  Widget _buildDateFields(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildDateField(
            context,
            label: 'Fecha de Inicio',
            controller: _startDateController,
            isStartDate: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateField(
            context,
            label: 'Fecha de Cierre',
            controller: _endDateController,
            isStartDate: false,
          ),
        ),
      ],
    );
  }

  /// Construye un campo de texto de solo lectura que abre un `DatePicker` al ser presionado.
  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required bool isStartDate,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.calendar_today,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      onTap: () => _selectDate(context, isStartDate),
      validator: (value) => value!.isEmpty ? 'Selecciona una fecha' : null,
    );
  }
}
