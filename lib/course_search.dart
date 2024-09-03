import 'package:flutter/material.dart';

class CourseSearchPage extends StatefulWidget {
  @override
  _CourseSearchPageState createState() => _CourseSearchPageState();
}

class _CourseSearchPageState extends State<CourseSearchPage> {
  String _searchQuery = '';
  String _sortBy = 'title';
  List<String> _filters = [];

  // List of jobs with various professions and types
  List<Map<String, dynamic>> _jobs = [
    {
      'title': 'Fullstack Developer',
      'salary': 85000.0,
      'details': 'Proficient in both frontend and backend technologies.',
      'courses': 'Computer Science, Fullstack Development Bootcamp',
      'contact': 'fullstack@careerhelp.com',
      'type': 'Fullstack',
    },
    {
      'title': 'Frontend Developer',
      'salary': 75000.0,
      'details': 'Expertise in HTML, CSS, JavaScript frameworks like React or Angular.',
      'courses': 'Frontend Development, UI/UX Design',
      'contact': 'frontend@careerhelp.com',
      'type': 'Frontend',
    },
    {
      'title': 'Backend Developer',
      'salary': 80000.0,
      'details': 'Experience with server-side languages like Node.js, Python, Java.',
      'courses': 'Backend Development, Database Management',
      'contact': 'backend@careerhelp.com',
      'type': 'Backend',
    },
    {
      'title': 'Data Analyst',
      'salary': 70000.0,
      'details': 'Skills in data analysis, SQL, Excel, and visualization tools.',
      'courses': 'Data Analytics, Statistics',
      'contact': 'dataanalyst@careerhelp.com',
      'type': 'Data Analyst',
    },
    {
      'title': 'DevOps Engineer',
      'salary': 95000.0,
      'details': 'Expert in CI/CD pipelines, cloud infrastructure, and automation.',
      'courses': 'DevOps Engineering, Cloud Computing',
      'contact': 'devops@careerhelp.com',
      'type': 'DevOps',
    },
    {
      'title': 'Security Specialist',
      'salary': 90000.0,
      'details': 'Knowledge of cybersecurity practices and ethical hacking.',
      'courses': 'Cybersecurity, Ethical Hacking',
      'contact': 'security@careerhelp.com',
      'type': 'Security',
    },
    {
      'title': 'Data Engineer',
      'salary': 92000.0,
      'details': 'Build and maintain data pipelines and architecture.',
      'courses': 'Data Engineering, Big Data',
      'contact': 'dataengineer@careerhelp.com',
      'type': 'Data Engineer',
    },
    {
      'title': 'MBA Graduate',
      'salary': 100000.0,
      'details': 'Leadership and management skills in business environments.',
      'courses': 'MBA, Business Management',
      'contact': 'mba@careerhelp.com',
      'type': 'MBA',
    },
    // Add more job data as needed
  ];
  List<Map<String, dynamic>> _filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _filteredJobs = _jobs; // Initialize with all jobs
  }

  void _searchJobs(String query) {
    setState(() {
      _searchQuery = query;
      _applyFiltersAndSorting();
    });
  }

  void _applyFilters(List<String> selectedFilters) {
    setState(() {
      _filters = selectedFilters;
      _applyFiltersAndSorting();
    });
  }

  void _applyFiltersAndSorting() {
    _filteredJobs = _jobs
        .where((job) {
      final matchesSearchQuery = job['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job['details'].toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilters = _filters.isEmpty || _filters.contains(job['type']);
      return matchesSearchQuery && matchesFilters;
    })
        .toList();

    // Sort jobs based on selected criteria
    if (_sortBy == 'salary') {
      _filteredJobs.sort((a, b) => a['salary'].compareTo(b['salary']));
    } else if (_sortBy == 'title') {
      _filteredJobs.sort((a, b) => a['title'].compareTo(b['title']));
    }
  }

  void _sortJobs(String? sortBy) {
    setState(() {
      if (sortBy != null) {
        _sortBy = sortBy;
        _applyFiltersAndSorting();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Career Guidance'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchJobs,
              decoration: InputDecoration(
                labelText: 'Search for jobs/professions',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // Filter chips and sorting options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Wrap(
                    spacing: 8.0,
                    children: _buildFilterChips(),
                  ),
                  SizedBox(width: 8.0),
                  DropdownButton<String>(
                    value: _sortBy,
                    items: [
                      DropdownMenuItem(value: 'title', child: Text('Sort by Title')),
                      DropdownMenuItem(value: 'salary', child: Text('Sort by Salary')),
                    ],
                    onChanged: _sortJobs,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _filteredJobs.map((job) => _buildJobCard(job)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    // Define available filters
    List<String> availableFilters = [
      'Fullstack',
      'Frontend',
      'Backend',
      'Data Analyst',
      'DevOps',
      'Security',
      'Data Engineer',
      'MBA'
    ];
    return availableFilters.map((filter) {
      return FilterChip(
        label: Text(filter),
        selected: _filters.contains(filter),
        onSelected: (isSelected) {
          setState(() {
            if (isSelected) {
              _filters.add(filter);
            } else {
              _filters.remove(filter);
            }
            _applyFilters(_filters);
          });
        },
      );
    }).toList();
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job['title'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text('Salary: \$${job['salary'].toStringAsFixed(2)}'),
            SizedBox(height: 8.0),
            Text('Details: ${job['details']}'),
            SizedBox(height: 8.0),
            Text('Courses: ${job['courses']}'),
            SizedBox(height: 8.0),
            Text('Contact: ${job['contact']}'),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                // Handle contact action
              },
              child: Text('Contact for Help'),
            ),
          ],
        ),
      ),
    );
  }
}
