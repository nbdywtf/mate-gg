import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://portal.paalo.de/api'; // Anpassen

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // 📌 Nickname speichern, falls vorhanden
      if (data.containsKey('player')) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', data['token']);
        await prefs.setString('nickname', data['player']['nickname']); // 🔹 Nickname speichern
        await prefs.setString('user_id', data['player']['id'].toString()); //
      }

      return data;
    } else {
      throw Exception('Login fehlgeschlagen: ${response.body}');
    }
  }

  // 🔹 Registrierung mit Email, Passwort und Nickname
  static Future<Map<String, dynamic>> register(String email, String password, String nickname) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nickname': nickname,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registrierung fehlgeschlagen: ${response.body}');
    }
  }

  static Future<List<dynamic>> getFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception("Kein Token oder User-ID gespeichert. Bitte erneut einloggen.");
    }

    final url = Uri.parse('$baseUrl/friends?player_id=$userId'); // 🛠️ Korrektur: Spieler-ID übergeben!
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 🔹 Token senden
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Fehler beim Abrufen der Freundesliste: ${response.body}');
    }
  }

  static Future<List<dynamic>> searchPlayers(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id'); // 🔹 Spieler-ID holen

    if (userId == null) {
      throw Exception("Kein Benutzer eingeloggt.");
    }

    final url = Uri.parse('$baseUrl/players/search?search=$query&player_id=$userId'); // 🔹 Spieler-ID mitsenden
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'}, // ❌ Kein Token mehr nötig
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Abrufen der Spieler: ${response.body}');
    }
  }



  static Future<void> sendFriendRequest(String friendId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception("Nicht eingeloggt.");
    }

    final url = Uri.parse('$baseUrl/friends/request');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'player_id': userId,
        'friend_id': friendId,
        'status': 'pending', // 🛠 WICHTIG: Status explizit auf 'pending' setzen
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Fehler beim Senden der Freundschaftsanfrage: ${response.body}');
    }
  }

  static Future<List<dynamic>> getFriendRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception("Kein Token oder User-ID gespeichert. Bitte erneut einloggen.");
    }

    final url = Uri.parse('$baseUrl/friends/requests?player_id=$userId'); // 🔹 API für Anfragen
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Abrufen der Freundschaftsanfragen: ${response.body}');
    }
  }

  // 🔹 Freundschaftsanfrage annehmen
  static Future<void> acceptFriendRequest(String friendId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception("Nicht eingeloggt.");
    }

    final url = Uri.parse('$baseUrl/friends/accept');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'player_id': userId,
        'friend_id': friendId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Akzeptieren der Anfrage: ${response.body}');
    }
  }

