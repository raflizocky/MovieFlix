# Movie Flix 🎬

**Movie Flix** is a mobile app for browsing world wide movies.

## Test

- Android ✅

## Demo

### Guest
<video src="https://github.com/user-attachments/assets/7ffde36d-9aa8-4c15-8638-4cb046698283"></video>

### Login/Register
<video src="https://github.com/user-attachments/assets/9a898330-9088-48eb-b3f8-0ad8bbff47e9"></video>

## Features

- Auth: Login, Register, Login as Guest
- Movies: Now Playing, Popular, Similar, Detail, Search
- Profile: Favorite & Watchlist Movies

## Download

- Updated at: 2024-12-13
- Download: [APK](https://github.com/raflizocky/MovieFlix/releases/download/v1.0.0/app-release.apk)

## Resources Used

- API: [TMDB API](https://www.themoviedb.org/settings/api)
- Code documentation: [Dart documentation](https://dart.dev/effective-dart/documentation)
- Firebase: Auth (email/password), Firestore (test mode)

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

## License

```
Copyright (c) 2024 Rafli Zocky Leonard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
