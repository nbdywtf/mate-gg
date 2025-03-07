  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:mate_gg/theme/colors.dart';
  import 'package:mate_gg/services/api_service.dart';

import 'friend_search_screen.dart';

  class FriendListScreen extends StatefulWidget {
    @override
    _FriendListScreenState createState() => _FriendListScreenState();
  }

  class _FriendListScreenState extends State<FriendListScreen> {
    List<dynamic> friends = [];
    List<dynamic> friendRequests = []; // 🔹 NEU: Liste für Freundschaftsanfragen
    bool isLoading = true;
    String? errorMessage;

    @override
    void initState() {
      super.initState();
      _loadFriends();
      _loadFriendRequests(); // 🔹 Freundschaftsanfragen laden
    }

    // 🔹 Freundesliste laden
    Future<void> _loadFriends() async {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        List<dynamic> fetchedFriends = await ApiService.getFriends();
        setState(() {
          friends = fetchedFriends;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          errorMessage = "Fehler beim Laden der Freundesliste";
          isLoading = false;
        });
      }
    }

    // 🔹 Freundschaftsanfragen laden
    Future<void> _loadFriendRequests() async {
      try {
        List<dynamic> requests = await ApiService.getFriendRequests();
        setState(() {
          friendRequests = requests;
        });
      } catch (e) {
        print("❌ Fehler beim Laden der Anfragen: $e");
      }
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
                : friends.isEmpty
                ? Center(child: Text("Keine Freunde gefunden", style: GoogleFonts.montserrat()))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 🔹 Überschrift links ausrichten
              children: [
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // 🔹 Zur vorherigen Seite zurückgehen
                      },
                    ),
                    Text(
                      "Your Mates",
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhiteColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FriendSearchScreen()),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 🔹 Freundschaftsanfragen anzeigen
                if (friendRequests.isNotEmpty) ...[
                  Column(
                    children: [
                      Text('Mate requests', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: friendRequests.length,
                        itemBuilder: (context, index) {
                          final request = friendRequests[index];
                          return Card(
                            color: AppColors.blueAccentColor,
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
                              title: Text(request['nickname'], style: GoogleFonts.montserrat(color: Colors.white)),
                              subtitle: Text(request['email'], style: TextStyle(color: Colors.white70)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (request['status'] == 'pending' && request['incoming']) ...[
                                    IconButton(
                                      icon: Icon(Icons.check, color: Colors.green),
                                      onPressed: () async {
                                        await ApiService.acceptFriendRequest(request['id']);
                                        _loadFriends(); // 🔄 Freunde neu laden
                                        _loadFriendRequests();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.red),
                                      onPressed: () async {
                                        await ApiService.declineFriendRequest(request['id']);
                                        _loadFriendRequests();
                                      },
                                    ),
                                  ],
                                  if (request['status'] == 'pending' && !request['incoming'])
                                    Text("Pending", style: TextStyle(color: AppColors.accentColor)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],

                Center(child: Text('Mates', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18))),

                // 🔹 Freundesliste
                Expanded(
                  child: ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return Card(
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
                          title: Text(friend['nickname'], style: GoogleFonts.montserrat(color: Colors.white)),
                          subtitle: Text(friend['email'], style: TextStyle(color: Colors.white70)),
                          trailing: Icon(Icons.cancel_sharp, color: Colors.red), // 🔹 Entfernen-Icon für später
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        ),
      );
    }
  }
