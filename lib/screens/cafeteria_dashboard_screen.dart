import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../main.dart'; // Necesario para el ThemeProvider.

class CafeteriaDashboardScreen extends StatelessWidget {
  const CafeteriaDashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Cafetería'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('calls')
            .where('isPublished', isEqualTo: true)
            .orderBy('endDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar convocatorias: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay listas de becarios publicadas en este momento.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final calls = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              final data = call.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Convocatoria sin título';
              final startDate = (data['startDate'] as Timestamp?)?.toDate();
              final endDate = (data['endDate'] as Timestamp?)?.toDate();

              String dateRange = 'Fechas no especificadas';
              if (startDate != null && endDate != null) {
                dateRange = '${DateFormat.yMMMd('es_ES').format(startDate)} - ${DateFormat.yMMMd('es_ES').format(endDate)}';
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.list_alt, color: Colors.white),
                  ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(dateRange),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/cafeteria-dashboard/scholar-list/${call.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
