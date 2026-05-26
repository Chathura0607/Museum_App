import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/artifact.dart';

class EditArtifactScreen extends StatefulWidget {
  final Artifact? artifact;

  const EditArtifactScreen({super.key, this.artifact});

  @override
  State<EditArtifactScreen> createState() => _EditArtifactScreenState();
}

class _EditArtifactScreenState extends State<EditArtifactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _periodController;
  late TextEditingController _yearController;
  late TextEditingController _sectionController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _detailsController;
  late TextEditingController _imageUrlController;
  late TextEditingController _modelUrlController;
  late TextEditingController _videoUrlController;
  late TextEditingController _audioUrlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.artifact?.id ?? '');
    _nameController = TextEditingController(text: widget.artifact?.name ?? '');
    _periodController = TextEditingController(text: widget.artifact?.period ?? '');
    _yearController = TextEditingController(text: widget.artifact?.year ?? '');
    _sectionController = TextEditingController(text: widget.artifact?.section ?? '');
    _locationController = TextEditingController(text: widget.artifact?.location ?? '');
    _descriptionController = TextEditingController(text: widget.artifact?.description ?? '');
    _detailsController = TextEditingController(text: widget.artifact?.details ?? '');
    _imageUrlController = TextEditingController(text: widget.artifact?.imageUrl ?? '');
    _modelUrlController = TextEditingController(text: widget.artifact?.modelUrl ?? '');
    _videoUrlController = TextEditingController(text: widget.artifact?.videoUrl ?? '');
    _audioUrlController = TextEditingController(text: widget.artifact?.audioUrl ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _periodController.dispose();
    _yearController.dispose();
    _sectionController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _detailsController.dispose();
    _imageUrlController.dispose();
    _modelUrlController.dispose();
    _videoUrlController.dispose();
    _audioUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveArtifact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final id = _idController.text.trim();
      final data = {
        'name': _nameController.text.trim(),
        'period': _periodController.text.trim(),
        'year': _yearController.text.trim(),
        'section': _sectionController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'details': _detailsController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'modelUrl': _modelUrlController.text.trim(),
        'videoUrl': _videoUrlController.text.trim(),
        'audioUrl': _audioUrlController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.artifact == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await FirebaseFirestore.instance.collection('artifacts').doc(id).set(data, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.artifact == null ? 'Artifact added' : 'Artifact updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.artifact != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Artifact' : 'Add New Artifact')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(labelText: 'Artifact ID'),
                    readOnly: isEditing,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _periodController,
                          decoration: const InputDecoration(labelText: 'Period'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(labelText: 'Exact Year (Optional)'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sectionController,
                          decoration: const InputDecoration(labelText: 'Section'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(labelText: 'Museum Location'),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Short Description'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    maxLines: 2,
                  ),
                  TextFormField(
                    controller: _detailsController,
                    decoration: const InputDecoration(labelText: 'Detailed Description'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    maxLines: 5,
                  ),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _modelUrlController,
                    decoration: const InputDecoration(labelText: '3D Model URL (Optional)'),
                  ),
                  TextFormField(
                    controller: _videoUrlController,
                    decoration: const InputDecoration(labelText: 'Video URL (Optional)'),
                  ),
                  TextFormField(
                    controller: _audioUrlController,
                    decoration: const InputDecoration(labelText: 'Audio Guide URL (Optional)'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveArtifact,
                      child: Text(isEditing ? 'Update Artifact' : 'Save Artifact'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
