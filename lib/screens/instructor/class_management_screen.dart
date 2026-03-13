import 'package:flutter/material.dart';
import '../../models/class_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class ClassManagementScreen extends StatefulWidget {
  final ClassModel? existingClass;

  const ClassManagementScreen({super.key, this.existingClass});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _radiusController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  bool get isEditing => widget.existingClass != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.existingClass!.name;
      _latController.text = widget.existingClass!.latitude.toString();
      _lngController.text = widget.existingClass!.longitude.toString();
      _radiusController.text = widget.existingClass!.radius.toString();
      _scheduleController.text = widget.existingClass!.schedule;
    } else {
      _radiusController.text = '100';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final classModel = ClassModel(
        id: isEditing ? widget.existingClass!.id : '',
        name: _nameController.text.trim(),
        instructorId: _authService.currentUser!.uid,
        latitude: double.tryParse(_latController.text) ?? 0,
        longitude: double.tryParse(_lngController.text) ?? 0,
        radius: double.tryParse(_radiusController.text) ?? 100,
        schedule: _scheduleController.text.trim(),
      );

      if (isEditing) {
        await _firestoreService.updateClass(
          widget.existingClass!.id,
          classModel.toMap(),
        );
      } else {
        await _firestoreService.createClass(classModel);
      }

      if (mounted) {
        Helpers.showSnackBar(
          context,
          isEditing ? 'Class updated!' : 'Class created!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Error: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Class' : 'Create Class')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  validator: (v) => Validators.required(v, 'Class name'),
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    prefixIcon: Icon(Icons.class_),
                    hintText: 'e.g., CS101 - Intro to Computer Science',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _scheduleController,
                  decoration: const InputDecoration(
                    labelText: 'Schedule',
                    prefixIcon: Icon(Icons.schedule),
                    hintText: 'e.g., Mon/Wed 10:00 AM - 11:30 AM',
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Classroom Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the GPS coordinates of the classroom for attendance verification.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (v) => Validators.required(v, 'Latitude'),
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          hintText: 'e.g., 13.7563',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (v) => Validators.required(v, 'Longitude'),
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          hintText: 'e.g., 100.5018',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _radiusController,
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.required(v, 'Radius'),
                  decoration: const InputDecoration(
                    labelText: 'Radius (meters)',
                    prefixIcon: Icon(Icons.radar),
                    hintText: '100',
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(isEditing ? 'Update Class' : 'Create Class'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
