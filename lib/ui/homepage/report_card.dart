import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final String name;
  final String type;
  final String date;
  final String address;
  final String status;
  final VoidCallback? onDelete;

  const ReportCard({
    super.key,
    required this.name,
    required this.type,
    required this.date,
    required this.address,
    required this.status,
    this.onDelete,
  });

  (IconData, Color) _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return (Icons.hourglass_empty, Colors.orangeAccent);
      case 'In Progress':
        return (Icons.autorenew, Colors.blueAccent);
      case 'Finished':
        return (Icons.check_circle, Colors.green);
      default:
        return (Icons.help_outline, Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),
            Text("Type : $type"),

            Text("Date : $date"),

            Text("Address : $address"),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.redAccent,
                  onPressed: onDelete,
                  tooltip: "Delete Report",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
