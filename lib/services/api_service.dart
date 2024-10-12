import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// A service class responsible for handling API requests to the movie database.
///
/// The [ApiService] class uses HTTP client requests to fetch various movie-related data,
/// including now-playing movies, popular movies, movie details, and search results.
class ApiService {
  /// The HTTP client used for making API requests.
  final http.Client _client;

  /// Creates an [ApiService] instance with an optional HTTP [client].
  /// If no client is provided, a default [http.Client] is used.
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches a list of now-playing movies.
  ///
  /// This method retrieves movies currently showing in theaters.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> fetchNowPlayingMovies() async {
    try {
      final response = await _client.get(
        Uri.parse(
            "${ApiConfig.baseUrl}/movie/now_playing?api_key=${ApiConfig.apiKey}"),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load movies: $e');
    }
  }

  /// Fetches a list of popular movies.
  ///
  /// This method retrieves popular movies based on the API's criteria.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> fetchPopularMovies() async {
    try {
      final response = await _client.get(
        Uri.parse(
            "${ApiConfig.baseUrl}/movie/popular?api_key=${ApiConfig.apiKey}"),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load popular movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load popular movies: $e');
    }
  }

  /// Fetches details for a specific movie.
  ///
  /// The [movieId] parameter specifies the ID of the movie to retrieve details for.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> fetchMovieDetails(int movieId) async {
    try {
      final response = await _client.get(
        Uri.parse(
            "${ApiConfig.baseUrl}/movie/$movieId?api_key=${ApiConfig.apiKey}"),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  /// Fetches a list of similar movies based on a specific movie.
  ///
  /// The [movieId] parameter specifies the ID of the movie to find similar movies for.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> fetchSimilarMovies(int movieId) async {
    try {
      final response = await _client.get(
        Uri.parse(
            "${ApiConfig.baseUrl}/movie/$movieId/similar?api_key=${ApiConfig.apiKey}"),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load similar movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load similar movies: $e');
    }
  }

  /// Searches for movies based on a query and optional parameters.
  ///
  /// The [endpoint] parameter specifies the API endpoint for the search.
  /// The [queryParams] parameter allows adding additional query parameters.
  /// Throws an [Exception] if the request fails.
  Future<dynamic> searchMovies(String endpoint,
      {Map<String, String>? queryParams}) async {
    final params = {
      'api_key': ApiConfig.apiKey,
      ...?queryParams,
    };

    final uri = Uri.parse(ApiConfig.baseUrl + endpoint)
        .replace(queryParameters: params);

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  /// Disposes the HTTP client when it is no longer needed.
  ///
  /// This method should be called to release resources used by the [http.Client].
  void dispose() {
    _client.close();
  }
}
