import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'package:samueliot_immocheck/ui/forms/element_inspection_form.dart';
import 'package:samueliot_immocheck/ui/report_page/components/room_element_tile.dart';

class RoomCard extends StatelessWidget {
  final Rapport rapport;
  final Room room;
  final VoidCallback onUpdate; 

  const RoomCard({
    super.key,
    required this.rapport,
    required this.room,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRapportTermine = rapport.statutRapport == EtatsRapport.termine;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                roomTypeString(room.roomName),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: isRapportTermine ? null : () {
                
              },
              icon: Icon(Icons.change_circle),
            ),
            IconButton(
              onPressed: isRapportTermine ? null : () {
                context.read<RapportProvider>().changeRoomStatus(room);
                onUpdate();
              },
              icon: room.statut == EtatsElement.ok ? const Icon(Icons.check) : const Icon(Icons.radio_button_unchecked),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
              onPressed: isRapportTermine ? null : () {
                context.read<RapportProvider>().deleteRoomFromRapport(
                  rapport.propertyId,
                  room.roomId,
                );
                onUpdate();
              },
            ),
          ],
        ),
        subtitle: Text("Statut: ${etatElementString(room.statut)}"),
        children: [
          ...room.elements.map(
            (element) => RoomElementTile(
              room: room,
              element: element,
              onUpdate: onUpdate,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: TextButton.icon(
                onPressed: isRapportTermine ? null : () {
                  // The room object is passed to the next form
                  Navigator.push(context, ElementInspectionFormPage.route(null, room)).then((_) => onUpdate());
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Ajouter un élément"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}