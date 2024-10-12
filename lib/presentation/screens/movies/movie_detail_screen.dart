import 'package:flutter/material.dart';
import '../../../data/movie_data_manager.dart';
import '../../../services/api_service.dart';

/// A screen that displays detailed information about a specific movie.
///
/// This widget fetches and displays movie details, similar movies,
/// and allows users to add/remove the movie from their favorites and watchlist.
class MovieDetailScreen extends StatefulWidget {
  /// The unique identifier of the movie to display.
  final int movieId;

  /// Creates a new instance of [MovieDetailScreen].
  ///
  /// The [movieId] parameter is required and must not be null.
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  MovieDetailScreenState createState() => MovieDetailScreenState();
}

/// The state for the [MovieDetailScreen] widget.
class MovieDetailScreenState extends State<MovieDetailScreen> {
  /// Service for making API calls to fetch movie data.
  final ApiService apiService = ApiService();

  /// Detailed information about the movie.
  Map<String, dynamic> movieDetails = {};

  /// List of similar movies.
  List<dynamic> similarMovies = [];

  /// Whether the current tab is showing about movie information.
  bool isAboutMovie = true;

  /// Whether the current movie is in the user's favorites.
  bool isFavorite = false;

  /// Whether the current movie is in the user's watchlist.
  bool isWatchlist = false;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
    fetchSimilarMovies();
    checkFavoriteStatus();
    checkWatchlistStatus();
  }

  /// Fetches detailed information about the movie from the API.
  Future<void> fetchMovieDetails() async {
    try {
      final details = await apiService.fetchMovieDetails(widget.movieId);
      setState(() {
        movieDetails = details;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('An error occurred during fetching movie details.')),
        );
      }
    }
  }

  /// Fetches a list of similar movies from the API.
  Future<void> fetchSimilarMovies() async {
    try {
      final data = await apiService.fetchSimilarMovies(widget.movieId);
      setState(() {
        similarMovies = data['results'].take(2).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('An error occurred during fetching similar movies.')),
        );
      }
    }
  }

  /// Checks if the current movie is in the user's favorites.
  Future<void> checkFavoriteStatus() async {
    bool favorite = await MovieDataManager.isFavorite(widget.movieId);
    setState(() {
      isFavorite = favorite;
    });
  }

  /// Checks if the current movie is in the user's watchlist.
  Future<void> checkWatchlistStatus() async {
    bool watchlist = await MovieDataManager.isWatchlist(widget.movieId);
    setState(() {
      isWatchlist = watchlist;
    });
  }

  /// Toggles the favorite status of the current movie.
  Future<void> toggleFavorite() async {
    final posterPath = movieDetails['poster_path'];
    await MovieDataManager.toggleFavorite(widget.movieId, posterPath ?? '');
    checkFavoriteStatus();
  }

  /// Toggles the watchlist status of the current movie.
  Future<void> toggleWatchlist() async {
    final posterPath = movieDetails['poster_path'];
    await MovieDataManager.toggleWatchlist(widget.movieId, posterPath ?? '');
    checkWatchlistStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildMovieInfo(),
            _buildTabBar(),
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar for the movie detail screen.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Detail',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: toggleFavorite,
        ),
        IconButton(
          icon: Icon(
            isWatchlist ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: toggleWatchlist,
        ),
      ],
    );
  }

  /// Builds the header section with the movie's backdrop image.
  Widget _buildHeader() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://image.tmdb.org/t/p/w500${movieDetails['backdrop_path']}',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Builds the movie information section with poster, title, rating, and other details.
  Widget _buildMovieInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPoster(),
          const SizedBox(width: 16),
          Expanded(child: _buildMovieDetails()),
        ],
      ),
    );
  }

  /// Builds the movie poster image.
  Widget _buildPoster() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        'https://image.tmdb.org/t/p/w200${movieDetails['poster_path']}',
        height: 150,
        width: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  /// Builds the movie details section with title, rating, and other information.
  Widget _buildMovieDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movieDetails['title'] ?? '',
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildRating(),
        const SizedBox(height: 8),
        Text(
          '${movieDetails['release_date']?.split('-')[0] ?? ''} • ${movieDetails['runtime']} Minutes • ${movieDetails['genres']?.map((g) => g['name']).join(', ') ?? ''}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  /// Builds the rating display with a star icon and the average vote.
  Widget _buildRating() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.yellow, size: 16),
        const SizedBox(width: 4),
        Text(
          '${movieDetails['vote_average']?.toStringAsFixed(1) ?? ''}',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  /// Builds the tab bar for switching between "About Movie" and "Similar Movie" sections.
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildTab('About Movie', isSelected: isAboutMovie),
          const SizedBox(width: 16),
          _buildTab('Similar Movie', isSelected: !isAboutMovie),
        ],
      ),
    );
  }

  /// Builds a single tab for the tab bar.
  Widget _buildTab(String text, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isAboutMovie = text == 'About Movie';
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 3,
              width: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the content for the selected tab (either About Movie or Similar Movies).
  Widget _buildTabContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isAboutMovie ? _buildAboutMovie() : _buildSimilarMovies(),
    );
  }

  /// Builds the "About Movie" section with the movie overview.
  Widget _buildAboutMovie() {
    return Text(
      movieDetails['overview'] ?? '',
      style: const TextStyle(color: Colors.white),
    );
  }

  /// Builds the "Similar Movies" section with a list of similar movie items.
  Widget _buildSimilarMovies() {
    return Column(
      children:
          similarMovies.map((movie) => _buildSimilarMovieItem(movie)).toList(),
    );
  }

  /// Builds a single item in the similar movies list.
  Widget _buildSimilarMovieItem(Map<String, dynamic> movie) {
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
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            _buildSimilarMoviePoster(movie),
            const SizedBox(width: 16),
            Expanded(child: _buildSimilarMovieDetails(movie)),
          ],
        ),
      ),
    );
  }

  /// Builds the poster for a similar movie item.
  Widget _buildSimilarMoviePoster(Map<String, dynamic> movie) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
        height: 120,
        width: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  /// Builds the details section for a similar movie item.
  Widget _buildSimilarMovieDetails(Map<String, dynamic> movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie['title'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        _buildSimilarMovieRating(movie),
        const SizedBox(height: 4),
        Text(
          '${movie['release_date']?.split('-')[0] ?? ''} • Action',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '${movie['runtime'] ?? 139} minutes',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  /// Builds the rating display for a similar movie item.
  Widget _buildSimilarMovieRating(Map<String, dynamic> movie) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.yellow, size: 16),
        const SizedBox(width: 4),
        Text(
          '${movie['vote_average']?.toStringAsFixed(1) ?? ''}',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
