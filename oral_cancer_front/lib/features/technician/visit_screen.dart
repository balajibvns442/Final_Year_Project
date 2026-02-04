import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oral_cancer_front/features/technician/upload_screen.dart';
import '../../core/api_client.dart';

class VisitScreen extends StatefulWidget {
  final int patientId;
  const VisitScreen({super.key, required this.patientId});

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {
  final _ageCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _createVisit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await ApiClient.post(
      '/visits',
      {
        'patient_id': widget.patientId,
        'age': int.tryParse(_ageCtrl.text),
      },
      auth: true,
    );

    setState(() => _loading = false);

    if (res.statusCode != 200) {
      setState(() => _error = "Failed to create visit");
      return;
    }

    final data = jsonDecode(res.body);
    final visitId = data['visit_id'];

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>UploadScreen(visitId: visitId))) ;

    // Next phase: navigate to image upload
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Visit Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Age"),
            ),
            const SizedBox(height: 20),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            ElevatedButton(
              onPressed: _loading ? null : _createVisit,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Create Visit"),
            ),
          ],
        ),
      ),
    );
  }
}
