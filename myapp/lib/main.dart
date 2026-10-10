import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StudentRegistrationPage(),
    );
  }
}

// ======================================================
// STUDENT REGISTRATION PAGE
// ======================================================

class StudentRegistrationPage extends StatefulWidget {
  const StudentRegistrationPage({super.key});

  @override
  State<StudentRegistrationPage> createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState
    extends State<StudentRegistrationPage> {

  final nameController = TextEditingController();
  final sectionController = TextEditingController();
  final yearLevelController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    yearLevelController.dispose();
    super.dispose();
  }

  void goToSubjectSchedule() {
    if (nameController.text.trim().isEmpty ||
        sectionController.text.trim().isEmpty ||
        yearLevelController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields.'),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectSchedulePage(
          name: nameController.text.trim(),
          section: sectionController.text.trim(),
          yearLevel: yearLevelController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 30),

            const Text(
              'Student Registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 35),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: sectionController,
              decoration: const InputDecoration(
                labelText: 'Section',
                hintText: 'Enter your section',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: yearLevelController,
              decoration: const InputDecoration(
                labelText: 'Yr Level',
                hintText: 'Enter your year level',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 35),

            ElevatedButton(
              onPressed: goToSubjectSchedule,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// SUBJECT SCHEDULE PAGE
// ======================================================

class SubjectSchedulePage extends StatefulWidget {
  final String name;
  final String section;
  final String yearLevel;

  const SubjectSchedulePage({
    super.key,
    required this.name,
    required this.section,
    required this.yearLevel,
  });

  @override
  State<SubjectSchedulePage> createState() =>
      _SubjectSchedulePageState();
}

class _SubjectSchedulePageState
    extends State<SubjectSchedulePage> {

  final subject1Controller = TextEditingController();
  final schedule1Controller = TextEditingController();

  final subject2Controller = TextEditingController();
  final schedule2Controller = TextEditingController();

  final subject3Controller = TextEditingController();
  final schedule3Controller = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    subject1Controller.dispose();
    schedule1Controller.dispose();

    subject2Controller.dispose();
    schedule2Controller.dispose();

    subject3Controller.dispose();
    schedule3Controller.dispose();

    super.dispose();
  }

  Future<void> saveStudent() async {

    if (subject1Controller.text.trim().isEmpty ||
        schedule1Controller.text.trim().isEmpty ||
        subject2Controller.text.trim().isEmpty ||
        schedule2Controller.text.trim().isEmpty ||
        subject3Controller.text.trim().isEmpty ||
        schedule3Controller.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all subject fields.'),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      await FirebaseFirestore.instance
          .collection('students')
          .add({

        'name': widget.name,

        'section': widget.section,

        'yearLevel': widget.yearLevel,

        'subjects': [
          {
            'subject': subject1Controller.text.trim(),
            'schedule': schedule1Controller.text.trim(),
          },
          {
            'subject': subject2Controller.text.trim(),
            'schedule': schedule2Controller.text.trim(),
          },
          {
            'subject': subject3Controller.text.trim(),
            'schedule': schedule3Controller.text.trim(),
          },
        ],

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Student registration saved successfully!',
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving data: $e',
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget subjectInput({
    required String subjectLabel,
    required TextEditingController subjectController,
    required TextEditingController scheduleController,
  }) {
    return Column(
      children: [

        TextField(
          controller: subjectController,
          decoration: InputDecoration(
            labelText: subjectLabel,
            hintText: 'Enter subject',
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: scheduleController,
          decoration: const InputDecoration(
            labelText: 'Schedule',
            hintText: 'Example: Monday 8:00 AM',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Schedule'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const Text(
              'Subject Schedule',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'Student: ${widget.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Section: ${widget.section}',
              style: const TextStyle(fontSize: 16),
            ),

            Text(
              'Year Level: ${widget.yearLevel}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            subjectInput(
              subjectLabel: 'Subject 1',
              subjectController: subject1Controller,
              scheduleController: schedule1Controller,
            ),

            subjectInput(
              subjectLabel: 'Subject 2',
              subjectController: subject2Controller,
              scheduleController: schedule2Controller,
            ),

            subjectInput(
              subjectLabel: 'Subject 3',
              subjectController: subject3Controller,
              scheduleController: schedule3Controller,
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: isSaving ? null : saveStudent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),

              child: isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}