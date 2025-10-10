import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/element_provider.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';

class ReportPage extends StatelessWidget {
  final Rapport rapport;

  const ReportPage({super.key, required this.rapport});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rapport: ${rapport.nom}")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rapport.nom,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text("Adresse: ${rapport.adresse}"),

                    Text("Type: ${propertyString(rapport.propertyType)}"),

                    Text(
                      "Statut du rapport: ${etatString(rapport.statutRapport)}",
                    ),

                    Text(
                      "Créé le: ${DateFormat('yyyy-MM-dd – kk:mm').format(rapport.creationDate)}",
                    ),

                    const SizedBox(height: 8),
                    Text("Signature: ${rapport.signature}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Pièces du bien",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...rapport.roomList.map((room) => _buildRoomCard(context, room)),

            const SizedBox(height: 16),

            // ➕ Add Room Button at bottom
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text("Ajouter une pièce"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          room.roomName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Statut: ${room.statut.name}"),
        children: [
          ...room.elements.map((element) => _buildRoomElementCard(element)),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Ajouter un élément"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomElementCard(RoomElement element) {
    return ListTile(
      leading: const Icon(Icons.home_repair_service),
      title: Text("Statut: ${element.statut.name}"),
      subtitle: Text(element.commentaire),
      trailing:
          element.elementPicture.isNotEmpty
              ? const Icon(Icons.photo_library, color: Colors.blueAccent)
              : const Icon(Icons.photo_outlined, color: Colors.grey),
    );
  }
}
