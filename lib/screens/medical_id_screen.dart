import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalIdScreen extends StatefulWidget {
  final bool isEmergency;

  const MedicalIdScreen({
    super.key,
    this.isEmergency = false,
  });

  @override
  State<MedicalIdScreen> createState() => _MedicalIdScreenState();
}

class _MedicalIdScreenState extends State<MedicalIdScreen> {
  final TextEditingController allergiesController =
      TextEditingController();

  final TextEditingController conditionsController =
      TextEditingController();

  final TextEditingController medicationsController =
      TextEditingController();

  final TextEditingController notesController =
      TextEditingController();

  String bloodGroup = "Select";

  bool isLoading = true;
  bool isSaving = false;

  // Firebase document for this prototype
  final DocumentReference medicalIdRef =
      FirebaseFirestore.instance
          .collection('medical_ids')
          .doc('current_user');

  @override
  void initState() {
    super.initState();
    loadMedicalId();
  }

  @override
  void dispose() {
    allergiesController.dispose();
    conditionsController.dispose();
    medicationsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // ==============================
  // LOAD MEDICAL ID
  // ==============================

  Future<void> loadMedicalId() async {
    try {
      final snapshot = await medicalIdRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        setState(() {
          bloodGroup = data['bloodGroup'] ?? "Select";

          allergiesController.text =
              data['allergies'] ?? "";

          conditionsController.text =
              data['medicalConditions'] ?? "";

          medicationsController.text =
              data['medications'] ?? "";

          notesController.text =
              data['additionalNotes'] ?? "";

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading Medical ID: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  // ==============================
  // SAVE MEDICAL ID
  // ==============================

  Future<void> saveMedicalId() async {
    setState(() {
      isSaving = true;
    });

    try {
      await medicalIdRef.set({
        'bloodGroup': bloodGroup,
        'allergies': allergiesController.text.trim(),
        'medicalConditions': conditionsController.text.trim(),
        'medications': medicationsController.text.trim(),
        'additionalNotes': notesController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "✅ Medical ID saved successfully",
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error saving Medical ID: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Failed to save Medical ID: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget medicalInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.red,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? "Not provided" : value,
        ),
      ),
    );
  }

  // ==============================
  // EMERGENCY MEDICAL ID VIEW
  // ==============================

  Widget emergencyView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [

                  const Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 40,
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: const [

                        Text(
                          "EMERGENCY MEDICAL ID",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "Important medical information",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          medicalInfoRow(
            Icons.bloodtype,
            "Blood Group",
            bloodGroup == "Select"
                ? "Not provided"
                : bloodGroup,
          ),

          medicalInfoRow(
            Icons.warning_amber,
            "Allergies",
            allergiesController.text,
          ),

          medicalInfoRow(
            Icons.health_and_safety,
            "Medical Conditions",
            conditionsController.text,
          ),

          medicalInfoRow(
            Icons.medication,
            "Current Medications",
            medicationsController.text,
          ),

          medicalInfoRow(
            Icons.notes,
            "Additional Medical Notes",
            notesController.text,
          ),

          const SizedBox(height: 20),

          Card(
            color: Colors.orange.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [

                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "This Medical ID is displayed "
                      "because an SOS emergency was triggered.",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================
  // NORMAL EDIT MODE
  // ==============================

  Widget editView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [

                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Colors.red.shade100,
                    child: const Icon(
                      Icons.medical_information,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Emergency Medical Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "This information can help others "
                          "assist you during an emergency.",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Blood Group",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue:
                bloodGroup == "Select"
                    ? null
                    : bloodGroup,

            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon:
                  Icon(Icons.bloodtype),
              hintText:
                  "Select blood group",
            ),

            items: const [

              DropdownMenuItem(
                value: "A+",
                child: Text("A+"),
              ),

              DropdownMenuItem(
                value: "A-",
                child: Text("A-"),
              ),

              DropdownMenuItem(
                value: "B+",
                child: Text("B+"),
              ),

              DropdownMenuItem(
                value: "B-",
                child: Text("B-"),
              ),

              DropdownMenuItem(
                value: "AB+",
                child: Text("AB+"),
              ),

              DropdownMenuItem(
                value: "AB-",
                child: Text("AB-"),
              ),

              DropdownMenuItem(
                value: "O+",
                child: Text("O+"),
              ),

              DropdownMenuItem(
                value: "O-",
                child: Text("O-"),
              ),
            ],

            onChanged: (value) {
              setState(() {
                bloodGroup =
                    value ?? "Select";
              });
            },
          ),

          const SizedBox(height: 20),

          const Text(
            "Allergies",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
                allergiesController,
            decoration:
                const InputDecoration(
              border:
                  OutlineInputBorder(),
              prefixIcon:
                  Icon(Icons.warning_amber),
              hintText:
                  "Example: Penicillin, peanuts",
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Medical Conditions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
                conditionsController,
            decoration:
                const InputDecoration(
              border:
                  OutlineInputBorder(),
              prefixIcon:
                  Icon(Icons.health_and_safety),
              hintText:
                  "Example: Asthma, diabetes",
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Current Medications",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
                medicationsController,
            decoration:
                const InputDecoration(
              border:
                  OutlineInputBorder(),
              prefixIcon:
                  Icon(Icons.medication),
              hintText:
                  "Example: Inhaler",
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Additional Medical Notes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
                notesController,
            maxLines: 4,
            decoration:
                const InputDecoration(
              border:
                  OutlineInputBorder(),
              prefixIcon:
                  Icon(Icons.notes),
              hintText:
                  "Any other important information...",
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),

              label: Text(
                isSaving
                    ? "SAVING..."
                    : "SAVE MEDICAL ID",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              onPressed:
                  isSaving
                      ? null
                      : saveMedicalId,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor:
            widget.isEmergency
                ? Colors.red
                : null,

        foregroundColor:
            widget.isEmergency
                ? Colors.white
                : null,

        title: Text(
          widget.isEmergency
              ? "Emergency Medical ID"
              : "Medical ID",
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : widget.isEmergency
              ? emergencyView()
              : editView(),
    );
  }
}