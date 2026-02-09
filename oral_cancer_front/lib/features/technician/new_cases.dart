import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oral_cancer_front/features/technician/visit_screen.dart';

import '../../core/api_client.dart';

class NewCaseWidget extends StatefulWidget {
  final void Function(int patientId,String patientName) onSuccess ;
  const NewCaseWidget({super.key , required this.onSuccess});

  @override
  State<NewCaseWidget> createState() => _NewCaseWidgetState();
}

class _NewCaseWidgetState extends State<NewCaseWidget> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _mailCtrl = TextEditingController();
  String _gender = 'MALE';

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await ApiClient.post(
      '/patients',
      {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'gender': _gender,
        'address': _addressCtrl.text.trim(),
        'email': _mailCtrl.text.trim()
      },
      auth: true,
    );

    setState(() => _loading = false);

    if (res.statusCode != 200) {
      setState(() => _error = "Failed to create/find patient");
      return;
    }

    final data = jsonDecode(res.body);
    final patientId = data['patient_id'];

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => VisitScreen(patientId: patientId),
    //   ),
    // );

    widget.onSuccess(patientId,_nameCtrl.text.trim()) ;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Patient Details",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 25),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Patient Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _mailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _addressCtrl,
              keyboardType: TextInputType.streetAddress,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _gender,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                    DropdownMenuItem(value: 'OTHERS', child: Text('Others')),
                  ],
                  onChanged: (v) => setState(() => _gender = v!),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _loading ? null : _submit,
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
