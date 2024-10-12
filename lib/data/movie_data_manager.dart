import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MovieDataManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> toggleFavorite(int movieId, String posterPath) async {
    if (_auth.currentUser != null) {
      await _toggleFirestoreFavorite(movieId);
    } else {
      await _toggleLocalFavorite(movieId);
    }
    await _saveImageLocally(posterPath, movieId);
  }

  static Future<void> toggleWatchlist(int movieId, String posterPath) async {
    if (_auth.currentUser != null) {
      await _toggleFirestoreWatchlist(movieId);
    } else {
      await _toggleLocalWatchlist(movieId);
    }
    await _saveImageLocally(posterPath, movieId);
  }

  static Future<bool> isFavorite(int movieId) async {
    if (_auth.currentUser != null) {
      return await _isFirestoreFavorite(movieId);
    } else {
      return await _isLocalFavorite(movieId);
    }
  }

  static Future<bool> isWatchlist(int movieId) async {
    if (_auth.currentUser != null) {
      return await _isFirestoreWatchlist(movieId);
    } else {
      return await _isLocalWatchlist(movieId);
    }
  }

  static Future<List<int>> getFavorites() async {
    if (_auth.currentUser != null) {
      return await _getFirestoreFavorites();
    } else {
      return await _getLocalFavorites();
    }
  }

  static Future<List<int>> getWatchlist() async {
    if (_auth.currentUser != null) {
      return await _getFirestoreWatchlist();
    } else {
      return await _getLocalWatchlist();
    }
  }

  static Future<void> handleUserLogin() async {
    await _clearLocalData();
  }

  static Future<void> handleUserLogout() async {
    await _clearLocalData();
  }

  static Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favorites');
    await prefs.remove('watchlist');
  }

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

  static Future<bool> _isFirestoreFavorite(int movieId) async {
    final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final userData = await userDoc.get();
    List<int> favorites = List<int>.from(userData.data()?['favorites'] ?? []);
    return favorites.contains(movieId);
  }

  static Future<bool> _isFirestoreWatchlist(int movieId) async {
    final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final userData = await userDoc.get();
    List<int> watchlist = List<int>.from(userData.data()?['watchlist'] ?? []);
    return watchlist.contains(movieId);
  }

  static Future<bool> _isLocalFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    return favorites.contains(movieId.toString());
  }

  static Future<bool> _isLocalWatchlist(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = prefs.getStringList('watchlist') ?? [];
    return watchlist.contains(movieId.toString());
  }

  static Future<List<int>> _getFirestoreFavorites() async {
    final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final userData = await userDoc.get();
    return List<int>.from(userData.data()?['favorites'] ?? []);
  }

  static Future<List<int>> _getFirestoreWatchlist() async {
    final userDoc = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final userData = await userDoc.get();
    return List<int>.from(userData.data()?['watchlist'] ?? []);
  }

  static Future<List<int>> _getLocalFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    return favorites.map((e) => int.parse(e)).toList();
  }

  static Future<List<int>> _getLocalWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = prefs.getStringList('watchlist') ?? [];
    return watchlist.map((e) => int.parse(e)).toList();
  }

  static Future<void> _saveImageLocally(String posterPath, int movieId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$movieId.jpg');

    if (!await file.exists()) {
      final response = await http
          .get(Uri.parse('https://image.tmdb.org/t/p/w200$posterPath'));
      await file.writeAsBytes(response.bodyBytes);
    }
  }

  static Future<File?> getLocalImage(int movieId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$movieId.jpg');

    if (await file.exists()) {
      return file;
    }
    return null;
  }
}
