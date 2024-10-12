import 'package:flutter/material.dart';
import '/services/api_service.dart';
import 'dart:io';
import '../../../data/movie_data_manager.dart';
import 'movie_detail_screen.dart';

/// A screen that displays a list of the user's favorite movies.
///
/// This widget fetches and displays favorite movies from local storage
/// and the API. It allows users to view details of each favorite movie.
class FavoriteMoviesScreen extends StatefulWidget {
  /// Creates a new instance of [FavoriteMoviesScreen].
  const FavoriteMoviesScreen({super.key});

  @override
  FavoriteMoviesScreenState createState() => FavoriteMoviesScreenState();
}

/// The state for the [FavoriteMoviesScreen] widget.
class FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  /// List of favorite movies with their details.
  List<Map<String, dynamic>> favoriteMovies = [];

  /// Service for making API calls to fetch movie data.
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    loadFavoriteMovies();
  }

  /// Loads favorite movies from local storage and fetches their details from the API.
  ///
  /// This method populates the [favoriteMovies] list with movie details
  /// for each favorite movie ID stored locally.
  Future<void> loadFavoriteMovies() async {
    final favorites = await MovieDataManager.getFavorites();
    List<Map<String, dynamic>> loadedMovies = [];

    for (int movieId in favorites) {
      final movieDetails = await apiService.fetchMovieDetails(movieId);
      if (movieDetails != null) {
        loadedMovies.add(movieDetails);
      }
    }

    setState(() {
      favoriteMovies = loadedMovies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildMovieList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header for the favorite movies screen.
  ///
  /// Includes a back button and the screen title.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Favorite',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the list of favorite movies.
  ///
  /// If there are no favorite movies, displays a message instead.
  Widget _buildMovieList() {
    return favoriteMovies.isEmpty
        ? const Center(
            child: Text(
              'No favorite movies yet',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        : ListView.builder(
            itemCount: favoriteMovies.length,
            itemBuilder: (context, index) =>
                _buildMovieItem(favoriteMovies[index]),
          );
  }

  /// Builds a list item for a single movie.
  ///
  /// This widget displays the movie poster, title, rating, genre, release date, and runtime.
  /// Tapping on the item navigates to the [MovieDetailScreen] for that movie.
  Widget _buildMovieItem(Map<String, dynamic> movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movieId: movie['id']),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoviePoster(movie),
            const SizedBox(width: 16),
            Expanded(child: _buildMovieDetails(movie)),
          ],
        ),
      ),
    );
  }

  /// Builds the movie poster widget.
  ///
  /// Attempts to load the poster from local storage first, then falls back to the network image.
  Widget _buildMoviePoster(Map<String, dynamic> movie) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: FutureBuilder<File?>(
        future: MovieDataManager.getLocalImage(movie['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
            );
          } else {
            return Image.network(
              'https://image.tmdb.org/t/p/w154${movie['poster_path']}',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
            );
          }
        },
      ),
    );
  }

  /// Builds the movie details widget.
  ///
  /// Displays the movie title, rating, genre, release date, and runtime.
  Widget _buildMovieDetails(Map<String, dynamic> movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie['title'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        _buildRating(movie['vote_average']),
        const SizedBox(height: 4),
        Text(
          '${movie['genres']?.first['name'] ?? 'N/A'}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          movie['release_date'] ?? 'Unknown date',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '${movie['runtime']} minutes',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  /// Builds the rating widget for a movie.
  ///
  /// Displays a star icon and the movie's rating.
  Widget _buildRating(double rating) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.yellow, size: 16),
        const SizedBox(width: 4),
        Text(
          '$rating',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
