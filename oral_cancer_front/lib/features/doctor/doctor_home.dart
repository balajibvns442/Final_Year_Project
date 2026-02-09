import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oral_cancer_front/widgets/review_card.dart';
import '../../core/api_client.dart';
import '../../widgets/logout_button.dart';
import 'review_detail_screen.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  bool _loading = true;
  List _reviews = [];

  Future<void> _loadReviews() async {
    final res = await ApiClient.get('/doctor/pending', auth: true);

    if (res.statusCode == 200) {
      setState(() {
        _reviews = jsonDecode(res.body);
        print(res.body) ;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Reviews"),
        actions: const [LogoutButton()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _reviews.length,
        itemBuilder: (_, i) {
          final r = _reviews[i];
          return GestureDetector(
            child: ReviewCard(review: _reviews[i]),
            onTap: () async {
              final _updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ReviewDetailScreen(review: r),
                ),
              );

              if( _updated==true ){
                _loadReviews() ;
              }
            },
          );
        },
      ),
    );
  }
}


