
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:share_plus/share_plus.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/element_provider.dart';
import 'package:samueliot_immocheck/providers/piece_provider.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'package:samueliot_immocheck/ui/forms/build_room_form.dart';
import 'package:samueliot_immocheck/ui/forms/element_inspection_form.dart';
import 'package:provider/provider.dart';
import 'package:samueliot_immocheck/ui/forms/validate_sign_rapport.dart';


class ReportPage extends StatefulWidget {
  final Rapport rapport;

  const ReportPage({super.key, required this.rapport});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  void _openAddRoomForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 20,
            ),
            child: RoomCreationForm(
              onSubmit: (room) {
                    context.read<RapportProvider>().addRoomToRapport(
                      widget.rapport.propertyId,
                      room
                      );
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ),
    );
  }

  void _exportJson(Rapport rapport) {
    final jsonString = jsonEncode(rapport.toJson());
    // You can use Share.share(jsonString) to share, or write to a file using dart:io
    SharePlus.instance.share(ShareParams(text:jsonString));
  }

  Future<void> _exportPdf(Rapport rapport) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text('Rapport: ${rapport.nom}'),
            pw.Text('Adresse: ${rapport.adresse}'),
            // Add more fields and formatting as needed
          ],
        ),
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Rapport_${rapport.nom}.pdf');
    }

  @override
  Widget build(BuildContext context) {
    final rapport = context.watch<RapportProvider>().getRapportById(widget.rapport.propertyId) ?? widget.rapport;

    return Scaffold(
      appBar: AppBar(title: Text("Rapport: ${rapport.nom}")),

      body: 
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              spacing: 50,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,

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
                              "Statut du rapport: ${etatRapportString(rapport.statutRapport)}",
                            ),

                            Text(
                              "Créé le: ${DateFormat('yyyy-MM-dd – kk:mm').format(rapport.creationDate)}",
                            ),

                          ],
                        ),
                      ),
                    ),
                    rapport.statutRapport==EtatsRapport.termine?
                    Text("Rapport déjà validé"):
                    ElevatedButton.icon(
                      onPressed: (){
                        Navigator.push<bool>(context,ValidateSignRapportPage.route(rapport))
                          .then((result) {
                            if (result == true) {setState(() {});};
                            }
                          );
                      }, 
                      icon: Icon(Icons.check),
                      label: Text("Valider le rapport",maxLines: 3,)
                    ),
                    if (rapport.statutRapport == EtatsRapport.termine)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text("Signatures du rapport:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ...rapport.signature.asMap().entries.map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: entry.value != null && entry.value!.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Signature ${entry.key + 1 == 1? "locataire":"propriétaire"} :"),
                                    Container(
                                      height: 120,
                                      width: 300,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Image.memory(entry.value!, fit: BoxFit.contain),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Text("Signature ${entry.key + 1}: "),
                                    Icon(Icons.close, color: Colors.red),
                                  ],
                                ),
                          )),
                        ],
                      ),
                    ],
                  ),
                Column(
                  children: [
                  context.read<RapportProvider>().getPropertyById(rapport.propertyId)?.statutRapport == EtatsRapport.termine?
                  Column(
                    spacing: 20,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _exportPdf(rapport);
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Exporter le rapport en PDF"),
                      ),
                      ElevatedButton.icon(
                        onPressed: (){
                          _exportJson(rapport);
                        },
                        icon: const Icon(Icons.file_copy),
                        label: const Text("Exporter le rapport en JSON"),
                        ),
                  ],
                  )
                  :Text(" ")
                ],
                ),
              ],
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
            rapport.statutRapport==EtatsRapport.termine?
            Text("Rapport déjà validé, impossible de le modifier"):
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _openAddRoomForm(context),
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
      child:
      ExpansionTile(
        title: Row( 
          children: [
            Expanded(
              child: Text(
                roomTypeString(room.roomName),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: context.read<RapportProvider>().getPropertyByRoomId(room.roomId)?.statutRapport == EtatsRapport.termine? null: (){
                context.read<RapportProvider>().changeRoomStatus(room);
                setState(() {});
              } ,
              icon: room.statut == EtatsElement.ok ? Icon(Icons.check) :Icon(Icons.radio_button_unchecked)
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
              onPressed: context.read<RapportProvider>().getPropertyByRoomId(room.roomId)?.statutRapport == EtatsRapport.termine? null:() {
                context.read<RapportProvider>().deleteRoomFromRapport(
                  widget.rapport.propertyId, 
                  room.roomId,
                );
                setState(() {});
              },
            ),
          ],
        ),
        subtitle: Text("Statut: ${etatElementString(room.statut)}"),
        children: [
          ...room.elements.map((element) => _buildRoomElementCard(context, room, element)),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: TextButton.icon(
                onPressed: context.read<RapportProvider>().getPropertyByRoomId(room.roomId)?.statutRapport == EtatsRapport.termine? null: () {
                  Navigator.push(context, ElementInspectionFormPage.route(null, room)).then((_) {setState(() {});});
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

  Widget _buildRoomElementCard(BuildContext context, Room room, RoomElement element) {
    return
    ListTile(
      leading: const Icon(Icons.home_repair_service),
      title: Text("Element: ${roomElementString(element.elementName)}"),
      subtitle:Text("Statut: ${etatElementString(element.statut)}"),
      onTap:  (){
        Navigator.push(
          context,
          ElementInspectionFormPage.route(element, room),
          ).then((_) {setState(() {});});
      },
      trailing:Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          element.elementPicture.isNotEmpty
              ? const Icon(Icons.photo_library, color: Colors.blueAccent)
              : const Icon(Icons.photo_outlined, color: Colors.grey),

              // const SizedBox(width: 8),

              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: context.read<RapportProvider>().getPropertyByRoomId(room.roomId)?.statutRapport == EtatsRapport.termine? null: () {
                  context.read<RapportProvider>().deleteElementFromRoom(
                    room.roomId,
                    element.elementID,
                  );
                  setState(() {});
                },
              ),
        ],
      ),
    );
  }
}
