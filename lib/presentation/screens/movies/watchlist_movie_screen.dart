import 'package:flutter/material.dart';
import 'dart:io';
import '../../../data/movie_data_manager.dart';
import '../../../services/api_service.dart';
import 'movie_detail_screen.dart';

/// A screen that displays the user's watchlist of movies.
///
/// This widget fetches and displays movies that the user has added to their
/// watchlist. It shows movie posters, titles, runtimes, and brief overviews.
/// Users can tap on a movie to view more details.

/// A stateful widget representing the watchlist movies screen.
class WatchlistMoviesScreen extends StatefulWidget {
  /// Creates a [WatchlistMoviesScreen].
  const WatchlistMoviesScreen({super.key});

  @override
  WatchlistMoviesScreenState createState() => WatchlistMoviesScreenState();
}

/// The state for the [WatchlistMoviesScreen] widget.
class WatchlistMoviesScreenState extends State<WatchlistMoviesScreen> {
  /// The list of movies in the user's watchlist.
  List<Map<String, dynamic>> watchlistMovies = [];

  /// The API service used to fetch movie details.
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    loadWatchlistMovies();
  }

  /// Loads the movies in the user's watchlist.
  ///
  /// This method fetches the watchlist from [MovieDataManager], then retrieves
  /// details for each movie from the API.
  Future<void> loadWatchlistMovies() async {
    final watchlist = await MovieDataManager.getWatchlist();

    List<Map<String, dynamic>> loadedMovies = [];
    for (int movieId in watchlist) {
      final movieDetails = await apiService.fetchMovieDetails(movieId);
      if (movieDetails != null) {
        loadedMovies.add(movieDetails);
      }
    }

    setState(() {
      watchlistMovies = loadedMovies;
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

  /// Builds the header for the watchlist screen.
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
            'Watch List',
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

  /// Builds the list of movies in the watchlist.
  ///
  /// If the watchlist is empty, displays a message encouraging the user to add movies.
  Widget _buildMovieList() {
    if (watchlistMovies.isEmpty) {
      return _buildEmptyWatchlistMessage();
    } else {
      return ListView.builder(
        itemCount: watchlistMovies.length,
        itemBuilder: (context, index) =>
            _buildMovieListItem(watchlistMovies[index]),
      );
    }
  }

  /// Builds a message to display when the watchlist is empty.
  Widget _buildEmptyWatchlistMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            color: Colors.grey,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Add movies you want to watch later',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Builds a list item for a single movie in the watchlist.
  ///
  /// Displays the movie poster, title, runtime, overview, and release date.
  /// Tapping on the item navigates to the [MovieDetailScreen] for that movie.
  Widget _buildMovieListItem(Map<String, dynamic> movie) {
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
            _buildMoviePoster(movie['id'], movie['poster_path']),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMovieDetails(movie),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the movie poster image.
  ///
  /// Attempts to load the image from local storage first, falling back to
  /// the network image if the local image is not available.
  Widget _buildMoviePoster(int movieId, String posterPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: FutureBuilder<File?>(
        future: MovieDataManager.getLocalImage(movieId),
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
              'https://image.tmdb.org/t/p/w154$posterPath',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
            );
          }
        },
      ),
    );
  }

  /// Builds the details section for a movie list item.
  ///
  /// Displays the movie title, runtime, overview, and release date.
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
        Row(
          children: [
            const Icon(Icons.access_time, color: Colors.blue, size: 16),
            const SizedBox(width: 4),
            Text(
              '${movie['runtime']} min',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          movie['overview'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[400], size: 14),
            const SizedBox(width: 4),
            Text(
              movie['release_date'] ?? 'TBA',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
