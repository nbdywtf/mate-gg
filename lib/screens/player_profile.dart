import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mate_gg/services/api_service.dart';
import 'package:mate_gg/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerProfileScreen extends StatefulWidget {
  @override
  _PlayerProfileScreenState createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // 🔹 Nutzerdaten laden
  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('nickname') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
    });
  }

  // 🔹 Profil aktualisieren
  Future<void> _saveProfile() async {
    setState(() => isLoading = true);

    try {
      await ApiService.updateUserProfile(
        _nameController.text,
        _emailController.text,
        _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', _nameController.text);
      await prefs.setString('email', _emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil erfolgreich aktualisiert!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Speichern!"), backgroundColor: Colors.red),
      );
    }

    setState(() => isLoading = false);
  }

  // 🔹 Account löschen
  Future<void> _deleteAccount() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Account löschen?"),
        content: Text("Bist du sicher, dass du deinen Account löschen möchtest?"),
        actions: [
          TextButton(child: Text("Abbrechen"), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: Text("Löschen", style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (confirm) {
      try {
        await ApiService.deleteAccount();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushReplacementNamed(context, "/login");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fehler beim Löschen des Accounts!"), backgroundColor: Colors.red),
        );
      }
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 10),
                  Text("Edit your profile", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 30),

              // 🔹 Name
              _buildTextField("Your Name", _nameController),

              // 🔹 E-Mail
              _buildTextField("Your Mail", _emailController),

              // 🔹 Passwort (optional)
              _buildTextField("Your Password", _passwordController, obscureText: true),

              // 🔹 Account löschen
              TextButton(
                onPressed: _deleteAccount,
                child: Text("Delete Account", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline)),
              ),

              Spacer(),

              // 🔹 Speichern-Button
              ElevatedButton(
                onPressed: isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("SAVE CHANGES", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.blueAccentColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}
