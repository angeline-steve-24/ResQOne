import 'package:flutter/material.dart';
import 'first_aid_detail_screen.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      {
        "title": "Road Accident",
        "subtitle": "Immediate actions after a road accident",
        "icon": Icons.car_crash,
        "color": Colors.orange,
        "dos": [
          "Ensure your own safety first.",
          "Call 108 immediately.",
          "Switch off the vehicle if safe.",
          "Check if the victim is breathing.",
          "Control heavy bleeding using a clean cloth.",
          "Stay with the injured person until help arrives.",
        ],
        "donts": [
          "Do not move a victim with suspected spinal injuries.",
          "Do not remove a helmet unless breathing is blocked.",
          "Do not give food or water.",
          "Do not crowd around the victim.",
        ],
      },
      {
        "title": "Heavy Bleeding",
        "subtitle": "Stop severe bleeding safely",
        "icon": Icons.bloodtype,
        "color": Colors.red,
        "dos": [
          "Apply firm pressure using a clean cloth.",
          "Raise the injured limb if possible.",
          "Call 108 immediately.",
        ],
        "donts": [
          "Do not remove embedded objects.",
          "Do not repeatedly lift the cloth.",
        ],
      },
      {
        "title": "Fracture",
        "subtitle": "Protect broken bones",
        "icon": Icons.personal_injury,
        "color": Colors.blue,
        "dos": [
          "Keep the injured limb still.",
          "Use a splint if available.",
          "Apply a cold pack wrapped in cloth.",
          "Seek medical help.",
        ],
        "donts": [
          "Do not straighten the bone.",
          "Do not move the victim unnecessarily.",
        ],
      },
      {
        "title": "Burns",
        "subtitle": "Treat burns correctly",
        "icon": Icons.local_fire_department,
        "color": Colors.deepOrange,
        "dos": [
          "Cool the burn with running water for 20 minutes.",
          "Cover with a clean cloth.",
          "Remove rings or watches before swelling.",
        ],
        "donts": [
          "Do not apply toothpaste.",
          "Do not apply butter or oil.",
          "Do not burst blisters.",
        ],
      },
      {
        "title": "CPR",
        "subtitle": "Help when someone is unconscious",
        "icon": Icons.favorite,
        "color": Colors.pink,
        "dos": [
          "Check responsiveness.",
          "Call 108.",
          "Begin chest compressions if trained.",
          "Continue until help arrives.",
        ],
        "donts": [
          "Do not stop unless the person recovers or professionals arrive.",
        ],
      },
      {
        "title": "Helmet Removal",
        "subtitle": "Motorcycle accident safety",
        "icon": Icons.health_and_safety,
        "color": Colors.indigo,
        "dos": [
          "Leave the helmet on unless breathing is blocked.",
          "Support the head and neck.",
          "Wait for trained responders.",
        ],
        "donts": [
          "Do not pull the helmet off suddenly.",
          "Do not twist the victim's neck.",
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("First Aid Guide"),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 32,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "First aid provides immediate help until professional medical assistance arrives.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: topic["color"] as Color,
                      child: Icon(
                        topic["icon"] as IconData,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      topic["title"] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        topic["subtitle"] as String,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FirstAidDetailScreen(
                            title: topic["title"] as String,
                            icon: topic["icon"] as IconData,
                            color: topic["color"] as Color,
                            dos: List<String>.from(topic["dos"] as List),
                            donts: List<String>.from(topic["donts"] as List),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}