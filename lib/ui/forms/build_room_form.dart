// ignore_for_file: deprecated_member_use

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
  final TextEditingController _roomTrueNameController = TextEditingController();
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
            "New room",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Room name",
            ),
            controller: _roomTrueNameController,
            validator:
                (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a room name";  
                    }
                  return null;
                },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<RoomTypes>(
            value: _nameController,
            decoration: const InputDecoration(
              labelText: "Room type",
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
                    value == null ? "Please select a type" : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<EtatsElement>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: "Room status",
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
                    value == null ? "Please select a status" : null,
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
              child: const Text("Add room"),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
