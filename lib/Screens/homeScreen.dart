import 'dart:convert';

import 'package:chatapp/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 late User user =User(id: 'id', name: 'name', mobileNumber: 'mobileNumber', profile: 'profile', about: 'about', satus: 'satus');
@override
  void initState() {
   _loadObject();
    super.initState();
  
  }

  Future<void> _loadObject() async {
    final prefs = await SharedPreferences.getInstance();
     final storedUniqueId = prefs.getString('uniqueId');
    final jsonString = prefs.getString('user');
    if (jsonString != null) {
      setState(() {
        user = User.fromMap(json.decode(jsonString),storedUniqueId??'');
      });
    }
  }

  


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top:60.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(user.name),
              ),
               Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: CircleAvatar(
                    radius: 20,
                    backgroundImage:NetworkImage(user.profile)
                 ),
               ),
              
              ],
            ),
          ),
           Expanded(
                 child: ListView.builder(
                  shrinkWrap: true,
                         itemCount: 20, // Example: 20 chat items
                         itemBuilder: (context, index) {
                           return ListTile(
                             leading: CircleAvatar(
                               backgroundColor: Colors.grey, // Placeholder color
                               backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
                             ),
                             title: Text('Contact Name'),
                             subtitle: Text('Last message'),
                             trailing: Column(
                               crossAxisAlignment: CrossAxisAlignment.end,
                               children: [
                  Text('11:00 PM'), // Example: Last message timestamp
                  Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '3', // Example: Unread message count
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                               ],
                             ),
                             onTap: () {
                               // Handle tap on chat item
                             },
                           );
                         },
                       ),
               ),
        ],
      ),
      
    );
  }
}