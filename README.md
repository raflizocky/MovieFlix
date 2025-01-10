## Demo

> Tested on: Android.

### Guest
<video src="https://github.com/user-attachments/assets/7ffde36d-9aa8-4c15-8638-4cb046698283"></video>

### Login/Register
<video src="https://github.com/user-attachments/assets/9a898330-9088-48eb-b3f8-0ad8bbff47e9"></video>

## Features

- Auth: Login, Register, Login as Guest
- Movies: Now Playing, Popular, Similar, Detail, Search
- Profile: Favorite & Watchlist Movies

## Pre-requisites

- Flutter SDK

## Download

- Min. Android version: Android 6.0 Marshmallow (API level 23)
- Download: [APK](https://github.com/raflizocky/MovieFlix/releases/download/v1.0.0/app-release.apk)

## Resources Used

- API: [TMDB API](https://www.themoviedb.org/settings/api)
- Code documentation: [Dart documentation](https://dart.dev/effective-dart/documentation)
- Firebase: Auth (email/password), Firestore

## Building

1. Clone the project and open it at your favorite text editor.

2. Open terminal, then run:

   ```
   flutter clean
   ```
   
   ```
   flutter pub get
   ```

3. Change the firebase project with your own:
  
   ```
   flutterfire configure
   ```

3. Create `dotenv` file at root, fill with the credentials of your TMDB & newly generated `firebase_options.dart`:

   ```
   # TMDB
   TMDB_BASE_URL=https://api.themoviedb.org/3
   TMDB_API_KEY=

   # Firebase Web Configuration
   WEB_API_KEY=
   WEB_APP_ID=
   WEB_MESSAGING_SENDER_ID=
   WEB_PROJECT_ID=
   WEB_AUTH_DOMAIN=
   WEB_STORAGE_BUCKET=
   WEB_MEASUREMENT_ID=

   # Firebase Android Configuration
   ANDROID_API_KEY=
   ANDROID_APP_ID=
   ANDROID_MESSAGING_SENDER_ID=
   ANDROID_PROJECT_ID=
   ANDROID_STORAGE_BUCKET=

   ...continue
   ```

4. Delete the newly generated `firebase_options.dart`.

5. Run the project:

   ```
   flutter run
   ```

6. Choose android platform.

## Contributing

If you encounter any issues or would like to contribute to the project, feel free to:

-   Report any [issues](https://github.com/raflizocky/MovieFlix/issues)
-   Submit a [pull request](https://github.com/raflizocky/MovieFlix/pulls)
-   Participate in [discussions](https://github.com/raflizocky/MovieFlix/discussions) for any questions, feedback, or suggestions

## License

Code released under the [MIT License](https://github.com/raflizocky/MovieFlix/blob/master/LICENSE).
