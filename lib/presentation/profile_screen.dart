import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_movie_app/presentation/screens/auth/welcome_screen.dart';
import 'screens/movies/favorite_movie_screen.dart';
import 'screens/movies/watchlist_movie_screen.dart';
import '../data/movie_data_manager.dart';

/// A widget that displays the user's profile screen.
///
/// This screen shows the user's profile picture, email, and provides options
/// to navigate to the Favorite and Watchlist screens. It also includes a logout button.
class ProfileScreen extends StatelessWidget {
  /// Creates a [ProfileScreen].
  ProfileScreen({super.key});

  /// The currently logged-in user, or null if no user is logged in.
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(),
              const SizedBox(height: 40),
              _buildMenuItem(
                icon: Icons.favorite,
                title: 'Favorite',
                onTap: () =>
                    _navigateToScreen(context, const FavoriteMoviesScreen()),
              ),
              _buildMenuItem(
                icon: Icons.movie,
                title: 'Watchlist',
                onTap: () =>
                    _navigateToScreen(context, const WatchlistMoviesScreen()),
              ),
              const Spacer(),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the profile header section, including the avatar and user information.
  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[800],
          child: const Icon(
            Icons.person,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'Guest',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a menu item for the profile options.
  ///
  /// [icon] is the icon to display for the menu item.
  /// [title] is the text to display for the menu item.
  /// [onTap] is the callback function to execute when the item is tapped.
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the logout button.
  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleLogout(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Logout',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Handles the logout process.
  ///
  /// This method signs out the user from Firebase, clears local data,
  /// and navigates to the welcome screen.
  void _handleLogout(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FutureBuilder(
          future: Future.wait([
            MovieDataManager.handleUserLogout(),
            FirebaseAuth.instance.signOut(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const WelcomeScreen();
            }
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          },
        ),
      ),
    );
  }

  /// Navigates to the specified screen.
  ///
  /// [context] is the build context.
  /// [screen] is the widget to navigate to.
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
