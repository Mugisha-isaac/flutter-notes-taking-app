import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_taking_app/controllers/auth_controller.dart';
import 'package:notes_taking_app/controllers/note.dart';
import 'package:notes_taking_app/screens/add-edit-note.dart';
import 'package:notes_taking_app/screens/login.dart';
import 'package:notes_taking_app/screens/notes.dart';
import 'package:notes_taking_app/screens/register.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notes Taking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),
        GetPage(name: '/notes', page: () => const NotesPage()),
        GetPage(name: '/add-note', page: () => const AddEditNotePage()),
      ],
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(NotesController());
      }),
    );
  }
}
