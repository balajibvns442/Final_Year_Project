import 'package:flutter/material.dart';
import '../../widgets/logout_button.dart';
import 'patient_screen.dart';

class TechnicianHome extends StatelessWidget {
  const TechnicianHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Technician Dashboard"),
        actions: [
          LogoutButton() ,
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Add / Find Patient"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PatientScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
