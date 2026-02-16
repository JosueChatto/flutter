
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Para acceder a ThemeProvider

// Modelo para los datos del reporte
class ScholarshipReport {
  final String reportId;
  final String controlNumber;
  final String cafeteriaId;
  final String type;
  final double amount;
  final String startDate;
  final String endDate;
  final String status;

  ScholarshipReport({
    required this.reportId,
    required this.controlNumber,
    required this.cafeteriaId,
    required this.type,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}

class CafeteriaDashboardScreen extends StatelessWidget {
  const CafeteriaDashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Datos de ejemplo para el reporte
    final List<ScholarshipReport> reports = [
      ScholarshipReport(reportId: 'R001', controlNumber: '2024001', cafeteriaId: 'CAF01', type: 'Alimenticia', amount: 1500.00, startDate: '2024-08-01', endDate: '2024-12-15', status: 'Activa'),
      ScholarshipReport(reportId: 'R002', controlNumber: '2024002', cafeteriaId: 'CAF01', type: 'Alimenticia', amount: 1500.00, startDate: '2024-08-01', endDate: '2024-12-15', status: 'Activa'),
      ScholarshipReport(reportId: 'R003', controlNumber: '2024003', cafeteriaId: 'CAF01', type: 'Alimenticia', amount: 1500.00, startDate: '2024-08-01', endDate: '2024-12-15', status: 'Inactiva'),
      ScholarshipReport(reportId: 'R004', controlNumber: '2024004', cafeteriaId: 'CAF01', type: 'Alimenticia', amount: 1500.00, startDate: '2024-08-01', endDate: '2024-12-15', status: 'Activa'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Becados'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingRowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary.withOpacity(0.1)),
              columns: const [
                DataColumn(label: Text('ID Reporte')),
                DataColumn(label: Text('No. Control')),
                DataColumn(label: Text('ID Cafetería')),
                DataColumn(label: Text('Tipo')),
                DataColumn(label: Text('Monto')),
                DataColumn(label: Text('Inicio')),
                DataColumn(label: Text('Fin')),
                DataColumn(label: Text('Estatus')),
              ],
              rows: reports.map((report) {
                return DataRow(
                  cells: [
                    DataCell(Text(report.reportId)),
                    DataCell(Text(report.controlNumber)),
                    DataCell(Text(report.cafeteriaId)),
                    DataCell(Text(report.type)),
                    DataCell(Text(report.amount.toStringAsFixed(2))),
                    DataCell(Text(report.startDate)),
                    DataCell(Text(report.endDate)),
                    DataCell(
                      Chip(
                        label: Text(report.status),
                        backgroundColor: report.status == 'Activa' ? Colors.green.shade100 : Colors.red.shade100,
                        labelStyle: TextStyle(
                          color: report.status == 'Activa' ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
