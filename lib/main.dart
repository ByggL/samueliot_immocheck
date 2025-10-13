import 'package:flutter/material.dart';
import 'package:samueliot_immocheck/ui/homepage/report_list.dart';
import 'package:provider/provider.dart';
import 'package:samueliot_immocheck/providers/rapport_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => RapportProvider(),
      child:const MyApp()
      ) 
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImmoCheck',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ReportList(),
    );
  }
}

