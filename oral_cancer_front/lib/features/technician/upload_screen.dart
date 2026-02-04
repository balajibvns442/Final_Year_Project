import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../../core/auth_storage.dart';

class UploadScreen extends StatefulWidget {
  final int visitId;
  const UploadScreen({super.key, required this.visitId});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  bool _uploading = false;
  String? _risk;
  double? _confidence;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _risk = null;
        _confidence = null;
        _error = null;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _uploading = true;
      _error = null;
    });

    final token = await AuthStorage.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppConstants.baseUrl}/images/upload"),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['visit_id'] = widget.visitId.toString();
    request.files.add(
      await http.MultipartFile.fromPath('image', _image!.path),
    );

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      setState(() => _uploading = false);

      if (response.statusCode != 200) {
        setState(() => _error = "Upload failed");
        return;
      }

      final data = jsonDecode(responseBody);
      setState(() {
        _risk = data['risk'];
        _confidence = data['confidence'].toDouble();
      });
    } catch (e) {
      setState(() {
        _uploading = false;
        _error = "Something went wrong";
      });
    }
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Oral Image")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null)
              Image.file(_image!, height: 220)
            else
              Container(
                height: 220,
                color: Colors.grey.shade200,
                child: const Center(child: Text("No image selected")),
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture Image"),
              onPressed: _pickImage,
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _uploading || _image == null ? null : _uploadImage,
              child: _uploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Upload & Analyze"),
            ),

            const SizedBox(height: 20),

            if (_risk != null)
              Column(
                children: [
                  Text(
                    "Risk Level: $_risk",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _riskColor(_risk!),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%",
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Doctor will review this case",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
