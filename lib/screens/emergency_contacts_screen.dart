import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController relationController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    relationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Emergency Contacts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // -----------------------------------------
            // ADD CONTACT CARD
            // -----------------------------------------

            Card(
              elevation: 4,
              shadowColor: Colors.red.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        Container(
                          padding:
                              const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              "Add Emergency Contact",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              "Someone who can help you quickly",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // NAME

                    TextField(
                      controller: nameController,
                      textCapitalization:
                          TextCapitalization.words,

                      decoration: InputDecoration(
                        labelText: "Name",
                        prefixIcon: const Icon(
                          Icons.person_outline,
                        ),

                        filled: true,
                        fillColor:
                            Colors.grey.shade50,

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),

                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // PHONE

                    TextField(
                      controller: phoneController,
                      keyboardType:
                          TextInputType.phone,

                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                        ),

                        filled: true,
                        fillColor:
                            Colors.grey.shade50,

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),

                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // RELATIONSHIP

                    TextField(
                      controller:
                          relationController,

                      textCapitalization:
                          TextCapitalization.words,

                      decoration: InputDecoration(
                        labelText: "Relationship",
                        prefixIcon: const Icon(
                          Icons.family_restroom,
                        ),

                        hintText:
                            "Example: Father, Mother, Friend",

                        filled: true,
                        fillColor:
                            Colors.grey.shade50,

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),

                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // SAVE BUTTON

                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton.icon(
                        onPressed: () async {

                          if (nameController
                                  .text
                                  .trim()
                                  .isEmpty ||
                              phoneController
                                  .text
                                  .trim()
                                  .isEmpty ||
                              relationController
                                  .text
                                  .trim()
                                  .isEmpty) {

                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please fill all fields",
                                ),
                              ),
                            );

                            return;
                          }

                          await FirestoreService()
                              .saveEmergencyContact(
                            name:
                                nameController.text
                                    .trim(),

                            phone:
                                phoneController.text
                                    .trim(),

                            relation:
                                relationController
                                    .text
                                    .trim(),
                          );

                          nameController.clear();
                          phoneController.clear();
                          relationController.clear();

                          if (!mounted) return;

                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              backgroundColor:
                                  Colors.green,
                              content: Text(
                                "Emergency contact saved",
                              ),
                            ),
                          );
                        },

                        icon: const Icon(
                          Icons.save,
                          color: Colors.white,
                        ),

                        label: const Text(
                          "SAVE CONTACT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    14),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // -----------------------------------------
            // SAVED CONTACTS HEADER
            // -----------------------------------------

            Row(
              children: [

                const Icon(
                  Icons.contacts,
                  color: Colors.red,
                  size: 25,
                ),

                const SizedBox(width: 8),

                const Text(
                  "Saved Contacts",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // -----------------------------------------
            // CONTACT LIST
            // -----------------------------------------

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService()
                    .getEmergencyContacts(),

                builder:
                    (context, snapshot) {

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Error loading contacts",
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color: Colors.red,
                      ),
                    );
                  }

                  final contacts =
                      snapshot.data!.docs;

                  if (contacts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Icon(
                            Icons.contact_page_outlined,
                            size: 65,
                            color:
                                Colors.grey.shade400,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "No emergency contacts yet",
                            style: TextStyle(
                              fontSize: 17,
                              color:
                                  Colors.grey.shade600,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "Add someone you trust above",
                            style: TextStyle(
                              color:
                                  Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: contacts.length,

                    itemBuilder:
                        (context, index) {

                      final contact =
                          contacts[index];

                      final name =
                          contact['name']
                              .toString();

                      final relation =
                          contact['relation']
                              .toString();

                      final phone =
                          contact['phone']
                              .toString();

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        elevation: 3,

                        shadowColor:
                            Colors.black
                                .withOpacity(0.08),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  18),
                        ),

                        child: ListTile(
                          contentPadding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          // AVATAR

                          leading: CircleAvatar(
                            radius: 27,

                            backgroundColor:
                                Colors.red.shade50,

                            child: Text(
                              name.isNotEmpty
                                  ? name[0]
                                      .toUpperCase()
                                  : "?",

                              style:
                                  const TextStyle(
                                color: Colors.red,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),

                          // NAME + DETAILS

                          title: Text(
                            name,

                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle:
                              Padding(
                            padding:
                                const EdgeInsets
                                    .only(top: 5),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Row(
                                  children: [

                                    const Icon(
                                      Icons
                                          .family_restroom,
                                      size: 15,
                                      color:
                                          Colors.grey,
                                    ),

                                    const SizedBox(
                                      width: 5,
                                    ),

                                    Text(
                                      relation,
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height: 3),

                                Row(
                                  children: [

                                    const Icon(
                                      Icons.phone,
                                      size: 15,
                                      color:
                                          Colors.grey,
                                    ),

                                    const SizedBox(
                                      width: 5,
                                    ),

                                    Text(
                                      phone,
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // DELETE

                          trailing:
                              IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 26,
                            ),

                            onPressed: () async {

                              await FirestoreService()
                                  .deleteContact(
                                contact.id,
                              );

                              if (!mounted) return;

                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Contact removed",
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}