import 'package:flutter/material.dart';
import '../../utils/validators.dart';

class PostReflectionScreen extends StatefulWidget {
  const PostReflectionScreen({super.key});

  @override
  State<PostReflectionScreen> createState() => _PostReflectionScreenState();
}

class _PostReflectionScreenState extends State<PostReflectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learningSummaryController = TextEditingController();
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _learningSummaryController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, {
      'learningSummary': _learningSummaryController.text.trim(),
      'feedback': _feedbackController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post-Class Reflection')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'After class...',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _learningSummaryController,
                  maxLines: 4,
                  validator: (v) => Validators.required(v, 'Learning summary'),
                  decoration: const InputDecoration(
                    labelText: 'What did you learn today?',
                    alignLabelWithHint: true,
                    hintText: 'Summarize the key concepts...',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 4,
                  validator: (v) => Validators.required(v, 'Feedback'),
                  decoration: const InputDecoration(
                    labelText: 'Feedback about the class',
                    alignLabelWithHint: true,
                    hintText: 'Any feedback about the class or instructor...',
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit & Finish Class'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
