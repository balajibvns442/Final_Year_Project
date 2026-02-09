import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oral_cancer_front/features/technician/upload_screen.dart';
import '../../core/api_client.dart';

class VisitScreen extends StatefulWidget {
  final int patientId;
  final String patientName ;
  const VisitScreen({super.key, required this.patientId, required this.patientName});

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {
  final _ageCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController() ;
  final _historyCtrl = TextEditingController() ;

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
        'symptoms': _symptomsCtrl.text.trim() ,
        'history': _historyCtrl.text.trim() ,
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

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>UploadScreen(visitId: visitId,patientId: widget.patientId,patientName: widget.patientName, age: int.tryParse(_ageCtrl.text)!,))) ;

    // Next phase: navigate to image upload
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Visit Details")),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           TextField(
  //             controller: _ageCtrl,
  //             keyboardType: TextInputType.number,
  //             decoration: const InputDecoration(labelText: "Age"),
  //           ),
  //           const SizedBox(height: 20),
  //
  //           if (_error != null)
  //             Text(_error!, style: const TextStyle(color: Colors.red)),
  //
  //           ElevatedButton(
  //             onPressed: _loading ? null : _createVisit,
  //             child: _loading
  //                 ? const CircularProgressIndicator()
  //                 : const Text("Create Visit"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Visit Details",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 25),

            TextField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Patient Age",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _symptomsCtrl,
              decoration: const InputDecoration(
                labelText: "Symptoms Observed",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _historyCtrl,
              decoration: const InputDecoration(
                labelText: "Medical History",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _loading ? null : _createVisit ,
              child: _loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
