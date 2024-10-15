import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final double coverHeight = 100;
  final double profileHeight = 130;

  final DatabaseReference _database = FirebaseDatabase.instance.reference().child('users');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _profileImage;
  bool _isLoading = false;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final imageUrl = await _getCurrentProfilePictureUrl();
    if (imageUrl != null) {
      setState(() {
        _profileImage = File(imageUrl); // Update this line if you need to fetch image from network
      });
    }
  }

  Future<String?> _getCurrentProfilePictureUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final profileImageSnapshot = await _database.child(user.uid).child('profileImage').once();
    return profileImageSnapshot.snapshot.value as String?;
  }

  Future<void> _deleteOldProfilePicture(String oldImageUrl) async {
    final oldImageRef = _storage.refFromURL(oldImageUrl);
    try {
      await oldImageRef.delete();
    } catch (e) {
      print("Error deleting old profile picture: $e");
    }
  }

  Future<void> _updateProfilePicture(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final currentImageUrl = await _getCurrentProfilePictureUrl();
    if (currentImageUrl != null) {
      await _deleteOldProfilePicture(currentImageUrl);
    }

    final storageRef = _storage.ref().child('profile_pictures').child(user.uid + '.jpg');

    try {
      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      await _database.child(user.uid).child('profileImage').set(imageUrl);

      setState(() {
        _profileImage = imageFile; // Update profile image after upload
        _successMessage = 'Profile picture updated successfully!';
      });
    } catch (e) {
      setState(() {
        _successMessage = 'Failed to update profile picture.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteProfilePicture() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final currentImageUrl = await _getCurrentProfilePictureUrl();
    if (currentImageUrl != null) {
      try {
        final storageRef = _storage.refFromURL(currentImageUrl);
        await storageRef.delete();
        await _database.child(user.uid).child('profileImage').remove();

        setState(() {
          _profileImage = null; // Update profile image to null after deletion
          _successMessage = 'Profile picture deleted successfully!';
        });
      } catch (e) {
        setState(() {
          _successMessage = 'Failed to delete profile picture.';
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await _updateProfilePicture(imageFile);
    }
  }

  Future<void> _showImageOptions() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose an action'),
        actions: <Widget>[
          TextButton(
            child: Text('Take Photo', style: TextStyle(color: Color(0xffa1c4fd)),),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          TextButton(
            child: Text('Pick from Gallery', style: TextStyle(color: Color(0xffa1c4fd)),),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          if (_profileImage != null) // Show this only if there is a profile image
            TextButton(
              child: Text('Delete Photo', style: TextStyle(color: Color(0xffa1c4fd)),),
              onPressed: () {
                Navigator.pop(context);
                _deleteProfilePicture();
              },
            ),
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Color(0xffa1c4fd)),),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    final userSnapshot = await _database.child(user.uid).get();
    if (!userSnapshot.exists) return null;

    return {
      'name': userSnapshot.child('name').value,
      'email': userSnapshot.child('email').value,
      'profileImage': userSnapshot.child('profileImage').value,
      'job': userSnapshot.child('job').value,
      'job_title': userSnapshot.child('job_title').value,
      'working_place': userSnapshot.child('working_place').value,
      'phone': userSnapshot.child('phone').value, // Ensure this is added
    };
  }
  Future<void> _deleteUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _database.child(user.uid).remove(); // Remove user data from the database
      await user.delete(); // Delete user from Firebase Authentication
      Navigator.pop(context); // Navigate back after deletion
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
  Future<void> _showDeleteConfirmation() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete your profile? This action cannot be undone.'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(); // Delete the user profile
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }

          final userData = snapshot.data;
          final profileImage = userData?['profileImage'] as String?;

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              buildTop(profileImage),
              buildContent(userData),
              SizedBox(height: 20),

              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(_successMessage!, style: TextStyle(color: Colors.green)),
                  ),
                ),
              buildAdditionalDetails(userData),
              buildProfileButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget buildCoverImage() => Container(
    color: Colors.white,
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Colors.blue],
          stops: [0.2, 0.8],
        ),
      ),
    ),
    width: double.infinity,
    height: coverHeight,
  );

  Widget buildProfileImage(String? imageUrl) => Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [
      CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey.shade800,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : AssetImage('assets/images/profileavatar.png') as ImageProvider,
      ),
      Positioned(
        bottom: 0,
        right: -10,
        child: buildEditIcon(Colors.blue),
      ),
    ],
  );

  Widget buildEditIcon(Color color) => buildCircle(
    color: Colors.white,
    all: 2,
    child: buildCircle(
      color: color,
      all: 5,
      child: IconButton(
        icon: Icon(Icons.edit, color: Colors.white, size: 17),
        onPressed: _showImageOptions,
      ),
    ),
  );


  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) => ClipOval(
    child: Container(
      padding: EdgeInsets.all(all),
      color: color,
      child: child,
    ),
  );

  Widget buildTop(String? profileImage) {
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCoverImage(),
        ),
        Positioned(
          top: top,
          child: buildProfileImage(profileImage),
        ),
      ],
    );
  }

  Widget buildContent(Map<String, dynamic>? userData) {
    final name = userData?['name'] ?? '-';

    return Column(
      children: [
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
      ],
    );

  }
  Widget buildAdditionalDetails(Map<String, dynamic>? userData) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.work, color: Colors.black),
          title: Text('Job Status: ${userData?['job'] ?? 'Not available'}'), // Job Status
        ),
        ListTile(
          leading: Icon(Icons.title, color: Colors.black),
          title: Text('Job Title: ${userData?['job_title'] ?? 'Not available'}'), // Job Title
        ),
        ListTile(
          leading: Icon(Icons.phone, color: Colors.black),
          title: Text('Phone Number: ${userData?['phone'] ?? 'Not available'}'), // Phone Number
        ),
        ListTile(
          leading: Icon(Icons.location_on, color: Colors.black),
          title: Text('Working Place: ${userData?['working_place'] ?? 'Not available'}'), // Working Place
        ),
      ],
    ),
  );
}

  Widget buildProfileButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            onPressed: () async {
              // Navigate to EditProfileScreen and wait for result
              final result = await Navigator.pushNamed(context, '/editprofile');

              // Check if the result indicates that changes were made
              if (result == true) {
                // Refresh the profile data by calling setState
                setState(() {});
              }
            },
            child: Text('Edit Profile', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: _showDeleteConfirmation,
            child: Text('Delete Profile', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}