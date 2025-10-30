import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';

class ReportInfoCard extends StatelessWidget {
  final Rapport rapport;

  const ReportInfoCard({super.key, required this.rapport});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).secondaryHeaderColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rapport.nom,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Adresse: ${rapport.adresse}"),
            Text("Type: ${propertyString(rapport.propertyType)}"),
            Text(
              "Statut du rapport: ${etatRapportString(rapport.statutRapport)}",
            ),
            Text(
              "Créé le: ${DateFormat('yyyy-MM-dd – kk:mm').format(rapport.creationDate)}",
            ),
          ],
        ),
      ),
    );
  }
}
