import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class UserProfilePage extends StatefulWidget {
  final String userName;
  const UserProfilePage({super.key, required this.userName});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dietaryNeedsController = TextEditingController();
  final TextEditingController _tasteBudsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bioController.text = 'This is the bio section where the user can write about themselves.';
    _dietaryNeedsController.text = 'List any dietary needs here.';
    _tasteBudsController.text = 'Describe taste preferences here.';
  }

  @override
  void dispose() {
    _bioController.dispose();
    _dietaryNeedsController.dispose();
    _tasteBudsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}\'s Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display User's Profile Picture and Name
            Center(
              child: Column(
                children: [
                  user?.photoURL != null
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoURL!),
                    radius: 50,
                  )
                      : const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 8.0),
                  Text('Profile Page for ${widget.userName}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    user?.email ?? 'No email',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Meal Plan Calendar
            const Text('Meal Plan Calendar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 20.0),

            // About Me/Bio Section
            const Text('About Me/Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Bio',
              ),
            ),
            const SizedBox(height: 20.0),

            // Dietary Needs Section
            const Text('Dietary Needs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            TextField(
              controller: _dietaryNeedsController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Dietary Needs',
              ),
            ),
            const SizedBox(height: 20.0),

            // Taste Buds Category Section
            const Text('Taste Buds Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            TextField(
              controller: _tasteBudsController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Taste Buds',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
