import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'package:samueliot_immocheck/data/enums.dart';

import 'package:samueliot_immocheck/providers/rapport_provider.dart';

class PdfExportService {
  final BuildContext context;
  final Rapport rapport;

  PdfExportService(this.context, this.rapport);

  void exportJson() {
    final jsonString = jsonEncode(rapport.toJson());
    // Use Share.share for simple text sharing/saving
    SharePlus.instance.share(ShareParams(text: jsonString, subject: 'Rapport JSON: ${rapport.nom}'));
  }

  Future<void> generateAndSharePdf() async {
    final doc = pw.Document(title: 'Rapport: ${rapport.nom}');
    final font = await PdfGoogleFonts.openSansRegular();

    // 1. Add cover page
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          List<pw.Widget> widgets = [];
          
          // Signatures section
          widgets.add(pw.Text('Signatures', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: font)));
          widgets.add(pw.Text('Signature: ${rapport.signature.isNotEmpty ? 'Oui' : 'Non'}', style: pw.TextStyle(font: font)));
          widgets.add(pw.SizedBox(height: 16));
          
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
            widgets.add(pw.Text('- ${room.roomTrueName}/${roomTypeString(room.roomName)} (${room.elements.length} éléments)', style: pw.TextStyle(font: font)));
          }

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

        if (element.elementPicture.isNotEmpty) {
          for (final dynamic pictureItem in element.elementPicture) {
            String? imagePath;
            if (pictureItem is XFile) {
              imagePath = pictureItem.path;
            } else if (pictureItem is String) {
              imagePath = pictureItem;
            }
            
            if (imagePath != null && imagePath.isNotEmpty) {
              try {
                final File file = File(imagePath);
                final Uint8List imageBytes = await file.readAsBytes();
                
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
                          width: 200, 
                        ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
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

    // 4. Handle sharing/saving based on platform
    if (kIsWeb) {
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    } else if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied. Cannot save file.")),
        );
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
        return; 
      }

      final Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory() 
          : await getApplicationDocumentsDirectory(); 

      if (directory == null) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text("Could not get a save directory.")),
        );
        return;
      }

      final File file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('PDF saved successfully to ${file.path}')),
      );
    } else {
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    }
  }
}