// 🔹 Freundschaftsanfrage ablehnen
  static Future<void> declineFriendRequest(String friendId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception("Nicht eingeloggt.");
    }

    final url = Uri.parse('$baseUrl/friends/reject');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'player_id': userId,
        'friend_id': friendId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Ablehnen der Anfrage: ${response.body}');
    }
  }



  static Future<List<dynamic>> getGames() async {
    final url = Uri.parse('$baseUrl/games');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Abrufen der Spiele: ${response.body}');
    }
  }

  static Future<void> saveUserGames(List<int> gameIds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id'); // Spieler-ID holen

    if (token == null || userId == null) {
      throw Exception("Kein Token oder User-ID gespeichert. Bitte erneut einloggen.");
    }

    final url = Uri.parse('$baseUrl/user/games');
    final body = jsonEncode({
      'player_id': int.parse(userId), // Spieler-ID mitsenden!
      'games': gameIds
    });

    print("📡 Sende API-Request an: $url");
    print("🔑 Authorization: Bearer $token");
    print("📦 Request-Body: $body");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    print("📩 API Response Code: ${response.statusCode}");
    print("📩 API Response Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Speichern der Spiele: ${response.body}');
    }
  }

  static Future<List<int>> getUserGames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id'); // Spieler-ID holen

    if (token == null || userId == null) {
      throw Exception("Kein Token oder User-ID gespeichert. Bitte erneut einloggen.");
    }

    final url = Uri.parse('$baseUrl/user/games?player_id=$userId');

    print("📡 Abrufen der gespeicherten Spiele von: $url");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("📩 API Response Code: ${response.statusCode}");
    print("📩 API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // **String-IDs zu Integer konvertieren**
      return List<int>.from(data['games'].map((gameId) => int.tryParse(gameId.toString()) ?? 0));
    } else {
      throw Exception('Fehler beim Abrufen der gespeicherten Spiele: ${response.body}');
    }
  }

  static Future<List<dynamic>> getUserGamesWithDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception("Kein Token oder User-ID gespeichert. Bitte erneut einloggen.");
    }

    // ✅ Gespeicherte Spiel-IDs abrufen
    final url = Uri.parse('$baseUrl/user/games?player_id=$userId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<int> gameIds = List<int>.from(data['games'].map((gameId) => int.tryParse(gameId.toString()) ?? 0));

      // ✅ ALLE Spiele aus der API abrufen
      List<dynamic> allGames = await getGames();

      // ✅ Nur die gespeicherten Spiele behalten
      List<dynamic> userGames = allGames.where((game) {
        int gameId = int.tryParse(game['id'].toString()) ?? 0;
        return gameIds.contains(gameId);
      }).toList();

      return userGames;
    } else {
      throw Exception('Fehler beim Abrufen der gespeicherten Spiele: ${response.body}');
    }
  }



  static Future<void> removeUserGame(int gameId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id'); // Spieler-ID holen

    if (token == null) {
      throw Exception("Kein Token gespeichert. Bitte erneut einloggen.");
    }

    final url = Uri.parse('$baseUrl/user/games/$gameId'); // API zum Entfernen eines Spiels

    print("📡 Lösche Spiel: $gameId von $url");

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("📩 API Response Code: ${response.statusCode}");
    print("📩 API Response Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Entfernen des Spiels: ${response.body}');
    }
  }

  static Future<void> updateUserProfile(String name, String email, String? password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception("Nicht eingeloggt.");
    }

    final url = Uri.parse('$baseUrl/user/update');
    final body = jsonEncode({
      'player_id': userId,
      'nickname': name,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
    });

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Speichern des Profils: ${response.body}');
    }
  }

// 🔹 Account löschen
  static Future<void> deleteAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception("Nicht eingeloggt.");
    }

    final url = Uri.parse('$baseUrl/user/delete/$userId');

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Löschen des Accounts: ${response.body}');
    }
  }

  static Future<void> createSession({
    required String name,
    required int ownerId,
    required int gameId,
    required DateTime sessionDatetime,
    required int duration,
    required String location,
    required String locationInfo,
    required String description,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Kein Token gefunden. Bitte erneut einloggen.");
    }

    final url = Uri.parse('$baseUrl/sessions');
    final body = jsonEncode({
      'name': name,
      'owner_id': ownerId,
      'game_id': gameId,
      'session_datetime': sessionDatetime.toIso8601String(),
      'duration': duration,
      'location': location,
      'location_info': locationInfo,
      'description': description, // ✅ Beschreibung mitsenden
    });

    print("📡 API Request: $body"); // 🔍 Debugging

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    print("📩 API Response Code: ${response.statusCode}");
    print("📩 API Response Body: ${response.body}");

    if (response.statusCode != 201) {
      throw Exception('Fehler beim Erstellen der Session: ${response.body}');
    }
  }


  static Future<Map<String, dynamic>> getSessionDetails(int sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/sessions/$sessionId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Abrufen der Session-Daten: ${response.body}');
    }
  }

  static Future<void> leaveSession(int sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Kein Token gespeichert. Bitte erneut einloggen.");
    }

    final url = Uri.parse('$baseUrl/sessions/$sessionId/leave');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Verlassen der Session: ${response.body}');
    }
  }


  static Future<Map<String, dynamic>> getMySessions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("Kein Benutzer eingeloggt.");
    }

    final url = Uri.parse('$baseUrl/sessions?player_id=$userId');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data; // ✅ Korrekt: Rückgabe als Map mit my_sessions und invited_sessions
      } else {
        throw Exception("Unerwartetes API-Format: ${response.body}");
      }
    } else {
      throw Exception('Fehler beim Abrufen der Sessions: ${response.body}');
    }
  }




  static Future<void> joinSession(int sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("Kein Benutzer eingeloggt.");
    }

    final url = Uri.parse('$baseUrl/sessions/join');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'session_id': sessionId, 'player_id': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Beitreten der Session: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id'); // 🔹 Holen der gespeicherten User-ID

    if (userId == null) {
      throw Exception("Kein Benutzer eingeloggt.");
    }

    final url = Uri.parse('$baseUrl/players/profile?player_id=$userId');
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Abrufen des Profils: ${response.body}');
    }
  }



}
