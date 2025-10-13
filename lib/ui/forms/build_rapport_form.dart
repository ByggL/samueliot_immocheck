import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'package:uuid/uuid.dart';


class BuildRapportForm extends StatefulWidget {

  const BuildRapportForm({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/buildRapportForm'),
      builder: (_) => BuildRapportForm(),
    );
  }

  @override
  State<BuildRapportForm> createState() => _BuildRapportFormState();
}

class _BuildRapportFormState extends State<BuildRapportForm> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _adressController = TextEditingController();
  String _signature = "Oui"; 
  PropertyTypes _propertyType = PropertyTypes.appartement;
  DateTime _selectedDate = DateTime.now();
  EtatsRapport? _selectedStatus;

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Rapport submittedRapport = Rapport(
        nom: _nameController.text,
        adresse: _adressController.text,
        roomList: [],
        propertyType: _propertyType,
        propertyId: Uuid().v4(),
        creationDate: _selectedDate,
        statutRapport: _selectedStatus!,
        signature: _signature ,
      );
      RapportProvider rapportProvider = RapportProvider();
      rapportProvider.loadRapports();
      print(rapportProvider.properties.length);

      rapportProvider.addRapportGlobal(submittedRapport);
      print('yo');
      print(rapportProvider.properties.length);
      rapportProvider.saveRapports();
      rapportProvider.loadRapports();
      print(rapportProvider.properties.length);
      Navigator.pop(context);


      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Reports')),
        body:
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom propriété'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _adressController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(_selectedDate == null
                      ? 'Sélectionner une date'
                      : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EtatsRapport>(
                  initialValue: _selectedStatus,
                  items: EtatsRapport.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.name),
                            ),
                          )
                          .toList(),
                  decoration: const InputDecoration(labelText: 'Statut'),
                  onChanged: (value) => setState(() => _selectedStatus = value),
                  validator: (value) =>
                      value == null ? 'Sélectionnez un statut' : null,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<PropertyTypes>(
                  initialValue: _propertyType,
                  items: PropertyTypes.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.name),
                            ),
                          )
                          .toList(),
                  decoration: const InputDecoration(labelText: 'Type de propriété'),
                  onChanged: (value) => setState(() => _propertyType = value!),
                  validator: (value) =>
                      value == null ? 'Sélectionnez un statut' : null,
                ),          
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: _signature,
                  items: ['Oui', 'Non']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                  decoration: const InputDecoration(labelText: 'Signé ?'),
                  onChanged: (value) => setState(() => _signature = value!),
                  validator: (value) =>
                      value == null ? 'Sélectionnez un statut' : null,
                ),          
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Créer le rapport'),
                ),
              ],
            ),
          )
    
    );
  }
}