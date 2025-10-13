import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'package:samueliot_immocheck/ui/report_page/report_page.dart';

class ReportCard extends StatelessWidget {
  final Rapport report;
  final VoidCallback? onDelete;

  const ReportCard({super.key, required this.report, this.onDelete});

  (IconData, Color) _getStatusIcon(EtatsRapport status) {
    switch (status) {
      case EtatsRapport.enCours:
        return (Icons.autorenew, Colors.blueAccent);
      case EtatsRapport.termine:
        return (Icons.check_circle, Colors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getStatusIcon(report.statutRapport);

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
              report.nom,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),
            Text("Type : ${propertyString(report.propertyType)}"),

            Text(
              "Date : ${DateFormat('yyyy-MM-dd – kk:mm').format(report.creationDate)}",
            ),

            Text("Address : ${report.adresse}"),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      etatRapportString(report.statutRapport),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPage(rapport: report),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                ),
                const SizedBox(width: 10),
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
