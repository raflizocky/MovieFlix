import 'package:flutter/material.dart';
import 'config/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// The main entry point of the Flutter application.
void main() async {
  // Ensures that all widgets are properly initialized before further setup.
  WidgetsFlutterBinding.ensureInitialized();

  // Loads environment variables from a .env file using the `flutter_dotenv` package.
  await dotenv.load(fileName: "./dotenv");

  // Initializes Firebase with platform-specific options.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initializes SharedPreferences for local storage needs.
  await SharedPreferences.getInstance();

  // Runs the main application.
  runApp(const MyApp());
}

/// The main application widget for the Flutter Movie App.
///
/// This widget is the root of the application's widget tree and sets up the
/// application theme and home screen.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Movie App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
