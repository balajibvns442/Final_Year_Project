import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../widgets/review_card.dart';

class ReviewedCasesWidget extends StatefulWidget {
  const ReviewedCasesWidget({super.key});

  @override
  State<ReviewedCasesWidget> createState() => _ReviewedCasesWidgetState();
}

class _ReviewedCasesWidgetState extends State<ReviewedCasesWidget> {
  List _reviewed = [];
  bool _loading = true;

  Future<void> _loadPendingCases() async {
    final res = await ApiClient.get('/technician/reviewed');

    if (res.statusCode == 200) {
      setState(() {
        _reviewed = jsonDecode(res.body);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: _reviewed.length,
      itemBuilder: (_, i) {
        return ReviewCard(review: _reviewed[i]);
      },
    );
  }
}
