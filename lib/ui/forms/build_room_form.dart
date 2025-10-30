import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:uuid/uuid.dart';

class RoomCreationForm extends StatefulWidget {
  final Function(Room) onSubmit;
  final Room? existingRoom;

  const RoomCreationForm({super.key,required this.onSubmit, this.existingRoom});

  @override
  State<RoomCreationForm> createState() => _RoomCreationForm();
}

class _RoomCreationForm extends State<RoomCreationForm> {
  final _formKey = GlobalKey<FormState>();
  RoomTypes _nameController= RoomTypes.bathroom ;
  EtatsElement? _selectedStatus ;
  TextEditingController _roomTrueNameController = TextEditingController();
  String? _roomId ;

  @override
  void initState() {  
    super.initState();
    if (widget.existingRoom != null) {
      _nameController = widget.existingRoom!.roomName;
      _selectedStatus = widget.existingRoom!.statut;
      _roomTrueNameController.text= widget.existingRoom!.roomTrueName;
      _roomId = widget.existingRoom!.roomId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nouvelle pièce",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: "Nom de la pièce",
            ),
            controller: _roomTrueNameController,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<RoomTypes>(
            // ignore: deprecated_member_use
            value: _nameController,
            decoration: const InputDecoration(
              labelText: "Type de pièce",
              border: OutlineInputBorder(),
            ),
            items:
                RoomTypes.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(roomTypeString(status)),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _nameController = value!),
            validator:
                (value) =>
                    value == null ? "Veuillez sélectionner un type" : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<EtatsElement>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: "Statut de la pièce",
              border: OutlineInputBorder(),
            ),
            items:
                EtatsElement.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(etatElementString(status)),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedStatus = value),
            validator:
                (value) =>
                    value == null ? "Veuillez sélectionner un statut" : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newRoom = Room(
                    roomId: _roomId ?? Uuid().v4(),
                    roomTrueName: _roomTrueNameController.text,
                    roomName: _nameController,
                    statut: _selectedStatus!,
                  );
                  widget.onSubmit(newRoom);
                }
              },
              child: const Text("Ajouter la pièce"),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
