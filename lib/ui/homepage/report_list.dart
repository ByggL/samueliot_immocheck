import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samueliot_immocheck/data/enums.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';
import 'package:samueliot_immocheck/ui/forms/build_rapport_form.dart';
import 'package:samueliot_immocheck/ui/homepage/report_card.dart';
import 'package:provider/provider.dart';

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {

  final TextEditingController _searchController = TextEditingController();
  String _searchField = 'name'; // current field used for filtering
  String _searchQuery = '';

  String _filterValue = 'none';

  // Filtered list based on query and field
  // List<Rapport> get _filteredReports {
  //   return _reports.where((report) {
  //     final fieldValue = switch (_searchField) {
  //       'name' => report.nom,
  //       'type' => report.propertyType.toString(),
  //       'date' => DateFormat('yyyy-MM-dd – kk:mm').format(report.creationDate),
  //       _ => report.nom,
  //     };

  //     final isIncludedByFilter = switch (_filterValue) {
  //       'none' => true,
  //       'inprogress' => report.statutRapport == EtatsRapport.enCours,
  //       'finished' => report.statutRapport == EtatsRapport.termine,
  //       _ => true,
  //     };

  //     if (_searchField.isEmpty) return isIncludedByFilter;

  //     return fieldValue.toLowerCase().contains(_searchQuery.toLowerCase()) &&
  //         isIncludedByFilter;
  //   }).toList();
  // }

  List<Rapport> _filteredReports(List<Rapport> allReports) {
    Iterable<Rapport> filtered = allReports;

    filtered = filtered.where((report) {
      final isIncludedByFilter = switch (_filterValue) {
        'none' => true,
        'inprogress' => report.statutRapport == EtatsRapport.enCours,
        'finished' => report.statutRapport == EtatsRapport.termine,
        _ => true,
      };

      return isIncludedByFilter;
    });

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((report) {
        final fieldValue = switch (_searchField) {
          'name' => report.nom,
          'type' => report.propertyType.toString(),
          'date' => DateFormat(
            'yyyy-MM-dd – kk:mm',
          ).format(report.creationDate),
          _ => report.nom,
        };
        return fieldValue.toLowerCase().contains(_searchQuery.toLowerCase());
      });
    }

    return filtered.toList();
  }

  
  Widget _buildBody(BuildContext context, RapportProvider rapportProvider) {
    // 1. ÉTAT DE CHARGEMENT
    if (rapportProvider.isLoading) {
      return const Center(child: CircularProgressIndicator()); 
    }

    // 2. ÉTAT D'ERREUR
    if (rapportProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(
              rapportProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: rapportProvider.loadRapports, 
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    
    final allReports = rapportProvider.properties.cast<Rapport>();
    final filteredReports = _filteredReports(allReports);

    // 3. ÉTAT VIDE (si aucune donnée du tout)
    if (allReports.isEmpty && rapportProvider.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_add_outlined, color: Colors.grey, size: 60),
            const SizedBox(height: 10),
            const Text(
              "Aucun rapport trouvé.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Text("Commencez par ajouter un nouveau rapport.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // 4. ÉTAT DE DONNÉES PRÊTES (y compris le cas où la recherche ne retourne rien)
    if (filteredReports.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: Colors.grey, size: 50),
            const SizedBox(height: 10),
            const Text(
              "Aucun rapport ne correspond à votre recherche.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }


    // Affichage Prêt
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return ReportCard(
          report: report,
          onDelete: () {
            context.read<RapportProvider>().removeRapport(
              report,
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<RapportProvider>().loadRapports();
  }

  @override
  Widget build(BuildContext context) {
      final rapportProvider = context.watch<RapportProvider>();
      
      return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          // 🔍 Search bar + dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _searchField,
                  onChanged: (value) {
                    setState(() {
                      _searchField = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'type', child: Text('Type')),
                    DropdownMenuItem(value: 'date', child: Text('Date')),
                  ],
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const SizedBox(width: 20),
                DropdownButton<String>(
                  value: _filterValue,
                  onChanged: (value) {
                    setState(() {
                      _filterValue = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('None')),
                    DropdownMenuItem(
                      value: 'inprogress',
                      child: Text('En cours'),
                    ),
                    DropdownMenuItem(value: 'finished', child: Text('Terminé')),
                  ],
                ),
              ],
            ),
          ),

          // 📋 Report list
          Expanded(
            child: _buildBody(context, rapportProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, BuildRapportForm.route());
        },
        label: const Text("Add Report"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
