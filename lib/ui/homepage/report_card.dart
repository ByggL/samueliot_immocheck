import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final String name;
  final String type;
  final String date;
  final String address;
  final VoidCallback? onDelete;

  const ReportCard({
    super.key,
    required this.name,
    required this.type,
    required this.date,
    required this.address,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left section — details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Type: $type"),
                  Text("Date: $date"),
                  Text("Address: $address"),
                ],
              ),
            ),

            // Right section — delete button
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.redAccent,
              onPressed: onDelete,
              tooltip: "Delete Report",
            ),
          ],
        ),
      ),
    );
  }
}
