import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mate_gg/screens/friendlist.dart';
import 'package:mate_gg/screens/gamecollection.dart';
import 'package:mate_gg/screens/player_profile.dart';
import 'package:mate_gg/screens/session_controller.dart';
import 'package:mate_gg/screens/session_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mate_gg/screens/auth_screen.dart';
import 'package:mate_gg/services/api_service.dart';
import 'package:mate_gg/theme/colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      isLoggedIn = loggedIn;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.purpleAccentColor,
          body: Center(child: CircularProgressIndicator(color: AppColors.accentColor)),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mate - Play with friends',
      theme: ThemeData(
        fontFamily: GoogleFonts.montserrat().fontFamily,
        primaryColor: AppColors.accentColor,
        scaffoldBackgroundColor: AppColors.purpleAccentColor,
        colorScheme: ColorScheme.light(
          primary: AppColors.accentColor, // ✅ Hier auch primary setzen
          secondary: AppColors.accentColor,
        ),

        // 🔹 Fokusfarbe für Textfelder & Eingabeelemente ändern
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.accentColor, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.purpleAccentColor, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          labelStyle: TextStyle(color: AppColors.accentColor), // Labels in neuer Farbe
          focusColor: AppColors.accentColor, // Standard-Fokusfarbe ändern
        ),

        // 🔹 `DatePicker`-Farbe anpassen
        datePickerTheme: DatePickerThemeData(
          backgroundColor: AppColors.purpleAccentColor,
          headerForegroundColor: Colors.white,
          dividerColor: AppColors.accentColor,
          todayForegroundColor: MaterialStateProperty.all(AppColors.purpleAccentColor),
        ),

        // 🔹 `TimePicker`-Farbe anpassen
        timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColors.purpleAccentColor,
          hourMinuteTextColor: AppColors.purpleAccentColor,
          dialHandColor: AppColors.accentColor,
          entryModeIconColor: AppColors.accentColor,
        ),
      ),
      home: isLoggedIn ? HomeScreen() : AuthScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nickname = "Mate";
  List<dynamic> userGames = [];
  int selectedGameIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.8);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserGames();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserGames(); // 🔄 Spieleliste aktualisieren, wenn zurückgekehrt wird
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nickname = prefs.getString('nickname') ?? "Mate";
    });
  }

  Future<void> _loadUserGames() async {
    try {
      List<dynamic> games = await ApiService.getUserGamesWithDetails();
      setState(() {
        userGames = games;
      });
    } catch (e) {
      print("❌ Fehler beim Laden der gespeicherten Spiele: $e");
    }
  }


  void _setSelectedGame(int index) {
    setState(() {
      selectedGameIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('token');
    await prefs.remove('nickname');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.person_outline_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PlayerProfileScreen()),
                      );
                    },
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          softWrap: true,
                          text: TextSpan(
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhiteColor,
                            ),
                            children: [
                              TextSpan(text: "Yo "),
                              TextSpan(
                                text: nickname,
                                style: TextStyle(color: AppColors.accentColor),
                              ),
                              TextSpan(text: ", what do you want to play today?"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: Icon(Icons.logout_sharp, color: Colors.white),
                    onPressed: () => _logout(context),
                  ),
                ],
              ),

              // 🔹 PageView Karussell
              userGames.isNotEmpty
                  ? Column(
                children: [
                  SizedBox(
                    height: 450,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: userGames.length,
                      onPageChanged: (index) {
                        _setSelectedGame(index);
                      },
                      itemBuilder: (context, index) {
                        final game = userGames[index];
                        final bool isSelected = index == selectedGameIndex;

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Image.network(
                                  game['image'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (userGames.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateSessionScreen(
                              gameId: int.tryParse(userGames[selectedGameIndex]['id'].toString()) ?? 0, // 🔹 Stelle sicher, dass gameId ein `int` ist!
                              gameName: userGames[selectedGameIndex]['name'], // Spielname als String
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Kein Spiel ausgewählt!"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Play ${userGames.isNotEmpty ? userGames[selectedGameIndex]['name'] : 'Game'}",
                      style: GoogleFonts.montserrat(
                        color: AppColors.blueAccentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),


                ],
              )
                  : Text(
                "No games selected.",
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              // 🔹 Icons bleiben am unteren Bildschirmrand
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.people_outline_sharp, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FriendListScreen()));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.gas_meter_outlined, color: Colors.white),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => GameCollectionScreen()),
                      );
                      _loadUserGames(); // 🔄 Nach Rückkehr Spiele aktualisieren
                    },
                  ),

                  IconButton(
                    icon: Icon(Icons.filter_list_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SessionListScreen()));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
