
import 'package:flutter/material.dart';
import '../data/scholarship_data.dart';
import '../widgets/scholarship_card.dart';
import 'scholarship_detail_screen.dart'; 

class ScholarshipListScreen extends StatelessWidget {
  const ScholarshipListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Becas Disponibles'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: mockScholarships.length,
        itemBuilder: (context, index) {
          final scholarship = mockScholarships[index];
          return ScholarshipCard(
            scholarship: scholarship,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScholarshipDetailScreen(scholarship: scholarship),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
