import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';
import 'package:tutor_finder/features/tutors/presentation/tutors_provider.dart';

class EditTutorProfileScreen extends ConsumerStatefulWidget {
  const EditTutorProfileScreen({super.key, required this.tutorId});

  final String tutorId;

  @override
  ConsumerState<EditTutorProfileScreen> createState() =>
      _EditTutorProfileScreenState();
}

class _EditTutorProfileScreenState
    extends ConsumerState<EditTutorProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _schoolController = TextEditingController();
  final _fieldController = TextEditingController();
  final _priceController = TextEditingController();
  final _availabilityController = TextEditingController();

  EducationStatus _educationStatus = EducationStatus.learning;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _schoolController.dispose();
    _fieldController.dispose();
    _priceController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  void _loadProfile(TutorProfile tutor) {
    if (_initialized) return;

    _nameController.text = tutor.name;
    _bioController.text = tutor.bio;
    _schoolController.text = tutor.school;
    _fieldController.text = tutor.fieldOfStudy;
    _priceController.text = tutor.pricePerHour.toString();
    _availabilityController.text = tutor.availability.join(', ');
    _educationStatus = tutor.educationStatus;

    _initialized = true;
  }

  Future<void> _save(TutorProfile tutor) async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim());

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid hourly price.')),
      );
      return;
    }

    final updatedProfile = tutor.copyWith(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      school: _schoolController.text.trim(),
      fieldOfStudy: _fieldController.text.trim(),
      pricePerHour: price,
      educationStatus: _educationStatus,
      availability: _availabilityController.text
          .split(',')
          .map((day) => day.trim())
          .where((day) => day.isNotEmpty)
          .toList(),
    );

    setState(() => _saving = true);

    try {
      await ref.read(tutorsProvider.notifier).updateProfile(updatedProfile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutor = ref.watch(tutorByIdProvider(widget.tutorId));

    if (tutor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Tutor Profile')),
        body: const Center(child: Text('Tutor profile not found.')),
      );
    }

    _loadProfile(tutor);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Tutor Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your name'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Biography',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your biography'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _schoolController,
              decoration: const InputDecoration(
                labelText: 'School / University',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your school'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _fieldController,
              decoration: const InputDecoration(
                labelText: 'Field of study',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your field of study'
                  : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<EducationStatus>(
              initialValue: _educationStatus,
              decoration: const InputDecoration(
                labelText: 'Education status',
                border: OutlineInputBorder(),
              ),
              items: EducationStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(
                    status == EducationStatus.learning
                        ? 'Currently learning'
                        : 'Graduated',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _educationStatus = value);
                }
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Hourly price (ETB)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final price = double.tryParse(value ?? '');
                if (price == null || price <= 0) {
                  return 'Enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _availabilityController,
              decoration: const InputDecoration(
                labelText: 'Availability',
                hintText: 'Monday, Wednesday, Saturday',
                helperText: 'Separate available days with commas.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _saving ? null : () => _save(tutor),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Saving...' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
