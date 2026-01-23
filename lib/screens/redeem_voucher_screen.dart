
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RedeemVoucherScreen extends StatelessWidget {
  const RedeemVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canjear Vale'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cafeteria-dashboard'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.qr_code_scanner, size: 100, color: Colors.indigo),
              const SizedBox(height: 24),
              Text(
                'Escanear Código QR',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Apunta la cámara al código QR del estudiante para canjear el vale de comida.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Escanear'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  // TODO: Implementar la funcionalidad de escaneo de QR
                  // Simular un canje exitoso
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vale canjeado exitosamente.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/cafeteria-dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
