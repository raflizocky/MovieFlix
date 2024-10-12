import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../movie_data_manager.dart';
import 'movie_detail_screen.dart';

const String apiKey = '3b0f6422b6bf1291ffc719ebae8e9435';
const String baseUrl = 'https://api.themoviedb.org/3';

class WatchlistMoviesScreen extends StatefulWidget {
  const WatchlistMoviesScreen({super.key});

  @override
  WatchlistMoviesScreenState createState() => WatchlistMoviesScreenState();
}

class WatchlistMoviesScreenState extends State<WatchlistMoviesScreen> {
  List<Map<String, dynamic>> watchlistMovies = [];

  @override
  void initState() {
    super.initState();
    loadWatchlistMovies();
  }

  Future<void> loadWatchlistMovies() async {
    final watchlist = await MovieDataManager.getWatchlist();

    List<Map<String, dynamic>> loadedMovies = [];
    for (int movieId in watchlist) {
      final movieDetails = await fetchMovieDetails(movieId);
      if (movieDetails != null) {
        loadedMovies.add(movieDetails);
      }
    }

    setState(() {
      watchlistMovies = loadedMovies;
    });
  }

  Future<Map<String, dynamic>?> fetchMovieDetails(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
            ),
            Expanded(
              child: watchlistMovies.isEmpty
                  ? const Center(
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
                    )
                  : ListView.builder(
                      itemCount: watchlistMovies.length,
                      itemBuilder: (context, index) {
                        final movie = watchlistMovies[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetailScreen(movieId: movie['id']),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<File?>(
                                    future: MovieDataManager.getLocalImage(
                                        movie['id']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
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
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          const Icon(Icons.access_time,
                                              color: Colors.blue, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${movie['runtime']} min',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        movie['overview'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              color: Colors.grey[400],
                                              size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            movie['release_date'] ?? 'TBA',
                                            style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
