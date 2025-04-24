import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:sheon/color.dart';
import 'package:sheon/contact_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPickerPage extends StatefulWidget {
  const ContactPickerPage({super.key});

  @override
  _ContactPickerPageState createState() => _ContactPickerPageState();
}

class _ContactPickerPageState extends State<ContactPickerPage> {
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _pickContact() async {
    try {
      final Contact? contact = await _contactPicker.selectContact();
      if (contact != null) {
        setState(() {
          _contacts.add(contact);
        });
        await ContactManager.saveContacts(_contacts);
      }
    } catch (e) {
      print("Error picking contact: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick contact: $e")),
      );
    }
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await ContactManager.loadContacts();
      setState(() {
        _contacts = contacts;
      });
    } catch (e) {
      print("Error loading contacts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load contacts")),
      );
    }
  }

  void _deleteContact(int index) async {
    try {
      setState(() {
        _contacts.removeAt(index);
      });
      await ContactManager.saveContacts(_contacts);
    } catch (e) {
      print("Error deleting contact: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete contact")),
      );
    }
  }

Future<void> _callContact(String phoneNumber) async {
  final String sanitizedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  final Uri googleDialerUri = Uri.parse("tel:$sanitizedNumber");

  try {
    // Try launching Google Dialer directly
    bool launched = await launchUrl(
      googleDialerUri,
      mode: LaunchMode.externalNonBrowserApplication,
    );

    if (!launched) {
      // Fallback to default dialer
      await launchUrl(
        googleDialerUri,
        mode: LaunchMode.externalApplication,
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Contacts"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.secondary),
            onPressed: _pickContact,
          ),
        ],
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: _contacts.isEmpty
                ? Center(
                    child: Text(
                      "No contacts added yet",
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      final phoneNumber = contact.phoneNumbers?.first ?? "";
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        color: AppColors.primary.withOpacity(0.8),
                        child: ListTile(
                          title: Text(
                            contact.fullName ?? "Unknown",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          subtitle: phoneNumber.isNotEmpty
                              ? Text(
                                  phoneNumber,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondary,
                                  ),
                                )
                              : null,
                          onTap: () => _callContact(phoneNumber),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteContact(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
    );
  }
}