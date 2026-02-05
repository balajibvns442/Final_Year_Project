import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';

class ReviewDetailScreen extends StatefulWidget {
  final Map review;
  const ReviewDetailScreen({super.key, required this.review});

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  final _notesCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  Future<void> _submitReview() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final res = await ApiClient.post(
      '/reviews/${widget.review['review_id']}',
      {
        'notes': _notesCtrl.text.trim(),
      },
      auth: true,
    );

    setState(() => _submitting = false);

    if (res.statusCode != 200) {
      setState(() => _error = "Failed to submit review");
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review submitted")),
    );

    Navigator.pop(context, true); // go back to list
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Case"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient name
            Text(
              r['patient_name'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Image
            Center(
              child: FutureBuilder<Uint8List>(
                future: ApiClient.getImageBytes("/images/getImage/${r['id']}"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 240,
                      child: Center(child: Icon(Icons.broken_image)),
                    );
                  }

                  return Image.memory(
                    snapshot.data!,
                    height: 360,
                    fit: BoxFit.fill,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // AI result
            Text(
              "AI Risk: ${r['risk']}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _riskColor(r['risk']),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "Confidence: ${(r['confidence'] * 100).toStringAsFixed(1)}%",
            ),

            const Divider(height: 32),

            // Notes
            const Text(
              "Doctor Notes",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter clinical notes / instructions",
              ),
            ),

            const SizedBox(height: 20),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitReview,
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Mark as Reviewed"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
