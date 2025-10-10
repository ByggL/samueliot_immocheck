import 'package:flutter/material.dart';
import 'report_card.dart'; // make sure this path matches your structure

// PLACEHOLDER CLASS FOR UI
class Report {
  final String name;
  final String type;
  final String date;
  final String address;

  Report({
    required this.name,
    required this.type,
    required this.date,
    required this.address,
  });
}

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  // Placeholder list of reports
  final List<Report> _reports = [
    Report(
      name: "Engine Inspection",
      type: "Maintenance Report",
      date: "2025-10-08",
      address: "1234 Elm Street, Los Angeles, CA",
    ),
    Report(
      name: "Emission Check",
      type: "Environmental Report",
      date: "2025-09-20",
      address: "456 Oak Avenue, San Francisco, CA",
    ),
  ];

  void _addReport(Report report) {
    setState(() {
      _reports.add(report);
    });
  }

  void _removeReport(Report report) {
    setState(() {
      _reports.remove(report);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body:
          _reports.isEmpty
              ? const Center(
                child: Text(
                  "No reports available.",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return ReportCard(
                    name: report.name,
                    type: report.type,
                    date: report.date,
                    address: report.address,
                    onDelete: () => _removeReport(report),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // PLACEHOLDER dummy report add button
          _addReport(
            Report(
              name: "New Vehicle Check",
              type: "Safety Report",
              date: DateTime.now().toString().split(' ')[0],
              address: "789 Pine Street, Seattle, WA",
            ),
          );
        },
        label: const Text("Add Report"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
