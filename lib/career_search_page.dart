import 'package:flutter/material.dart';

class CareerSearchPage extends StatefulWidget {
  @override
  _CareerSearchPageState createState() => _CareerSearchPageState();
}

class _CareerSearchPageState extends State<CareerSearchPage> {
  String? _selectedCareer;
  final List<String> _careers = [
    "Software Developer",
    "Data Scientist",
    "UI/UX Designer"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Career Path'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffa1c4fd), Color(0xffc2e9fb)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select a Career',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              value: _selectedCareer,
              items: _careers.map((career) {
                return DropdownMenuItem<String>(
                  value: career,
                  child: Text(career),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCareer = value;
                });
              },
            ),
            SizedBox(height: 20),
            if (_selectedCareer != null)
              Expanded(
                child: FutureBuilder<List<Map<String, String>>>(
                  future: _fetchProfessionals(_selectedCareer!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error fetching professionals'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No professionals found for $_selectedCareer'));
                    }

                    final professionals = snapshot.data!;
                    return ListView.builder(
                      itemCount: professionals.length,
                      itemBuilder: (context, index) {
                        final professional = professionals[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(professional['name']![0]),
                            ),
                            title: Text(professional['name']!),
                            subtitle: Text(
                              'Experience: ${professional['experience']} \n'
                                  'Location: ${professional['location']} \n'
                                  'Company: ${professional['company']}',
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xffa1c4fd),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MessagePage(professional: professional),
                                  ),
                                );
                              },
                              child: Text('Connect'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, String>>> _fetchProfessionals(String career) async {
    // Simulating network delay
    await Future.delayed(Duration(seconds: 2));

    // Sample data for professionals based on the career selected
    List<Map<String, String>> professionals;

    switch (career) {
      case "Software Developer":
        professionals = [
          {
            'name': 'Alice Johnson',
            'experience': '5 years',
            'location': 'New York, USA',
            'company': 'Tech Innovators Inc.',
          },
          {
            'name': 'Bob Smith',
            'experience': '3 years',
            'location': 'San Francisco, USA',
            'company': 'Data Insights LLC',
          },
          {
            'name': 'Chandra Shekhar',
            'experience': '10 years',
            'location': 'Bangalore, India',
            'company': 'Infosys Ltd.',
          },
          {
            'name': 'Deepika Sharma',
            'experience': '6 years',
            'location': 'Mumbai, India',
            'company': 'Tata Consultancy Services',
          },
          {
            'name': 'Ethan Brown',
            'experience': '4 years',
            'location': 'Austin, USA',
            'company': 'Dell Technologies',
          },
          {
            'name': 'Fatima Khan',
            'experience': '8 years',
            'location': 'Delhi, India',
            'company': 'Wipro Ltd.',
          },
          {
            'name': 'Gaurav Gupta',
            'experience': '7 years',
            'location': 'Pune, India',
            'company': 'Persistent Systems',
          },
          {
            'name': 'Hiroshi Tanaka',
            'experience': '12 years',
            'location': 'Tokyo, Japan',
            'company': 'Sony Corporation',
          },
        ];
        break;
      case "Data Scientist":
        professionals = [
          {
            'name': 'Catherine Lee',
            'experience': '8 years',
            'location': 'London, UK',
            'company': 'Creative Data Co.',
          },
          {
            'name': 'David Wilson',
            'experience': '2 years',
            'location': 'Sydney, Australia',
            'company': 'AI Solutions Pty Ltd',
          },
          {
            'name': 'Ishita Patel',
            'experience': '5 years',
            'location': 'Ahmedabad, India',
            'company': 'DataMinds Pvt Ltd.',
          },
          {
            'name': 'Jackie Chan',
            'experience': '6 years',
            'location': 'Hong Kong, China',
            'company': 'Analytics Hub',
          },
          {
            'name': 'Karthik Kumar',
            'experience': '7 years',
            'location': 'Chennai, India',
            'company': 'HCL Technologies',
          },
          {
            'name': 'Lily Wang',
            'experience': '9 years',
            'location': 'Shanghai, China',
            'company': 'Alibaba Group',
          },
          {
            'name': 'Manoj Verma',
            'experience': '4 years',
            'location': 'Hyderabad, India',
            'company': 'Cyient Ltd.',
          },
          {
            'name': 'Natalie Garcia',
            'experience': '3 years',
            'location': 'Mexico City, Mexico',
            'company': 'Data Analytics SA',
          },
        ];
        break;
      case "UI/UX Designer":
        professionals = [
          {
            'name': 'Eva Green',
            'experience': '6 years',
            'location': 'Toronto, Canada',
            'company': 'Design Studio Inc.',
          },
          {
            'name': 'Franklin White',
            'experience': '4 years',
            'location': 'Berlin, Germany',
            'company': 'UX Design GmbH',
          },
          {
            'name': 'Nidhi Rao',
            'experience': '5 years',
            'location': 'Bangalore, India',
            'company': 'Mindtree Ltd.',
          },
          {
            'name': 'Olga Petrova',
            'experience': '10 years',
            'location': 'Moscow, Russia',
            'company': 'Creative Works Studio',
          },
          {
            'name': 'Pankaj Kapoor',
            'experience': '6 years',
            'location': 'Delhi, India',
            'company': 'Pixel Perfect Designs',
          },
          {
            'name': 'Qi Zhang',
            'experience': '7 years',
            'location': 'Beijing, China',
            'company': 'Tencent',
          },
          {
            'name': 'Rita Roy',
            'experience': '8 years',
            'location': 'Kolkata, India',
            'company': 'TCS',
          },
          {
            'name': 'Samantha Williams',
            'experience': '3 years',
            'location': 'Johannesburg, South Africa',
            'company': 'Creative UX Studio',
          },
        ];
        break;
      default:
        professionals = [];
        break;
    }

    return professionals;
  }
}

class MessagePage extends StatefulWidget {
  final Map<String, String> professional;

  MessagePage({required this.professional});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add(_messageController.text);
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.professional['name']}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffa1c4fd), Color(0xffc2e9fb)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffa1c4fd), Color(0xffc2e9fb)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _messages[index],
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
