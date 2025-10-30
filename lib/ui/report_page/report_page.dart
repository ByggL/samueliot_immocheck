import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'package:samueliot_immocheck/ui/forms/build_room_form.dart';
import 'package:samueliot_immocheck/ui/forms/validate_sign_rapport.dart';

// Import the newly created components and service
import 'package:samueliot_immocheck/ui/report_page/components/report_info_card.dart';
import 'package:samueliot_immocheck/ui/report_page/components/room_card.dart';
import 'package:samueliot_immocheck/ui/report_page/pdf_export_service.dart';

class ReportPage extends StatefulWidget {
  final Rapport rapport;

  const ReportPage({super.key, required this.rapport});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // Single refresh function for all sub-components to call
  void _refreshState() {
    setState(() {});
  }

  void _openAddRoomForm(BuildContext context, Rapport rapport) {
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
                  rapport.propertyId,
                  room,
                );
                Navigator.pop(context);
                _refreshState();
              },
            ),
          ),
    );
  }

  void _validateReport(Rapport rapport) {
    Navigator.push<bool>(context, ValidateSignRapportPage.route(rapport)).then((
      result,
    ) {
      if (result == true) {
        _refreshState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes on the report object
    final rapport =
        context.watch<RapportProvider>().getRapportById(
          widget.rapport.propertyId,
        ) ??
        widget.rapport;

    // Instantiate the service
    final exportService = PdfExportService(context, rapport);
    final isRapportTermine = rapport.statutRapport == EtatsRapport.termine;

    return Scaffold(
      appBar: AppBar(title: Text("Rapport: ${rapport.nom}")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Report Main Info Card (Extracted Widget)
            Align(
              alignment: Alignment.center,
              child: ReportInfoCard(rapport: rapport),
            ),

            const SizedBox(height: 16),

            // 2. Validation Button
            if (isRapportTermine)
              const Text("Rapport déjà validé")
            else
              ElevatedButton.icon(
                onPressed: () => _validateReport(rapport),
                icon: const Icon(Icons.check),
                label: const Text("Valider le rapport", maxLines: 3),
              ),

            const SizedBox(height: 16),

            // 3. Export Buttons (Logic delegated to service)
            if (isRapportTermine)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: exportService.generateAndSharePdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Exporter le rapport en PDF"),
                  ),
                  ElevatedButton.icon(
                    onPressed: exportService.exportJson,
                    icon: const Icon(Icons.file_copy),
                    label: const Text("Exporter le rapport en JSON"),
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

            // 4. Room List (Uses Extracted Widget)
            ...rapport.roomList.map(
              (room) => RoomCard(
                rapport: rapport,
                room: room,
                onUpdate: _refreshState, // Pass the parent's refresh callback
              ),
            ),

            const SizedBox(height: 16),

            // 5. Add Room Button
            if (isRapportTermine)
              const Text("Rapport déjà validé, impossible de le modifier")
            else
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _openAddRoomForm(context, rapport),
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

            // 6. Signature Display
            const Text(
              "Signatures du rapport:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...rapport.signature.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child:
                    (entry.value != null && entry.value!.isNotEmpty)
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Signature ${entry.key == 0 ? "locataire" : "propriétaire"} :",
                            ),
                            Container(
                              height: 120,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromARGB(255, 250, 53, 53),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.memory(
                                entry.value!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
