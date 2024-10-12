import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A configuration class that provides access to API-related environment variables.
///
/// The [ApiConfig] class retrieves and exposes the base URL and API key for The Movie Database (TMDB) API.
/// It uses the `flutter_dotenv` package to load environment variables.
class ApiConfig {
  /// Retrieves the base URL for TMDB API from environment variables.
  ///
  /// If the environment variable [TMDB_BASE_URL] is not set, an empty string is returned.
  static String get baseUrl => dotenv.env['TMDB_BASE_URL'] ?? '';

  /// Retrieves the API key for TMDB API from environment variables.
  ///
  /// If the environment variable [TMDB_API_KEY] is not set, an empty string is returned.
  static String get apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
}
