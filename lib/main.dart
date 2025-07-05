import 'package:flutter/material.dart';
import 'package:notes_taking_app/screens/login.dart';
import 'package:notes_taking_app/screens/notes.dart';
import 'package:notes_taking_app/screens/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes Taking App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/notes': (context) => const NotesPage(),
      },
    );
  }
}
