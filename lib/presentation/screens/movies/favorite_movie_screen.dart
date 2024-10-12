import 'package:flutter/material.dart';
import '/services/api_service.dart';
import 'dart:io';
import '../../../data/movie_data_manager.dart';
import 'movie_detail_screen.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  const FavoriteMoviesScreen({super.key});

  @override
  FavoriteMoviesScreenState createState() => FavoriteMoviesScreenState();
}

class FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  List<Map<String, dynamic>> favoriteMovies = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    loadFavoriteMovies();
  }

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
            Padding(
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
            ),
            Expanded(
              child: favoriteMovies.isEmpty
                  ? const Center(
                      child: Text(
                        'No favorite movies yet',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: favoriteMovies.length,
                      itemBuilder: (context, index) {
                        final movie = favoriteMovies[index];
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
                                          const Icon(Icons.star,
                                              color: Colors.yellow, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${movie['vote_average']}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${movie['genres']?.first['name'] ?? 'N/A'}',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        movie['release_date'] ?? 'Unknown date',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${movie['runtime']} minutes',
                                        style:
                                            const TextStyle(color: Colors.grey),
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
