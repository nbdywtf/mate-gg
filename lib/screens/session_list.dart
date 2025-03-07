import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mate_gg/services/api_service.dart';
import 'package:mate_gg/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_view.dart';

class SessionListScreen extends StatefulWidget {
  @override
  _SessionListScreenState createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  List<dynamic> mySessions = [];
  List<dynamic> invitedSessions = [];
  bool isLoading = true;
  String? errorMessage;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndSessions();
  }

  Future<void> _loadUserIdAndSessions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });

    if (userId != null) {
      _loadSessions();
    } else {
      setState(() {
        errorMessage = "Kein Benutzer eingeloggt.";
        isLoading = false;
      });
    }
  }

  Future<void> _loadSessions() async {
    try {
      final sessionData = await ApiService.getMySessions();

      setState(() {
        mySessions = sessionData['my_sessions'] ?? [];  // ✅ Korrekt: Liste extrahieren
        invitedSessions = sessionData['invited_sessions'] ?? [];  // ✅ Korrekt: Liste extrahieren
        isLoading = false;
      });

      print("✅ My Sessions: $mySessions");
      print("✅ Invited Sessions: $invitedSessions");

    } catch (e) {
      print("❌ Fehler in session_list.dart: $e");
      setState(() {
        errorMessage = "Fehler beim Laden der Sessions: $e";
        isLoading = false;
      });
    }
  }



  Future<void> _joinSession(int sessionId) async {
    try {
      await ApiService.joinSession(sessionId);
      _loadSessions(); // 🔄 Liste aktualisieren
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Beitreten der Session."), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildSessionCard(Map<String, dynamic> session, bool isOwnSession) {
    bool isJoined = (session['is_joined'] ?? false) as bool;
    bool isLive = (session['is_live'] ?? false) as bool;
    String liveTime = session['live_time'] ?? "unknown";
    String sessionTime = session['session_time'] ?? "unknown";
    print("🎮 Session: ${session['name']} | Game: ${session['game_name']} | Owner: ${session['owner_nickname']}  | Sessiontime: ${session['sessionTime']}");


    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SessionViewScreen(sessionId: session['id'])),
        );
      },
      child: Card(
        color: AppColors.purpleAccentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentColor, // 🔹 Border in deiner Accent-Farbe
                width: 2, // 🔹 Dicke der Border
              ),
            ),
            child: CircleAvatar(
              radius: 22, // 🔹 Größe des Avatars
              backgroundColor: AppColors.purpleAccentColor,
              child: Image.asset('assets/mate-logo.png', width: 20),
            ),
          ),
          title: Text(
            isOwnSession ? "Your Session" : "${session['owner_nickname']}'s Session",
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          subtitle: Text(
            "${session['game_name']} ${isLive ? "live for $liveTime" : "at $sessionTime"}",
            style: GoogleFonts.montserrat(color: Colors.white70),
          ),
          trailing: isJoined
              ? GestureDetector(
            onTap: () {
              // ✅ Sicherstellen, dass die ID als int übergeben wird
              int sessionId = int.tryParse(session['id'].toString()) ?? 0;

              if (sessionId > 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SessionViewScreen(sessionId: sessionId)),
                );
              } else {
                print("⚠ Fehler: Ungültige Session-ID");
              }
            },
            child: Icon(Icons.check_circle, color: AppColors.accentColor, size: 30),
          )
              : IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.accentColor, size: 30),
            onPressed: () => _joinSession(session['id']),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundGradientStart,
              AppColors.backgroundGradientMiddle1,
              AppColors.backgroundGradientMiddle2,
              AppColors.backgroundGradientEnd,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.accentColor))
              : errorMessage != null
              ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context), // Menü-Logik
                  ),
                  Text(
                    "Sessions",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhiteColor,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 10),

              // 🔹 Eigene Sessions
              if (mySessions.isNotEmpty) ...[
                Center(
                  child: Text("Your Sessions",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
                const SizedBox(height: 5),
                ...mySessions.map((session) => _buildSessionCard(session, true)).toList(),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 30),
              // 🔹 Eingeladene Sessions
              if (invitedSessions.isNotEmpty) ...[
                Center(
                  child: Text("Invited Sessions",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
                const SizedBox(height: 5),
                ...invitedSessions
                    .map((session) => _buildSessionCard(session, false))
                    .toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
