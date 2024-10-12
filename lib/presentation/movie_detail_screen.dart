import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String apiKey = '3b0f6422b6bf1291ffc719ebae8e9435';
const String baseUrl = 'https://api.themoviedb.org/3';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  MovieDetailScreenState createState() => MovieDetailScreenState();
}

class MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic> movieDetails = {};
  List<dynamic> similarMovies = [];
  bool isAboutMovie = true;
  bool isFavorite = false;
  bool isWatchlist = false;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
    fetchSimilarMovies();
    checkFavoriteStatus();
    checkWatchlistStatus();
  }

  Future<void> fetchMovieDetails() async {
    final url = Uri.parse('$baseUrl/movie/${widget.movieId}?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        movieDetails = json.decode(response.body);
      });
    }
  }

  Future<void> fetchSimilarMovies() async {
    final url =
        Uri.parse('$baseUrl/movie/${widget.movieId}/similar?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        similarMovies = data['results'].take(2).toList();
      });
    }
  }

  Future<void> checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.movieId.toString());
    });
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      if (isFavorite) {
        favorites.remove(widget.movieId.toString());
      } else {
        favorites.add(widget.movieId.toString());
      }
      isFavorite = !isFavorite;
    });

    await prefs.setStringList('favorites', favorites);
  }

  Future<void> checkWatchlistStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = prefs.getStringList('watchlist') ?? [];
    setState(() {
      isWatchlist = watchlist.contains(widget.movieId.toString());
    });
  }

  Future<void> toggleWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = prefs.getStringList('watchlist') ?? [];

    setState(() {
      if (isWatchlist) {
        watchlist.remove(widget.movieId.toString());
      } else {
        watchlist.add(widget.movieId.toString());
      }
      isWatchlist = !isWatchlist;
    });

    await prefs.setStringList('watchlist', watchlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
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
      ),
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

  Widget _buildMovieInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://image.tmdb.org/t/p/w200${movieDetails['poster_path']}',
              height: 150,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movieDetails['title'] ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${movieDetails['vote_average']?.toStringAsFixed(1) ?? ''}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${movieDetails['release_date']?.split('-')[0] ?? ''} • ${movieDetails['runtime']} Minutes • ${movieDetails['genres']?.map((g) => g['name']).join(', ') ?? ''}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildTabContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isAboutMovie ? _buildAboutMovie() : _buildSimilarMovies(),
    );
  }

  Widget _buildAboutMovie() {
    return Text(
      movieDetails['overview'] ?? '',
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildSimilarMovies() {
    return Column(
      children:
          similarMovies.map((movie) => _buildSimilarMovieItem(movie)).toList(),
    );
  }

  Widget _buildSimilarMovieItem(Map<String, dynamic> movie) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
              height: 120,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie['title'] ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${movie['vote_average']?.toStringAsFixed(1) ?? ''}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
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
            ),
          ),
        ],
      ),
    );
  }
}
