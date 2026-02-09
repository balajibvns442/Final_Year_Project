import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oral_cancer_front/core/api_client.dart';
import 'package:oral_cancer_front/features/technician/new_cases.dart';
import 'package:oral_cancer_front/features/technician/pending_cases.dart';
import 'package:oral_cancer_front/features/technician/visit_screen.dart';
import 'package:oral_cancer_front/widgets/logout_button.dart';
import 'package:oral_cancer_front/widgets/review_card.dart';

import 'reviewed_screen.dart';

enum TechTab { pending, reviewed, newCase }

class TechnicianHomeScreen extends StatefulWidget {
  final String name;

  const TechnicianHomeScreen({
    super.key,
    required this.name,
  });

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  TechTab selectedTab = TechTab.newCase;
  bool _loadingP = true;
  bool _loadingR = true;
  List _pending = [];
  List _reviewed = [];

  int? _patientId;
  String? _patientName ;
  int? _visitId ;
  int? age ;

  Future<void> _loadPendingCases() async {
    final res = await ApiClient.get('/technician/pending');

    if (res.statusCode == 200) {
      setState(() {
        _pending = jsonDecode(res.body);
        _loadingP = false;
      });
    }
  }

  Future<void> _loadReviewedCases() async {
    final res = await ApiClient.get('technician/reviewed');

    if (res.statusCode == 200) {
      setState(() {
        _reviewed = jsonDecode(res.body);
        _loadingR = false;
      });
    }
  }

  Widget _buildTabButton(String label, TechTab tab, Color color) {
    final isSelected = selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (selectedTab) {
      case TechTab.pending:
        return PendingCasesWidget();
      case TechTab.reviewed:
        return const ReviewedCasesWidget();
      case TechTab.newCase:
        return _patientId == null
            ? NewCaseWidget(onSuccess: (id,name) {
                setState(() {
                  _patientId = id;
                  _patientName = name ;
                });
              })
            : VisitScreen(patientId: _patientId!,patientName: _patientName!,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 18,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 10),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          LogoutButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tabs
            Row(
              children: [
                _buildTabButton("Pending", TechTab.pending, Colors.orange),
                const SizedBox(width: 8),
                _buildTabButton("Reviewed", TechTab.reviewed, Colors.green),
                const SizedBox(width: 8),
                _buildTabButton("New Case", TechTab.newCase, Colors.blue),
              ],
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
}
