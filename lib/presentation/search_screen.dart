import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  List<dynamic> searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final url = Uri.parse(
        '$baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(query)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        searchResults = data['results'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
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
              onChanged: (value) {
                searchMovies(value);
              },
            ),
          ),
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
