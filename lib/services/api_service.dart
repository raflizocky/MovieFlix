import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

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

  void dispose() {
    _client.close();
  }
}
