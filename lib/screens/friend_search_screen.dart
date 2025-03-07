import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mate_gg/services/api_service.dart';
import 'package:mate_gg/theme/colors.dart';

class FriendSearchScreen extends StatefulWidget {
  @override
  _FriendSearchScreenState createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> _searchPlayers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await ApiService.searchPlayers(searchController.text);
      print("📡 API Response: $results"); // 🔍 Debugging: Antwort loggen

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Fehler bei der Suche: $e"); // 🔍 Fehler loggen
      setState(() {
        errorMessage = "Fehler bei der Suche: $e";
        isLoading = false;
      });
    }
  }


  Future<void> _sendFriendRequest(String friendId) async {
    try {
      await ApiService.sendFriendRequest(friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Freundschaftsanfrage gesendet!"), backgroundColor: AppColors.accentColor),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Senden der Anfrage"), backgroundColor: Colors.red),
      );
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
          child: Column(
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
                    "Add a Mate",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhiteColor,
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search for players...",
                  hintStyle: GoogleFonts.montserrat(color: Colors.white70),
                  filled: true,
                  fillColor: AppColors.blueAccentColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: _searchPlayers,
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              isLoading
                  ? CircularProgressIndicator(color: AppColors.accentColor)
                  : errorMessage != null
                  ? Text(errorMessage!, style: TextStyle(color: Colors.red))
                  : Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final player = searchResults[index];
                    return Card(
                      color: AppColors.blueAccentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(player['nickname'], style: GoogleFonts.montserrat(color: Colors.white)),
                        subtitle: Text(player['email'], style: TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: Icon(Icons.person_add, color: AppColors.accentColor),
                          onPressed: () => _sendFriendRequest(player['id']),
                        ),
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
