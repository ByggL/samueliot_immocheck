import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/element_provider.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'package:samueliot_immocheck/ui/forms/element_inspection_form.dart';

class RoomElementTile extends StatelessWidget {
  final Room room;
  final RoomElement element;
  final VoidCallback onUpdate; 

  const RoomElementTile({
    super.key,
    required this.room,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // Check report status through the provider using the room's ID
    final bool isRapportTermine = context.read<RapportProvider>().getPropertyByRoomId(room.roomId)?.statutRapport == EtatsRapport.termine;

    return ListTile(
      leading: const Icon(Icons.home_repair_service),
      title: Text("Element: ${roomElementString(element.elementName)}"),
      subtitle: Text("Statut: ${etatElementString(element.statut)}"),
      onTap: () {
        Navigator.push(
          context,
          ElementInspectionFormPage.route(element, room),
        ).then((_) => onUpdate());
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          element.elementPicture.isNotEmpty
              ? const Icon(Icons.photo_library, color: Colors.blueAccent)
              : const Icon(Icons.photo_outlined, color: Colors.grey),
          
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: isRapportTermine ? null : () {
              context.read<RapportProvider>().deleteElementFromRoom(
                room.roomId,
                element.elementID,
              );
              onUpdate(); 
            },
          ),
        ],
      ),
    );
  }
}