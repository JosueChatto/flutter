import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Para acceder a ThemeProvider

/// Modelo de datos simplificado para mostrar la información de un estudiante becado.
class ApprovedApplicant {
  final String fullName;
  final String controlNumber;
  final String career;

  ApprovedApplicant({
    required this.fullName,
    required this.controlNumber,
    required this.career,
  });
}

/// Pantalla principal para el personal de cafetería.
///
/// Muestra un reporte de todos los estudiantes con becas aprobadas, permitiendo
/// buscar y filtrar en tiempo real por nombre o número de control.
class CafeteriaDashboardScreen extends StatefulWidget {
  const CafeteriaDashboardScreen({super.key});

  @override
  State<CafeteriaDashboardScreen> createState() =>
      _CafeteriaDashboardScreenState();
}

class _CafeteriaDashboardScreenState extends State<CafeteriaDashboardScreen> {
  String? _cafeteriaName;
  bool _isLoading = true;
  List<ApprovedApplicant> _allApplicants = [];
  List<ApprovedApplicant> _filteredApplicants = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    // Se añade un listener al controlador para filtrar la lista en tiempo real.
    _searchController.addListener(_filterApplicants);
  }

  /// Orquesta la carga inicial de datos: primero la info de la cafetería, luego los becados.
  Future<void> _loadInitialData() async {
    await _loadCafeteriaInfo();
    await _fetchApprovedApplicants();
  }

  /// Carga el nombre de la cafetería desde el documento del usuario actual.
  Future<void> _loadCafeteriaInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (mounted && userDoc.exists) {
          setState(() {
            _cafeteriaName = userDoc.data()?['nameCafeteria'];
          });
        }
      } catch (e) {
        // Manejar el error si es necesario, por ejemplo, mostrando un mensaje.
      }
    }
  }

  /// Obtiene todos los estudiantes con estatus 'approved' usando una consulta de grupo.
  ///
  /// Una `collectionGroup` query permite buscar en todas las subcolecciones con el mismo
  /// nombre (en este caso, 'applicants') a la vez, lo cual es muy eficiente para
  /// este caso de uso.
  Future<void> _fetchApprovedApplicants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('applicants')
          .where('status', isEqualTo: 'approved')
          .get();

      final applicants = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final fullName =
            ('${data['studentName'] ?? ''} ${data['lastName'] ?? ''}').trim();
        return ApprovedApplicant(
          fullName: fullName,
          controlNumber: data['numberControl']?.toString() ?? 'N/A',
          career: data['career'] ?? 'N/A',
        );
      }).toList();

      setState(() {
        _allApplicants = applicants;
        _filteredApplicants = applicants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // En un caso real, sería bueno mostrar un SnackBar o mensaje de error.
    }
  }

  /// Filtra la lista de aplicantes basado en el texto del buscador.
  void _filterApplicants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApplicants = _allApplicants.where((applicant) {
        final nameMatches = applicant.fullName.toLowerCase().contains(query);
        final controlNumberMatches = applicant.controlNumber
            .toLowerCase()
            .contains(query);
        return nameMatches || controlNumberMatches;
      }).toList();
    });
  }

  /// Cierra la sesión del usuario y lo redirige a la pantalla de login.
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    context.go('/login');
  }

  @override
  void dispose() {
    // Es crucial remover el listener y desechar el controlador para evitar fugas de memoria.
    _searchController.removeListener(_filterApplicants);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reporte de Becados'),
            if (_cafeteriaName != null)
              Text(
                _cafeteriaName!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).appBarTheme.foregroundColor?.withOpacity(0.8),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Cambiar Tema',
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por Nombre o No. de Control',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApplicants.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'No hay becados aprobados actualmente.'
                          : 'No se encontraron resultados para \'${_searchController.text}\'.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : _buildDataTable(context, isDark),
          ),
        ],
      ),
    );
  }

  /// Construye el widget `DataTable` para mostrar la lista de estudiantes.
  Widget _buildDataTable(BuildContext context, bool isDark) {
    final headerColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
    final headerTextColor = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(headerColor),
          columns: [
            DataColumn(
              label: Text(
                'Nombre Completo',
                style: TextStyle(
                  color: headerTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'No. de Control',
                style: TextStyle(
                  color: headerTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Carrera',
                style: TextStyle(
                  color: headerTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          rows: _filteredApplicants.map((applicant) {
            return DataRow(
              cells: [
                DataCell(Text(applicant.fullName)),
                DataCell(Text(applicant.controlNumber)),
                DataCell(Text(applicant.career)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
