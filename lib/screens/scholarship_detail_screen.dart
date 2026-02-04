
import 'package:flutter/material.dart';
import '../models/scholarship.dart';

class ScholarshipDetailScreen extends StatelessWidget {
  final Scholarship scholarship;

  const ScholarshipDetailScreen({super.key, required this.scholarship});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scholarship.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Organización'),
            const SizedBox(height: 8.0),
            Text(scholarship.organization, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16.0),
            _buildSectionTitle(context, 'Descripción'),
            const SizedBox(height: 8.0),
            Text(scholarship.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16.0),
            _buildInfoRow(context, 'Monto:', scholarship.amount),
            const SizedBox(height: 8.0),
            _buildInfoRow(context, 'Fecha Límite:', scholarship.deadline),
            const SizedBox(height: 16.0),
            _buildSectionTitle(context, 'Requisitos'),
            const SizedBox(height: 8.0),
            ...scholarship.requirements.map((req) => _buildRequirement(context, req)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRequirement(BuildContext context, String requirement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 20.0, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12.0),
          Expanded(child: Text(requirement, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
