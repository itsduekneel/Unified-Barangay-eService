import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/authentication/supabase_config.dart';
import 'package:ube/view_models/document_view_model.dart';
import 'package:ube/view_models/user_view_model.dart';
import 'widgets/appShell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DocumentViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'SNPro'),
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}
