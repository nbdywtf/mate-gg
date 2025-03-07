import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mate_gg/services/api_service.dart';
import 'package:mate_gg/theme/colors.dart';

class SessionViewScreen extends StatefulWidget {
  final int sessionId;

  SessionViewScreen({required this.sessionId});

  @override
  _SessionViewScreenState createState() => _SessionViewScreenState();
}

class _SessionViewScreenState extends State<SessionViewScreen> {
  Map<String, dynamic>? sessionData;
  List<dynamic> participants = [];
  List<dynamic> sessionLog = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSessionDetails();
  }

  Future<void> _loadSessionDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print("📡 Lade Session mit ID: ${widget.sessionId}"); // ✅ Debug-Ausgabe

      final data = await ApiService.getSessionDetails(widget.sessionId);

      print("📩 API Response: $data"); // ✅ API Response ausgeben

      if (data == null || !data.containsKey('session')) {
        throw Exception("Ungültige Session-Daten erhalten.");
      }

      setState(() {
        sessionData = data['session'];
        participants = data['participants'] ?? [];
        sessionLog = data['log'] ?? [];
        isLoading = false;
      });

      print("✅ Session geladen: $sessionData");
      print("✅ Teilnehmer: $participants");
      print("✅ Session-Log: $sessionLog");

    } catch (e) {
      print("❌ Fehler beim Laden der Session: $e");
      setState(() {
        errorMessage = "Fehler beim Laden der Session: $e";
        isLoading = false;
      });
    }
  }


  Future<void> _leaveSession() async {
    try {
      await ApiService.leaveSession(widget.sessionId);
      Navigator.pop(context); // Zurück zur vorherigen Seite
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Verlassen der Session."), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _inviteFriends() async {
    // Hier die Logik für das Einladen von Freunden implementieren
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
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.accentColor))
            : errorMessage != null
            ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header mit Zurück-Button und Optionen
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    sessionData!['name'],
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhiteColor,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (String value) {
                      if (value == 'leave') {
                        _leaveSession();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'leave',
                        child: Text('Leave Session'),
                      ),
                    ],
                  ),
                ],
              ),

              Center(
                child: Text(
                  sessionData!['game_name'].toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.accentColor,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Infotext
              Center(
                child: Text(
                  sessionData!['description'] ?? "No description available",
                  style: GoogleFonts.montserrat(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Dauer & Location
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: AppColors.accentColor),
                          const SizedBox(width: 5),
                          Text("For ${sessionData!['duration']} hours",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentColor,
                              )),
                        ],
                      ),
                      Text(
                        "on ${sessionData!['session_datetime']?? "Unknown date"}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: AppColors.accentColor),
                          const SizedBox(width: 5),
                          Text(sessionData!['location'],
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentColor,
                              )),
                        ],
                      ),
                      Text(sessionData!['location_info'],
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 50),

              Row(
                children: participants.map((participant) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accentColor, // 🔹 Border in deiner Accent-Farbe
                              width: 2, // 🔹 Dicke der Border
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30, // 🔹 Größe des Avatars
                            backgroundColor: AppColors.purpleAccentColor,
                            child: Image.asset('assets/mate-logo.png', width: 30),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          participant['nickname'],
                          style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 🔹 Session Log (Wer ist beigetreten?)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.purpleAccentColor, // 🎨 Hintergrundfarbe für den gesamten Bereich
                    borderRadius: BorderRadius.circular(20), // Abgerundete Ecken für den Container
                  ),
                  padding: EdgeInsets.all(5), // Optional: Innenabstand
                  child: ListView.builder(
                    itemCount: sessionLog.length,
                    itemBuilder: (context, index) {
                      final log = sessionLog[index];
                      return Card(
                        color: AppColors.purpleAccentColor,
                        shadowColor: Colors.transparent,
                        child: ListTile(
                          title: Row(
                            children: [
                              Text("${log['player_name']}",
                                  style: GoogleFonts.montserrat(color: AppColors.accentColor, fontWeight: FontWeight.bold)),
                              Text(" joined the session!",
                                  style: GoogleFonts.montserrat(color: Colors.white)),
                            ],
                          ),
                          subtitle: log['message'] != null && log['message'].isNotEmpty
                              ? Text(log['message'] ?? "", style: TextStyle(color: Colors.white70))
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 🔹 Freunde einladen Button
              ElevatedButton(
                onPressed: _inviteFriends,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "INVITE YOUR FRIENDS TO MATE.GG",
                  style: GoogleFonts.montserrat(
                    color: AppColors.blueAccentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
