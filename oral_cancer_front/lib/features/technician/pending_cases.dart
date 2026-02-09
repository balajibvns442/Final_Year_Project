import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../widgets/review_card.dart';


class PendingCasesWidget extends StatefulWidget {
  const PendingCasesWidget({super.key});

  @override
  State<PendingCasesWidget> createState() => _PendingCasesWidgetState();
}


class _PendingCasesWidgetState extends State<PendingCasesWidget> {
  List _pending = [];
  bool _loading = true;

  Future<void> _loadPendingCases() async {
    try {
      final res = await ApiClient.get('/technician/pending-cases', auth: true);

      if (res.statusCode == 200) {
        setState(() {
          _pending = jsonDecode(res.body);
          _loading = false;
        });
      } else {
        debugPrint('Error: ${res.statusCode}');
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('API error: $e');
      setState(() => _loading = false);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPendingCases();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: _pending.length,
      itemBuilder: (_, i) {
        print(_pending[i]);
        return ReviewCard(review: _pending[i]);
      },
    );
  }
}