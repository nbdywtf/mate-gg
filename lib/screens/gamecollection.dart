import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mate_gg/services/api_service.dart';
import 'package:mate_gg/theme/colors.dart';

class GameCollectionScreen extends StatefulWidget {
  @override
  _GameCollectionScreenState createState() => _GameCollectionScreenState();
}

class _GameCollectionScreenState extends State<GameCollectionScreen> {
  List<dynamic> allGames = []; // Original-Spieleliste
  List<dynamic> filteredGames = []; // Gefilterte Spieleliste
  Set<int> selectedGames = {}; // 💾 Speichert die gewählten Spiele (IDs)
  bool isLoading = true;
  String? errorMessage;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGames();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }



  // Spiele aus der API laden
  Future<void> _loadGames() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<dynamic> fetchedGames = await ApiService.getGames();
      List<int> savedGames = await ApiService.getUserGames(); // ✅ Gespeicherte Spiele abrufen

      setState(() {
        allGames = fetchedGames;
        filteredGames = fetchedGames;
        selectedGames = savedGames.toSet(); // ✅ Gespeicherte Spiele markieren
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Fehler beim Laden der Spiele";
        isLoading = false;
      });
    }
  }


  // 🔍 Suche aktualisieren
  void _onSearchChanged() {
    String query = searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredGames = allGames; // Vollständige Liste wiederherstellen
      } else {
        filteredGames = allGames.where((game) {
          return game['name'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // ✅ Spiel markieren oder abwählen
  void _toggleSelection(int gameId) {
    setState(() {
      if (selectedGames.contains(gameId)) {
        selectedGames.remove(gameId);
        _removeGameFromDatabase(gameId); // 🛠 Spiel aus der DB entfernen
      } else {
        selectedGames.add(gameId);
      }
    });
  }

// 🛠 API-Request zum Entfernen eines Spiels
  Future<void> _removeGameFromDatabase(int gameId) async {
    try {
      await ApiService.removeUserGame(gameId);
      print("🗑 Spiel entfernt: $gameId");
    } catch (e) {
      print("❌ Fehler beim Entfernen des Spiels: $e");
    }
  }



  // 🔹 Spiele speichern per API
  Future<void> _saveSelection() async {
    if (selectedGames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Keine Spiele ausgewählt ❌")),
      );
      return;
    }

    try {
      print("📡 Speichere Spiele: ${selectedGames.toList()}"); // Debugging

      await ApiService.saveUserGames(selectedGames.toList());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Spiele erfolgreich gespeichert! ✅")),
      );
    } catch (e) {
      print("❌ Fehler beim Speichern: $e"); // Fehler ausgeben
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Speichern ❌")),
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
              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // 🔹 Zur vorherigen Seite zurückgehen
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Choose the games you play the most.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhiteColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // 🔍 Suchfeld
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search for a Game",
                  hintStyle: GoogleFonts.montserrat(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: AppColors.blueAccentColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              // 🎮 Spieleliste
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.accentColor))
                    : errorMessage != null
                    ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
                    : filteredGames.isEmpty
                    ? Center(child: Text("Keine Spiele gefunden", style: GoogleFonts.montserrat()))
                    : GridView.builder(
                  shrinkWrap: true, // 🔹 Verhindert RenderBox-Fehler
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Anzahl der Spalten
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: filteredGames.length,
                  itemBuilder: (context, index) {
                    final game = filteredGames[index];
                    final int gameId = int.tryParse(game['id'].toString()) ?? 0;
                    final bool isSelected = selectedGames.contains(gameId);


                    return GestureDetector(
                      onTap: () => _toggleSelection(gameId),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              game['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image, color: Colors.white),
                            ),
                          ),

                          // ✅ Markierung (Wenn ausgewählt)
                          if (isSelected)
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.accentColor.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.check_circle, color: Colors.white, size: 40),
                            ),

                          // 🎮 Spielname als Overlay (Fix)
                          Positioned(
                            bottom: 5,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.accentColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                game['name'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  color: AppColors.blueAccentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ✅ READY BUTTON
              ElevatedButton(
                onPressed: _saveSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text("SAVE", style: GoogleFonts.montserrat(color: AppColors.blueAccentColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
