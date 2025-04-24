import 'dart:convert';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactManager {
  static const String _contactsKey = 'contacts';

  // Save contacts to shared preferences
  static Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final contactList = contacts.map((c) {
      // Ensure all phone numbers have the +91 prefix
      String formattedPhone = c.phoneNumbers?.first ?? "";
      if (!formattedPhone.startsWith("+91")) {
        formattedPhone = "+91$formattedPhone";
      }
      return jsonEncode({'name': c.fullName, 'phone': formattedPhone});
    }).toList();
    await prefs.setStringList(_contactsKey, contactList);
  }

  // Load contacts from shared preferences
  static Future<List<Contact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactList = prefs.getStringList(_contactsKey) ?? [];
    return contactList.map((c) {
      final data = jsonDecode(c);
      return Contact(fullName: data['name'], phoneNumbers: [data['phone']]);
    }).toList();
  }
}