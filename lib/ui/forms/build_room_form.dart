import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:uuid/uuid.dart';

class RoomCreationForm extends StatefulWidget {
  final Function(Room) onSubmit;

  const RoomCreationForm({required this.onSubmit});

  @override
  State<RoomCreationForm> createState() => _RoomCreationForm();
}

class _RoomCreationForm extends State<RoomCreationForm> {
  final _formKey = GlobalKey<FormState>();
  RoomTypes _nameController = RoomTypes.bathroom;
  EtatsElement? _selectedStatus;

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
          DropdownButtonFormField<RoomTypes>(
            initialValue: _nameController,
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
            initialValue: _selectedStatus,
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
                    roomId: Uuid().v4(),
                    roomName: _nameController.name,
                    statut: _selectedStatus!,
                    elements: [],
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
