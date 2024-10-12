import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Manages movie-related data operations, including favorites and watchlist.
///
/// This class provides methods to interact with user's movie preferences,
/// handling both authenticated (Firestore) and unauthenticated (local storage) scenarios.
class MovieDataManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Toggles the favorite status of a movie.
  ///
  /// Adds or removes the [movieId] from the user's favorites list.
  /// Also saves the movie poster locally.
  ///
  /// [movieId] is the unique identifier of the movie.
  /// [posterPath] is the path to the movie's poster image.
  static Future<void> toggleFavorite(int movieId, String posterPath) async {
    if (_auth.currentUser != null) {
      await _toggleFirestoreFavorite(movieId);
    } else {
      await _toggleLocalFavorite(movieId);
    }
    await _saveImageLocally(posterPath, movieId);
  }

  /// Toggles the watchlist status of a movie.
  ///
  /// Adds or removes the [movieId] from the user's watchlist.
  /// Also saves the movie poster locally.
  ///
  /// [movieId] is the unique identifier of the movie.
  /// [posterPath] is the path to the movie's poster image.
  static Future<void> toggleWatchlist(int movieId, String posterPath) async {
    if (_auth.currentUser != null) {
      await _toggleFirestoreWatchlist(movieId);
    } else {
      await _toggleLocalWatchlist(movieId);
    }
    await _saveImageLocally(posterPath, movieId);
  }

  /// Checks if a movie is in the user's favorites.
  ///
  /// Returns true if the movie is a favorite, false otherwise.
  ///
  /// [movieId] is the unique identifier of the movie.
  static Future<bool> isFavorite(int movieId) async {
    if (_auth.currentUser != null) {
      return await _isFirestoreFavorite(movieId);
    } else {
      return await _isLocalFavorite(movieId);
    }
  }

  /// Checks if a movie is in the user's watchlist.
  ///
  /// Returns true if the movie is in the watchlist, false otherwise.
  ///
  /// [movieId] is the unique identifier of the movie.
  static Future<bool> isWatchlist(int movieId) async {
    if (_auth.currentUser != null) {
      return await _isFirestoreWatchlist(movieId);
    } else {
      return await _isLocalWatchlist(movieId);
    }
  }

  /// Retrieves the list of favorite movie IDs.
  ///
  /// Returns a list of movie IDs that are marked as favorites.
  static Future<List<int>> getFavorites() async {
    if (_auth.currentUser != null) {
      return await _getFirestoreFavorites();
    } else {
      return await _getLocalFavorites();
    }
  }

  /// Retrieves the list of watchlist movie IDs.
  ///
  /// Returns a list of movie IDs that are in the watchlist.
  static Future<List<int>> getWatchlist() async {
    if (_auth.currentUser != null) {
      return await _getFirestoreWatchlist();
    } else {
      return await _getLocalWatchlist();
    }
  }

  /// Handles user login by clearing local data.
  static Future<void> handleUserLogin() async {
    await _clearLocalData();
  }

  /// Handles user logout by clearing local data.
  static Future<void> handleUserLogout() async {
    await _clearLocalData();
  }

  // Private methods

  /// Clears locally stored favorites and watchlist data.
  static Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favorites');
    await prefs.remove('watchlist');
  }

  /// Toggles a movie's favorite status in Firestore.
  static Future<void> _toggleFirestoreFavorite(int movieId) async {
    final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final userData = await userDoc.get();
    List<int> favorites = List<int>.from(userData.data()?['favorites'] ?? []);

    if (favorites.contains(movieId)) {
      favorites.remove(movieId);
    } else {
      favorites.add(movieId);
    }

    await userDoc.set({'favorites': favorites}, SetOptions(merge: true));
  }

  /// Toggles a movie's watchlist status in Firestore.
  static Future<void> _toggleFirestoreWatchlist(int movieId) async {
    final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final userData = await userDoc.get();
    List<int> watchlist = List<int>.from(userData.data()?['watchlist'] ?? []);

    if (watchlist.contains(movieId)) {
      watchlist.remove(movieId);
    } else {
      watchlist.add(movieId);
    }

    await userDoc.set({'watchlist': watchlist}, SetOptions(merge: true));
  }

  /// Toggles a movie's favorite status in local storage.
  static Future<void> _toggleLocalFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    if (favorites.contains(movieId.toString())) {
      favorites.remove(movieId.toString());
    } else {
      favorites.add(movieId.toString());
    }

    await prefs.setStringList('favorites', favorites);
  }

  /// Toggles a movie's watchlist status in local storage.
  static Future<void> _toggleLocalWatchlist(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = prefs.getStringList('watchlist') ?? [];

    if (watchlist.contains(movieId.toString())) {
      watchlist.remove(movieId.toString());
    } else {
      watchlist.add(movieId.toString());
    }

    await prefs.setStringList('watchlist', watchlist);
  }

  /// Checks if a movie is a favorite in Firestore.
  static Future<bool> _isFirestoreFavorite(int movieId) async {
    final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final userData = await userDoc.get();
    List<int> favorites = List<int>.from(userData.data()?['favorites'] ?? []);
    return favorites.contains(movieId);
  }

  /// Checks if a movie is in the watchlist in Firestore.
  static Future<bool> _isFirestoreWatchlist(int movieId) async {
    final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final userData = await userDoc.get();
    List<int> watchlist = List<int>.from(userData.data()?['watchlist'] ?? []);
    return watchlist.contains(movieId);
  }

  /// Checks if a movie is a favorite in local storage.
  static Future<bool> _isLocalFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    return favorites.contains(movieId.toString());
  }

  /// Checks if a movie is in the watchlist in local storage.
  static Future<bool> _isLocalWatchlist(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = prefs.getStringList('watchlist') ?? [];
    return watchlist.contains(movieId.toString());
  }

  /// Retrieves the list of favorite movie IDs from Firestore.
  static Future<List<int>> _getFirestoreFavorites() async {
    final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final userData = await userDoc.get();
    return List<int>.from(userData.data()?['favorites'] ?? []);
  }

  /// Retrieves the list of watchlist movie IDs from Firestore.
  static Future<List<int>> _getFirestoreWatchlist() async {
    final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final userData = await userDoc.get();
    return List<int>.from(userData.data()?['watchlist'] ?? []);
  }

  /// Retrieves the list of favorite movie IDs from local storage.
  static Future<List<int>> _getLocalFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    return favorites.map((e) => int.parse(e)).toList();
  }

  /// Retrieves the list of watchlist movie IDs from local storage.
  static Future<List<int>> _getLocalWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = prefs.getStringList('watchlist') ?? [];
    return watchlist.map((e) => int.parse(e)).toList();
  }

  /// Saves a movie poster image locally.
  ///
  /// [posterPath] is the path to the movie's poster image.
  /// [movieId] is the unique identifier of the movie.
  static Future<void> _saveImageLocally(String posterPath, int movieId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$movieId.jpg');

    if (!await file.exists()) {
      final response = await http
          .get(Uri.parse('https://image.tmdb.org/t/p/w200$posterPath'));
      await file.writeAsBytes(response.bodyBytes);
    }
  }

  /// Retrieves a locally saved movie poster image.
  ///
  /// Returns the [File] of the image if it exists, null otherwise.
  ///
  /// [movieId] is the unique identifier of the movie.
  static Future<File?> getLocalImage(int movieId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$movieId.jpg');

    if (await file.exists()) {
      return file;
    }
    return null;
  }
}
