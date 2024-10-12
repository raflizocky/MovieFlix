import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import '../../services/api_service.dart';
import 'screens/movies/movie_detail_screen.dart';

/// A stateful widget representing the main home screen of the app.
///
/// This screen includes a bottom navigation bar to switch between
/// home content, search, and profile screens.
class HomeScreen extends StatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

/// The state for the [HomeScreen] widget.
class HomeScreenState extends State<HomeScreen> {
  /// The index of the currently selected tab.
  int _currentIndex = 0;

  /// The API service used to fetch movie data.
  final ApiService _apiService = ApiService();

  /// The list of screens corresponding to each tab.
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeContent(),
      SearchScreen(apiService: _apiService),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Builds the bottom navigation bar for the home screen.
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

/// A stateful widget representing the main content of the home screen.
///
/// This widget displays a list of movies, either now playing or popular,
/// and allows the user to switch between these two categories.
class HomeContent extends StatefulWidget {
  /// Creates a [HomeContent] widget.
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

/// The state for the [HomeContent] widget.
class HomeContentState extends State<HomeContent> {
  /// The API service used to fetch movie data.
  final ApiService _apiService = ApiService();

  /// The list of movies to display.
  List<dynamic> movies = [];

  /// Whether to show now playing movies (true) or popular movies (false).
  bool isNowPlaying = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  /// Fetches the list of movies based on the current selection (now playing or popular).
  Future<void> fetchMovies() async {
    try {
      final data = isNowPlaying
          ? await _apiService.fetchNowPlayingMovies()
          : await _apiService.fetchPopularMovies();

      setState(() {
        movies = data['results'].take(isNowPlaying ? 6 : 20).toList();
      });
    } catch (e) {
      const SnackBar(content: Text("Error fetching movies."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTabs(),
          const SizedBox(height: 16),
          Expanded(child: _buildMovieGrid()),
        ],
      ),
    );
  }

  /// Builds the header section of the home content.
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'What do you want to watch?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds the tabs for switching between now playing and popular movies.
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildTab('Now playing', isSelected: isNowPlaying),
          const SizedBox(width: 16),
          _buildTab('Popular', isSelected: !isNowPlaying),
        ],
      ),
    );
  }

  /// Builds a single tab for the movie category selection.
  ///
  /// [text] is the label of the tab.
  /// [isSelected] determines whether this tab is currently selected.
  Widget _buildTab(String text, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isNowPlaying = text == 'Now playing';
        });
        fetchMovies();
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

  /// Builds the grid of movie posters.
  Widget _buildMovieGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMoviePoster(movie);
      },
    );
  }

  /// Builds a movie poster widget for a single movie.
  ///
  /// [movie] is a map containing the movie data.
  Widget _buildMoviePoster(Map<String, dynamic> movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movieId: movie['id']),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: movie['poster_path'] != null
            ? Image.network(
                'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                fit: BoxFit.cover,
              )
            : Container(color: Colors.grey),
      ),
    );
  }
}
