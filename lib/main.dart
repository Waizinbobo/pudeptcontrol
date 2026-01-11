import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hvxciowwhkjuxijaajgq.supabase.co',
    anonKey: 'sb_publishable_d2Rq1gteZ2bxwxjU9b1BTw_bnGFfpmb',
  );

  final loggedIn = await SupabaseService.isLoggedIn();

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PU Dept Control',
      home: loggedIn ? DashboardUI() : DepartmentLoginPage(),
    );
  }
}
