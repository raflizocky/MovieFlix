import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl => dotenv.env['TMDB_BASE_URL'] ?? '';
  static String get apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
}
