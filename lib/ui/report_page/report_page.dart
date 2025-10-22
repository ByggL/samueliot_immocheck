

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:image_picker/image_picker.dart'; 
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

    
  Future<void> _generateAndSharePdf(Rapport rapport) async {
    // print("Hello from PDF generation");
    final doc = pw.Document(title: 'Rapport: ${rapport.nom}');
    final font = await PdfGoogleFonts.openSansRegular();

    // print('Starting PDF generation...');

    // 1. Add cover page with signatures and main info (synchronous content)
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          List<pw.Widget> widgets = [];
          
          // Signatures at the top
          widgets.add(pw.Text('Signatures', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font)));
          // ... (rest of your signature and main info widgets)

          // Main info section
          widgets.add(pw.Text('Informations principales', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font)));
          widgets.add(pw.Text('Nom: ${rapport.nom}', style: pw.TextStyle(font: font)));
          widgets.add(pw.Text('Adresse: ${rapport.adresse}', style: pw.TextStyle(font: font)));
          widgets.add(pw.Text('Type: ${propertyString(rapport.propertyType)}', style: pw.TextStyle(font: font)));
          widgets.add(pw.Text('Statut du rapport: ${etatRapportString(rapport.statutRapport)}', style: pw.TextStyle(font: font)));
          widgets.add(pw.Text('Créé le: ${DateFormat('yyyy-MM-dd - kk:mm').format(rapport.creationDate)}', style: pw.TextStyle(font: font)));
          widgets.add(pw.SizedBox(height: 16));
          
          // Rooms summary section on the cover
          widgets.add(pw.Text('Sommaire des pièces', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font)));
          for (final room in rapport.roomList) {
            widgets.add(pw.Text('- ${roomTypeString(room.roomName)} (${room.elements.length} éléments)', style: pw.TextStyle(font: font)));
          }

          // WRAP the list in a pw.Column to enable content flow and page breaks
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: widgets,
            ),
          ];
        },
      ),
    );

    // 2. Add detailed pages for each element with ASYNCHRONOUS image loading
    for (final room in rapport.roomList) {
      for (final element in room.elements) {
        final List<pw.Widget> imageWidgets = [];

        // Check if elementPicture contains image paths (as String) or XFile objects (in-memory)
        if (element.elementPicture.isNotEmpty) {
          
          // print('Processing ${element.elementPicture.length} images for ${element.elementName.name}');

          // CRITICAL: Iterate through picture paths/objects and load bytes ASYNCHRONOUSLY
          for (final dynamic pictureItem in element.elementPicture) {
            String? imagePath;

            // NEW LOGIC START: Check for XFile object
            if (pictureItem is XFile) {
              imagePath = pictureItem.path;
            } 
            // NEW LOGIC START: Check for String object (path from saved data)
            else if (pictureItem is String) {
              imagePath = pictureItem;
            }
            // NEW LOGIC END
            
            if (imagePath != null && imagePath.isNotEmpty) {
              try {
                // Read the file from the local path into bytes
                final File file = File(imagePath);
                final Uint8List imageBytes = await file.readAsBytes();
                
                // Add the image bytes to the list of PDF widgets
                imageWidgets.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Photo pour ${roomElementString(element.elementName)} (Statut: ${element.statut.name})',
                          style: pw.TextStyle(font: font, fontSize: 10),
                        ),
                        pw.Image(
                          pw.MemoryImage(imageBytes),
                          width: 200, // Adjust size as needed
                        ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                // This catch block handles failed reads (e.g., file moved/deleted)
                // print('Error loading image at path $imagePath: $e');
                imageWidgets.add(
                  pw.Text('Erreur: Image indisponible à ce chemin.', style: pw.TextStyle(color: PdfColors.red, font: font)),
                );
              }
            }
          }
        }

        // Add a new page for each detailed element report
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Pièce: ${roomTypeString(room.roomName)} - Élément: ${roomElementString(element.elementName)}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Statut: ${etatElementString(element.statut)}', style: pw.TextStyle(font: font)),
                  pw.Text('Commentaire: ${element.commentaire}', style: pw.TextStyle(font: font)),
                  pw.SizedBox(height: 15),
                  
                  // Insert the asynchronously loaded image widgets
                  ...imageWidgets,
                ],
              );
            },
          ),
        );
      }
    }


    // 3. Save the PDF bytes
    final Uint8List pdfBytes = await doc.save();
    final String fileName = 'Rapport_${rapport.nom}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

    // 4. Handle sharing/saving based on platform (using logic from your sample function)
    if (kIsWeb) {
      // WEB: Use Printing.js for direct browser download
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    } else if (Platform.isAndroid || Platform.isIOS) {
      // MOBILE: Request permission and save to a public directory

      // Check for storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        // Handle denied permission (e.g., show a dialog or SnackBar)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied. Cannot save file.")),
        );
        // Fallback to sharing directly
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
        return; 
      }

      // Get the directory to save the file
      final Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory() // Often a good place for user files on Android
          : await getApplicationDocumentsDirectory(); // Standard on iOS

      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not get a save directory.")),
        );
        return;
      }

      final File file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved successfully to ${file.path}')),
      );
    } else {
      // Desktop fallback
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    }
    
    // print('PDF sharing/saving complete.');
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
                  // ignore: empty_statements
                  if (result == true) {setState(() {});};
                  }
                );
            }, 
            icon: Icon(Icons.check),
            label: Text("Valider le rapport",maxLines: 3,)
          ),
                  
          const SizedBox(height: 16),
          Column(
                children: [
                context.read<RapportProvider>().getPropertyById(rapport.propertyId)?.statutRapport == EtatsRapport.termine?
                Column(
                  spacing: 20,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _generateAndSharePdf(rapport);
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
          const SizedBox(height: 12),
          Text("Signatures du rapport:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...rapport.signature.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              // Use an if collection-element to conditionally include the widget.
              child: (entry.value != null && entry.value!.isNotEmpty) 
                ? Column( // Value if true
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text("Signature ${entry.key + 1 == 1 ? "locataire" : "propriétaire"} :"),
                        Container(
                            height: 120,
                            width: 300,
                            decoration: BoxDecoration(
                                border: Border.all(color: const Color.fromARGB(255, 250, 53, 53)),
                                borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.memory(entry.value!, fit: BoxFit.contain),
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
                ))
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
