import 'dart:convert';
import 'package:chatapp/Screens/chatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   List<Contact> _deviceContacts = [];
  List<Map<String, dynamic>> _matchedContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      // Fetch contacts from the device
      Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        _deviceContacts = contacts.toList();
      });

      // Fetch contacts from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>> firestoreContacts = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Find matching contacts
      List<Map<String, dynamic>> matchedContacts = [];
      for (var deviceContact in _deviceContacts) {
        String? devicePhoneNumber = deviceContact.phones?.isNotEmpty == true ? deviceContact.phones!.first.value : null;
        if (devicePhoneNumber != null) {
          for (var firestoreContact in firestoreContacts) {
            print("sharath");
            print(devicePhoneNumber.replaceAll(' ', ''));
            print(firestoreContact['mobileNumber']);
            if (firestoreContact['mobileNumber'] == devicePhoneNumber.replaceAll(' ', '')) {
              matchedContacts.add(firestoreContact);
            }
          }
        }
      }

      setState(() {
        _matchedContacts = matchedContacts;
      });
    } else {
      // Handle case when permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contacts permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matching Contacts from Firestore'),
      ),
      body: _matchedContacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _matchedContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap:()=>Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(
                              toMobileNumber: _matchedContacts[index]['mobileNumber'],
                            )),
                  ) ,
                  title: Text(_matchedContacts[index]['name']),
                  subtitle: Text(_matchedContacts[index]['mobileNumber']??''),
                );
              },
            ),
    );
  }
}