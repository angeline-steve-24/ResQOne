import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _contactsKey =
      'cached_emergency_contacts';

  // =========================================================
  // SEND SOS
  // =========================================================

  Future<void> sendSOS({
    required double latitude,
    required double longitude,
  }) async {
    await _firestore.collection('sos_alerts').add({
      'latitude': latitude,
      'longitude': longitude,
      'status': 'active',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // SAVE EMERGENCY CONTACT
  // =========================================================

  Future<void> saveEmergencyContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    final contact = {
      'name': name,
      'phone': phone,
      'relation': relation,
    };

    // 1. Save locally first
    await _saveContactLocally(contact);

    // 2. Save to Firestore
    try {
      await _firestore
          .collection('emergency_contacts')
          .add({
        'name': name,
        'phone': phone,
        'relation': relation,
        'createdAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Offline? Local copy already exists.
      print(
        "Firestore unavailable. Contact saved locally.",
      );
    }
  }

  // =========================================================
  // LOCAL CONTACT STORAGE
  // =========================================================

  Future<void> _saveContactLocally(
    Map<String, dynamic> contact,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final existing =
        prefs.getString(_contactsKey);

    List<dynamic> contacts = [];

    if (existing != null) {
      contacts = jsonDecode(existing);
    }

    contacts.add(contact);

    await prefs.setString(
      _contactsKey,
      jsonEncode(contacts),
    );
  }

  // =========================================================
  // GET CONTACTS
  // =========================================================

  Future<List<Map<String, dynamic>>> getContacts() async {
  try {
    final snapshot = await _firestore
        .collection('emergency_contacts')
        .get();

    final contacts = snapshot.docs
        .map((doc) => doc.data())
        .toList();

    // Update local cache with ALL Firestore contacts
    await _replaceLocalContacts(contacts);

    debugPrint(
      "☁️ Firestore contacts loaded: ${contacts.length}",
    );

    return contacts;
  } catch (e) {
    debugPrint(
      "⚠️ Firestore unavailable. Loading local contacts.",
    );

    final localContacts =
        await _getLocalContacts();

    debugPrint(
      "📱 Local contacts loaded: ${localContacts.length}",
    );

    return localContacts;
  }
}

  // =========================================================
  // GET LOCAL CONTACTS
  // =========================================================

  Future<List<Map<String, dynamic>>>
      _getLocalContacts() async {

    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getString(_contactsKey);

    if (data == null) {
      return [];
    }

    final decoded =
        jsonDecode(data);

    return List<Map<String, dynamic>>.from(
      decoded,
    );
  }

  // =========================================================
  // REPLACE LOCAL CONTACT CACHE
  // =========================================================

  Future<void> _replaceLocalContacts(
    List<Map<String, dynamic>> contacts,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _contactsKey,
      jsonEncode(contacts),
    );
  }

  // =========================================================
  // FIRESTORE CONTACT STREAM
  // =========================================================

  Stream<QuerySnapshot>
      getEmergencyContacts() {

    return _firestore
        .collection('emergency_contacts')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // =========================================================
  // DELETE CONTACT
  // =========================================================

  Future<void> deleteContact(
    String documentId,
  ) async {

    await _firestore
        .collection('emergency_contacts')
        .doc(documentId)
        .delete();
  }

  // =========================================================
  // GET SOS ALERTS
  // =========================================================

  Stream<QuerySnapshot> getSOSAlerts() {

    return _firestore
        .collection('sos_alerts')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .snapshots();
  }

  // =========================================================
  // DELETE SOS ALERT
  // =========================================================

  Future<void> deleteSOSAlert(
    String documentId,
  ) async {

    await _firestore
        .collection('sos_alerts')
        .doc(documentId)
        .delete();
  }
}