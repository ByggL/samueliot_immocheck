import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:samueliot_immocheck/ui/homepage/element_inspection_form.dart';

class RoomPage extends StatelessWidget {
  final Room room;

  static Route<void> route(Room room) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/roomPage'),
      builder: (_) => RoomPage(room: room,),
    );
  }

  const RoomPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final RoomProvider provider=RoomProvider();

    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pièce')),
        body: const Center(child: Text('Pièce introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(room.roomName)),
      body: ListView.builder(
        itemCount: room.elements.length,
        itemBuilder: (context, index) {
          final element = room.elements[index];
          return ListTile(
            title: Text(element.elementName.toString()),
            subtitle: Text(element.commentaire),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit ??'),duration: Duration(milliseconds: 500),),
                  );  
                Navigator.push(context, ElementInspectionFormPage.route(element,room));
              },

            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          //TODO
          ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Add ??'),duration: Duration(milliseconds: 500),),
                ); 
          true;
        },
      ),
    );
  }
}
