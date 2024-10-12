import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../presentation/screens/movies/movie_detail_screen.dart';

/// A screen that allows users to search for movies.
///
/// The [SearchScreen] widget provides a text field for inputting search
/// queries and displays a list of search results retrieved from an API.
/// This screen uses the [ApiService] to perform the search operation.
class SearchScreen extends StatefulWidget {
  /// The [ApiService] instance used for fetching movie data.
  final ApiService apiService;

  /// Creates a [SearchScreen] with the provided [ApiService].
  const SearchScreen({super.key, required this.apiService});

  @override
  SearchScreenState createState() => SearchScreenState();
}

/// The state class for [SearchScreen].
///
/// Manages the search logic, input field, and displays a list of results
/// based on the user input.
class SearchScreenState extends State<SearchScreen> {
  /// List to store the search results.
  List<dynamic> searchResults = [];

  /// Controller for the search input field.
  final TextEditingController _searchController = TextEditingController();

  /// Fetches movies based on the search query.
  ///
  /// This method sends the query to the API and updates [searchResults]
  /// based on the response. If the query is empty, it clears the results.
  Future<void> searchMovies(String query) async {
    // If the search query is empty, clear the results.
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      // Fetch movie data using the ApiService.
      final data = await widget.apiService.searchMovies(query);
      setState(() {
        searchResults = data['results'];
      });
    } catch (e) {
      // Display an error message if the search fails.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred during searching movies.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // The search input field.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for movies...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              // Calls the search method when the input changes.
              onChanged: (value) {
                searchMovies(value);
              },
            ),
          ),
          // Displays the list of search results.
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final movie = searchResults[index];
                return ListTile(
                  leading: movie['poster_path'] != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 50,
                          color: Colors.grey,
                        ),
                  title: Text(
                    movie['title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    movie['release_date'] ?? 'Unknown release date',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  // Navigates to the movie detail screen when a result is tapped.
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailScreen(movieId: movie['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
