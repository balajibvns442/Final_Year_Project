import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oral_cancer_front/features/doctor/pending_screen.dart';
import 'package:oral_cancer_front/features/doctor/review_screen.dart';
import 'package:oral_cancer_front/widgets/review_card.dart';
import '../../core/api_client.dart';
import '../../widgets/logout_button.dart';
import 'review_detail_screen.dart';

enum TechTab { pending , reviewed }

class DoctorHome extends StatefulWidget {
  final String name;

  const DoctorHome({super.key, required this.name});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  TechTab selectedTab  = TechTab.pending ;
  bool _loading = true;
  List _reviews = [];

  Future<void> _loadReviews() async {
    final res = await ApiClient.get('/doctor/pending', auth: true);

    if (res.statusCode == 200) {
      setState(() {
        _reviews = jsonDecode(res.body);
        print(res.body);
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadReviews();
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
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        title: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        actions: [LogoutButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildTabButton("PENDING",TechTab.pending , Colors.orange) ,
                const SizedBox(width:8) ,
                _buildTabButton("REVIEWED",TechTab.reviewed , Colors.green) ,
              ],
            ),
            const SizedBox(height: 20,),

            Expanded(child: _buildBody(),)
          ],
        ),
      ),
    );
  }
}

