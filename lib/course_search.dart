import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _webinarLinkController = TextEditingController();
  final _database = FirebaseDatabase.instance.ref().child('posts');
  XFile? _mediaFile; // Change File to XFile
  String? _selectedPostType;
  String? _userName = FirebaseAuth.instance.currentUser?.displayName;

  // Method to pick media file (image/video) from gallery
  Future<void> _pickMedia() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaFile = pickedFile; // Store XFile instead of File
      });
    } else {
      print('No media file picked');
    }
  }

  // Method to upload file to Firebase Storage
  Future<String?> _uploadFile(XFile file) async {
    try {
      String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(File(file.path)); // Convert to File for upload
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Method to submit post
  void _submitPost() async {
    String postText = _postController.text.trim();
    String description = _descriptionController.text.trim();
    String webinarLink = _webinarLinkController.text.trim();

    if (postText.isNotEmpty && description.isNotEmpty) { // Removed media check
      String? mediaURL;

      // Only upload file if media is selected
      if (_mediaFile != null) {
        mediaURL = await _uploadFile(_mediaFile!);
        if (mediaURL == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload media')));
          return; // Stop the submission process if upload fails
        }
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          Map<String, dynamic> postData = {
            'author': _userName ?? 'Anonymous',
            'userId': user.uid,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'text': postText,
            'description': description,
            'postType': _selectedPostType,
            'mediaURL': mediaURL, // This can be null if no media is uploaded
          };

          if (_selectedPostType == 'Webinar' && webinarLink.isNotEmpty) {
            postData['webinarLink'] = webinarLink;
          }

          await _database.push().set(postData);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post added successfully')));
          Navigator.pop(context);
        } catch (e) {
          print('Error adding post: $e');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add post')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not authenticated')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xff5B75F0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _postController,
                  decoration: InputDecoration(
                    labelText: 'Post Text',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPostType,
                  decoration: InputDecoration(
                    labelText: 'Post Type',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPostType = newValue;
                    });
                  },
                  items: <String>['Webinar', 'Job Referral', 'Personal Post']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                if (_selectedPostType == 'Webinar')
                  TextField(
                    controller: _webinarLinkController,
                    decoration: InputDecoration(
                      labelText: 'Webinar Link',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                SizedBox(height: 16),
                if (_mediaFile != null)
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      image: DecorationImage(
                        image: NetworkImage(_mediaFile!.path), // Use NetworkImage for web
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Text('No media selected', style: TextStyle(color: Colors.black)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickMedia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff5B75F0),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Pick Media', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff5B75F0),
                      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    ),
                    child: Text('Submit Post', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
