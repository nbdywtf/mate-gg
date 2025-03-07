import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mate_gg/services/api_service.dart';
import 'package:mate_gg/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateSessionScreen extends StatefulWidget {
  final int gameId;
  final String gameName;

  CreateSessionScreen({required this.gameId, required this.gameName});

  @override
  _CreateSessionScreenState createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationInfoController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();
  double sessionDuration = 2.0;
  String selectedLocation = "Discord";

  Future<void> _createSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Nicht eingeloggt."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      await ApiService.createSession(
        name: _sessionNameController.text,
        ownerId: int.parse(userId),
        gameId: widget.gameId,
        sessionDatetime: selectedDateTime,
        duration: sessionDuration.toInt(),
        location: selectedLocation,
        locationInfo: _locationInfoController.text,
        description: _descriptionController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Session erfolgreich erstellt!"),
        backgroundColor: AppColors.accentColor,
      ));
      Navigator.pop(context); // Zurück zur vorherigen Seite
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Fehler beim Erstellen der Session."),
        backgroundColor: Colors.red,
      ));
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
                    TextSpan(text: "Tell your Mates about your "),
                    TextSpan(
                      text: "${widget.gameName}",
                      style: TextStyle(color: AppColors.accentColor),
                    ),
                    TextSpan(text: " Session!"),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // 🔹 Session Name Eingabe
              _buildTextField("Session Name", _sessionNameController),

              // 🔹 Datumsauswahl
              Text("The Session starts", style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white)),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.blueAccentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(DateFormat('EEE, d MMM HH:mm').format(selectedDateTime), style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Dauer Slider
              Text("The Session will last for ${sessionDuration.toInt()} hours", style: TextStyle(color: Colors.white)),
              Slider(
                value: sessionDuration,
                min: 1,
                max: 5,
                divisions: 4,
                label: "${sessionDuration.toInt()} hours",
                onChanged: (value) {
                  setState(() {
                    sessionDuration = value;
                  });
                },
              ),

              // 🔹 Beschreibung
              _buildTextField("Some warm words to your Mates?", _descriptionController),

              // 🔹 Treffpunkt
              Text("Where do you meet?", style: TextStyle(color: Colors.white)),
              Wrap(
                spacing: 10,
                children: ["Discord", "Teamspeak", "other"].map((option) {
                  return ChoiceChip(
                    label: Text(option),
                    selected: selectedLocation == option,
                    onSelected: (selected) {
                      setState(() {
                        selectedLocation = option;
                      });
                    },
                  );
                }).toList(),
              ),
              _buildTextField("Type further info here (optional)", _locationInfoController),

              Spacer(),

              // 🔹 Start Button
              ElevatedButton(
                onPressed: _createSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text("START SESSION!", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
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
