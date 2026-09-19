import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class AccidentHistoryScreen extends StatelessWidget {
  const AccidentHistoryScreen({super.key});

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
          "Accident History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getSOSAlerts(),

        builder: (context, snapshot) {

          // -----------------------------------------
          // ERROR
          // -----------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.shade300,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Unable to load incidents",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // -----------------------------------------
          // LOADING
          // -----------------------------------------

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }

          final alerts =
              snapshot.data!.docs;

          // -----------------------------------------
          // EMPTY STATE
          // -----------------------------------------

          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Container(
                    padding:
                        const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      Icons.shield_outlined,
                      size: 55,
                      color: Colors.green.shade600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "No Emergency Incidents Yet",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Your emergency history will appear here.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // -----------------------------------------
          // INCIDENT LIST
          // -----------------------------------------

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: alerts.length,

            itemBuilder: (context, index) {

              final alert =
                  alerts[index];

              final latitude =
                  alert['latitude'].toString();

              final longitude =
                  alert['longitude'].toString();

              final status =
                  alert['status'].toString();

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 14,
                ),

                elevation: 3,

                shadowColor:
                    Colors.black.withOpacity(0.08),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // --------------------------------
                      // INCIDENT ICON
                      // --------------------------------

                      Container(
                        width: 52,
                        height: 52,

                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(15),
                        ),

                        child: const Icon(
                          Icons.warning_rounded,
                          color: Colors.red,
                          size: 29,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // --------------------------------
                      // INCIDENT INFORMATION
                      // --------------------------------

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(
                              "Emergency Incident",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 17,
                                  color: Colors.grey,
                                ),

                                const SizedBox(width: 5),

                                Expanded(
                                  child: Text(
                                    "Latitude: $latitude",
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 17,
                                  color: Colors.grey,
                                ),

                                const SizedBox(width: 5),

                                Expanded(
                                  child: Text(
                                    "Longitude: $longitude",
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // STATUS

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),

                              decoration: BoxDecoration(
                                color:
                                    status.toLowerCase() ==
                                            "active"
                                        ? Colors.red
                                            .shade50
                                        : Colors.green
                                            .shade50,

                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),

                              child: Text(
                                "Status: $status",

                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.bold,

                                  color:
                                      status.toLowerCase() ==
                                              "active"
                                          ? Colors.red
                                          : Colors.green
                                              .shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --------------------------------
                      // DELETE
                      // --------------------------------

                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 25,
                        ),

                        tooltip:
                            "Delete incident",

                        onPressed: () async {

                          await FirestoreService()
                              .deleteSOSAlert(
                            alert.id,
                          );

                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Incident removed",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}