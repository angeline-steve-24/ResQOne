import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstAidDetailScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> dos;
  final List<String> donts;

  const FirstAidDetailScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.dos,
    required this.donts,
  });

  Future<void> call108() async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: '108',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Card(
              color: Colors.red.shade50,

              child: const ListTile(
                leading: Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                title: Text(
                  "First aid is temporary.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Call emergency services immediately for serious injuries.",
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: color,

                child: Icon(
                  icon,
                  size: 45,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "✅ What To Do",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            ...dos.map(
  (e) => Card(
    color: Colors.green.shade50,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              e,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
            const Divider(height: 40),
            const SizedBox(height: 25),

            const Text(
              "❌ What NOT To Do",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 10),

            ...donts.map(
  (e) => Card(
    color: Colors.red.shade50,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cancel,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              e,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),

            const SizedBox(height: 35),
            Card(
  color: Colors.amber.shade50,
  elevation: 0,
  child: const Padding(
    padding: EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info,
          color: Colors.orange,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            "First aid provides temporary assistance only. Always seek professional medical care as soon as possible.",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                onPressed: call108,

                icon: const Icon(Icons.call),

                label: const Text(
                  "Call 108",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}