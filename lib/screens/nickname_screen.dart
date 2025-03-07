import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mate_gg/services/api_service.dart';
import 'package:mate_gg/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class NicknameScreen extends StatefulWidget {
  final String email;
  final String password;

  NicknameScreen({required this.email, required this.password});

  @override
  _NicknameScreenState createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController nicknameController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> _registerAndLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // 🔹 Registrierung durchführen
      final response = await ApiService.register(widget.email, widget.password, nicknameController.text);

      if (response.containsKey('token')) {
        // 🔹 Token & Login-Status speichern
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', response['token']);

        // 🔹 Zur `HomeScreen` navigieren
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Fehler bei der Registrierung';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "❌ Fehler: ${e.toString()}";
      });
    }

    setState(() {
      isLoading = false;
    });
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/mate-logo.png', width: 100),

              const SizedBox(height: 20),

              Text("Welcome, newbie! What's your nickname?",
                  textAlign: TextAlign.center,
                  style:
                    GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhiteColor
                    )
              ),

              const SizedBox(height: 120),

              TextField(
                controller: nicknameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Nickname",
                  prefixIcon: Icon(Icons.person, color: AppColors.accentColor),
                ),
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 14)),
              ],

              const SizedBox(height: 20),

              isLoading
                  ? CircularProgressIndicator(color: AppColors.accentColor)
                  : OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accentColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
                onPressed: _registerAndLogin,
                child: Text("Registrieren", style: GoogleFonts.montserrat(color: AppColors.accentColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
