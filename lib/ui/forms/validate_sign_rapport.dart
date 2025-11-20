import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'package:signature/signature.dart';

class ValidateSignRapportPage extends StatefulWidget {
  final Rapport reportData; 

  static Route<bool> route(Rapport reportData) {
    return MaterialPageRoute<bool>(
      settings: const RouteSettings(name: '/validateSignRapport'),
      builder: (_) => ValidateSignRapportPage(reportData: reportData),
    );
  }
  const ValidateSignRapportPage({super.key, required this.reportData});

  @override
  State<ValidateSignRapportPage> createState() => _ValidateSignRapportPageState();
}

class _ValidateSignRapportPageState extends State<ValidateSignRapportPage> {
  final SignatureController _tenantController = SignatureController(penStrokeWidth: 2, penColor: Colors.black);
  final SignatureController _ownerController = SignatureController(penStrokeWidth: 2, penColor: Colors.black);
      

  @override
  void dispose() {
    _tenantController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  void _validateReport() async {
   
    if (_tenantController.isNotEmpty && _ownerController.isNotEmpty) {
      final Uint8List? tenantSignature = await _tenantController.toPngBytes();
      final Uint8List? ownerSignature = await _ownerController.toPngBytes();

      context.read<RapportProvider>().validateRapport(
        widget.reportData, 
        [tenantSignature,  ownerSignature],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Succesfully validated report"),
        ),
      );
      Navigator.pop(context, true);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signatures required to validate report'),duration: Duration(seconds: 2),),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.reportData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report validation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Global summary and overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRapportCard(report),
            const SizedBox(height: 24),
            const Text('Tenant signature', style: TextStyle(fontWeight: FontWeight.bold)),
            Signature(
              controller: _tenantController,
              height: 150,
              backgroundColor: Colors.grey[200]!,
            ),
            TextButton(
              onPressed: () => _tenantController.clear(),
              child: const Text('Erase'),
            ),
            const SizedBox(height: 24),
            const Text('Landlord signature', style: TextStyle(fontWeight: FontWeight.bold)),
            Signature(
              controller: _ownerController,
              height: 150,
              backgroundColor: Colors.grey[200]!,
            ),
            TextButton(
              onPressed: () => _ownerController.clear(),
              child: const Text('Erase'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _validateReport,
              child: const Text('Validate report'),
            ),
          ],
        ),
      ),
    );
  }
}


Widget _buildRapportCard(Rapport report) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(report.nom, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Address: ${report.adresse}"),
          Text("Type: ${propertyString(report.propertyType)}"),
          Text("Report status: ${etatRapportString(report.statutRapport)}"),
          Text("Created: ${report.creationDate.toLocal()}"),
          Text("Is signed: ${report.signature.isNotEmpty ? "Yes" : "No"}"),
          const SizedBox(height: 12),
          Text("Rooms:", style: const TextStyle(fontWeight: FontWeight.bold)),
          ...report.roomList.map((room) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("- ${roomTypeString(room.roomName)}"),
                Text("  Room name: ${room.roomTrueName}"),
                Text("  Status: ${etatElementString(room.statut)}"),
                Text("  Number of elements: ${room.elements.length}"),
                ...room.elements.map((element) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ${roomElementString(element.elementName)}"),
                      Text("   Status: ${etatElementString(element.statut)}"),
                      Text("   Commentary: ${element.commentaire}"),
                      Text("   Number of pictures: ${element.elementPicture.length}"),
                    ],
                  ),
                )),
              ],
            ),
          )),
        ],
      ),
    ),
  );
}