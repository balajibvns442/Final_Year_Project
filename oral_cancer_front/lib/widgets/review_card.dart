import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {

  final dynamic review ;
  const ReviewCard({super.key , required this.review});

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
    return Card(
      child: ListTile(
        title: Text(review['patient_name']),
        subtitle: Text(
          "Risk: ${review['risk']} (${(review['confidence'] * 100).toStringAsFixed(1)}%)",
          style: TextStyle(color: _riskColor(review['risk'])),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),

    );
  }
}
