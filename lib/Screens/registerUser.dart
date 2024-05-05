import 'dart:convert';

import 'package:chatapp/Screens/homeScreen.dart';
import 'package:chatapp/models/user.dart';
import 'package:chatapp/service/service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({Key? key, required this.mobileNumber})
      : super(key: key);

  final String mobileNumber;
  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  File? _imageFile;
  String? _downloadUrl;
  String userId = '';
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUniqueId();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );

      if (croppedImage != null) {
        setState(() {
          _imageFile = File(croppedImage.path);
        });

        // Upload image to Firebase Storage
        final _userId = userId; // Replace with actual user ID
        await _uploadImage(_imageFile!, _userId);
      }
    }
  }

  Future<void> _loadUniqueId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUniqueId = prefs.getString('uniqueId');
    if (storedUniqueId != null) {
      setState(() {
        userId = storedUniqueId;
      });
    } else {
      final uuid = const Uuid();
      final newUniqueId = uuid.v4();
      setState(() {
        userId = newUniqueId;
      });
      await prefs.setString('uniqueId', newUniqueId);
    }
  }

  Future<void> register() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUniqueId = prefs.getString('uniqueId');
      print(_downloadUrl);
      User user = User(
          id: storedUniqueId ?? '',
          name: _nameController.text,
          mobileNumber: widget.mobileNumber,
          profile: _downloadUrl ?? '',
          about: "Available",
          satus: "Online");
          final jsonString = json.encode(user.toMap());
        prefs.setString('user', jsonString);
      Services()
          .addUserToFirestore(user)
          .then((value) => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomeScreen(
                        // mobileNumber: widget.mobileNumber,
                        )),
              ));
    } catch (e) {
      print(e);
    }
  }


  Future<void> _uploadImage(File imageFile, String userId) async {
    try {
      // Get a reference to the Firebase Storage bucket
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${userId}_profile.jpg');

      // Upload the file to Firebase Storage
      await ref.putFile(imageFile);

      // Get the download URL of the uploaded file
      final downloadURL = await ref.getDownloadURL();

      setState(() {
        _downloadUrl = downloadURL;
        print("_downloadUrl11");
        print(_downloadUrl);
      });
    } catch (e) {
      print('Error uploading profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker and Cropper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              style: const TextStyle(fontSize: 16.0),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Select Image Source'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                          child: const Text('Camera'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                          child: const Text('Gallery'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _downloadUrl != null
                ? const Text('Image uploaded successfully!')
                : const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.only(bottom: 84),
              child: ElevatedButton(
                onPressed: () {
                  register();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: const Color.fromARGB(255, 89, 141, 231),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 4.0,
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
