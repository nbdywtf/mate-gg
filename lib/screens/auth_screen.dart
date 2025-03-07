import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mate_gg/theme/colors.dart';
import 'package:mate_gg/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nickname_screen.dart';
import '../main.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> _login() async {
    print("🔹 Login-Button wurde gedrückt");

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      print("⚠️ Email oder Passwort fehlt!");
      setState(() {
        errorMessage = "Bitte fülle alle Felder aus!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.login(emailController.text, passwordController.text);

      if (response.containsKey('token')) {
        print("✅ Login erfolgreich! Token: ${response['token']}");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', response['token']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        print("❌ Login fehlgeschlagen: ${response['message']}");
        setState(() {
          errorMessage = response['message'] ?? 'Login fehlgeschlagen';
        });
      }
    } catch (e) {
      print("❌ Fehler beim Login: $e");
      setState(() {
        errorMessage = "Fehler: ${e.toString()}";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _goToNicknameScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NicknameScreen(
          email: emailController.text,
          password: passwordController.text,
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/mate-logo.png', width: 100),

              const SizedBox(height: 20),

              Text(
                "Become a Mate today!",
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textWhiteColor,
                ),
              ),

              const SizedBox(height: 30),

              // E-Mail Input
              TextField(
                controller: emailController,
                style: TextStyle(color: Colors.white), // Textfarbe weiß
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: "E-Mail",
                  hintStyle: GoogleFonts.montserrat(color: Colors.white70), // leicht graue Hint-Farbe
                  prefixIcon: Icon(Icons.email, color: AppColors.accentColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.accentColor), // Standard-Border
                  ),
                  focusColor: AppColors.accentColor,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.accentColor, width: 2), // Aktiv-Border
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Passwort Input
              TextField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white), // Textfarbe weiß
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: "Password",
                  hintStyle: GoogleFonts.montserrat(color: Colors.white70), // leicht graue Hint-Farbe
                  prefixIcon: Icon(Icons.lock, color: AppColors.accentColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.accentColor), // Standard-Border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.accentColor, width: 2), // Aktiv-Border
                  ),
                ),
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 14)),
              ],

              const SizedBox(height: 20),

              Text(
                "Register or log in now!",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhiteColor,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "We don't send you no bs, promise. We just want to keep your account secure.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textWhiteColor,
                ),
              ),


              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? CircularProgressIndicator(color: AppColors.accentColor)
                      : OutlinedButton(
                    onPressed: _login,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.accentColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    ),
                    child: Text("Login", style: GoogleFonts.montserrat(color: AppColors.accentColor)),
                  ),

                  const SizedBox(width: 15),

                  ElevatedButton(
                    onPressed: _goToNicknameScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    ),
                    child: Text("Register", style: GoogleFonts.montserrat(color: AppColors.blueAccentColor)),
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
