import 'package:flutter/material.dart';
import '../../widgets/mood_selector.dart';
import '../../utils/validators.dart';

class PreReflectionScreen extends StatefulWidget {
  const PreReflectionScreen({super.key});

  @override
  State<PreReflectionScreen> createState() => _PreReflectionScreenState();
}

class _PreReflectionScreenState extends State<PreReflectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();
  int _mood = 3;

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, {
      'previousTopic': _previousTopicController.text.trim(),
      'expectedTopic': _expectedTopicController.text.trim(),
      'mood': _mood,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Class Reflection')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Before class begins...',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _previousTopicController,
                  maxLines: 3,
                  validator: (v) => Validators.required(v, 'Previous topic'),
                  decoration: const InputDecoration(
                    labelText: 'What topic was covered in the previous class?',
                    alignLabelWithHint: true,
                    hintText: 'e.g., Introduction to databases...',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _expectedTopicController,
                  maxLines: 3,
                  validator: (v) => Validators.required(v, 'Expected topic'),
                  decoration: const InputDecoration(
                    labelText: 'What topic do you expect to learn today?',
                    alignLabelWithHint: true,
                    hintText: 'e.g., SQL queries and joins...',
                  ),
                ),
                const SizedBox(height: 24),
                MoodSelector(
                  selectedMood: _mood,
                  onMoodChanged: (m) => setState(() => _mood = m),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit & Check In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
