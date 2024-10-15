import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseReference userRef = FirebaseDatabase.instance.ref('users');
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List<UserProfile> allUsers = [];
  List<UserProfile> filteredUsers = [];

  // Selected filters
  String selectedJobStatus = 'All';
  String selectedJobTitle = 'All';
  String selectedWorkingPlace = 'All';
  String searchQuery = '';

  // For dropdown items
  List<String> jobStatuses = ['All', 'employed', 'unemployed'];
  List<String> jobTitles = ['All'];
  List<String> workingPlaces = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await userRef.once();
    if (snapshot.snapshot.value != null) {
      final usersMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
      allUsers = usersMap.entries.map((entry) {
        final userData = entry.value;
        return UserProfile(
          id: entry.key,
          name: userData['name'],
          jobStatus: userData['job'] ?? '',
          jobTitle: userData['job_title'] ?? '',
          workingPlace: userData['working_place'] ?? '',
        );
      }).toList();
      _extractUniqueValues();
      _filterUsers();
    }
  }

  void _extractUniqueValues() {
    Set<String> jobTitleSet = {};
    Set<String> workingPlaceSet = {};

    for (var user in allUsers) {
      jobTitleSet.add(user.jobTitle);
      workingPlaceSet.add(user.workingPlace);
    }

    setState(() {
      jobTitles = ['All', ...jobTitleSet.toList()..removeWhere((item) => item.isEmpty)];
      workingPlaces = ['All', ...workingPlaceSet.toList()..removeWhere((item) => item.isEmpty)];
    });
  }

  void _filterUsers() {
    setState(() {
      filteredUsers = allUsers.where((user) {
        final matchesSearch = user.name.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesJobStatus = selectedJobStatus == 'All' || user.jobStatus == selectedJobStatus;
        final matchesJobTitle = selectedJobTitle == 'All' || user.jobTitle == selectedJobTitle;
        final matchesWorkingPlace = selectedWorkingPlace == 'All' || user.workingPlace == selectedWorkingPlace;

        return matchesSearch && matchesJobStatus && matchesJobTitle && matchesWorkingPlace;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterUsers();
                });
              },
            ),
          ),
          // Filters
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name[0]),
                    ),
                    title: Text(user.name),
                    subtitle: Text(
                      'Job Title: ${user.jobTitle}\n'
                      'Working Place: ${user.workingPlace}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (user.id == currentUserId) {
                          Navigator.of(context).pushNamed('/profilescreen');
                        } else {
                          Navigator.of(context).pushNamed('/otherprofile', arguments: user.id);
                        }
                      },
                      child: const Text('Connect'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          _buildDropdown(
            value: selectedJobStatus,
            items: jobStatuses,
            onChanged: (value) {
              setState(() {
                selectedJobStatus = value!;
                _filterUsers();
              });
            },
          ),
          const SizedBox(width: 8.0),
          _buildDropdown(
            value: selectedJobTitle,
            items: jobTitles,
            onChanged: (value) {
              setState(() {
                selectedJobTitle = value!;
                _filterUsers();
              });
            },
          ),
          const SizedBox(width: 8.0),
          _buildDropdown(
            value: selectedWorkingPlace,
            items: workingPlaces,
            onChanged: (value) {
              setState(() {
                selectedWorkingPlace = value!;
                _filterUsers();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: DropdownButton<String>(
        isExpanded: true,
        value: items.contains(value) ? value : null,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String jobStatus;
  final String jobTitle;
  final String workingPlace;

  UserProfile({
    required this.id,
    required this.name,
    required this.jobStatus,
    required this.jobTitle,
    required this.workingPlace,
  });
}