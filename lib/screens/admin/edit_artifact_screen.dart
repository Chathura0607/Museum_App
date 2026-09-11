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
  late TextEditingController _nameSiController;
  late TextEditingController _periodController;
  late TextEditingController _yearController;
  late TextEditingController _sectionController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _descriptionSiController;
  late TextEditingController _detailsController;
  late TextEditingController _detailsSiController;
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
    _nameSiController = TextEditingController(text: widget.artifact?.nameSi ?? '');
    _periodController = TextEditingController(text: widget.artifact?.period ?? '');
    _yearController = TextEditingController(text: widget.artifact?.year ?? '');
    _sectionController = TextEditingController(text: widget.artifact?.section ?? '');
    _locationController = TextEditingController(text: widget.artifact?.location ?? '');
    _descriptionController = TextEditingController(text: widget.artifact?.description ?? '');
    _descriptionSiController = TextEditingController(text: widget.artifact?.descriptionSi ?? '');
    _detailsController = TextEditingController(text: widget.artifact?.details ?? '');
    _detailsSiController = TextEditingController(text: widget.artifact?.detailsSi ?? '');
    _imageUrlController = TextEditingController(text: widget.artifact?.imageUrl ?? '');
    _modelUrlController = TextEditingController(text: widget.artifact?.modelUrl ?? '');
    _videoUrlController = TextEditingController(text: widget.artifact?.videoUrl ?? '');
    _audioUrlController = TextEditingController(text: widget.artifact?.audioUrl ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _nameSiController.dispose();
    _periodController.dispose();
    _yearController.dispose();
    _sectionController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _descriptionSiController.dispose();
    _detailsController.dispose();
    _detailsSiController.dispose();
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
        'nameSi': _nameSiController.text.trim(),
        'period': _periodController.text.trim(),
        'year': _yearController.text.trim(),
        'section': _sectionController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'descriptionSi': _descriptionSiController.text.trim(),
        'details': _detailsController.text.trim(),
        'detailsSi': _detailsSiController.text.trim(),
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
          SnackBar(content: Text(widget.artifact == null ? 'Exhibit added successfully' : 'Exhibit updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save error: $e')),
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
      appBar: AppBar(
        title: Text(isEditing ? 'Curate Exhibit' : 'Register New Exhibit', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2C1810),
        foregroundColor: const Color(0xFFC9A84C),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Basic Identification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2C1810))),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(labelText: 'Unique Artifact ID (e.g. artifact_010)', border: OutlineInputBorder()),
                      readOnly: isEditing,
                      validator: (v) => v!.trim().isEmpty ? 'Required ID' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Name (English)', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Required Name' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _nameSiController,
                            decoration: const InputDecoration(labelText: 'නම (සිංහල)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _periodController,
                            decoration: const InputDecoration(labelText: 'Period / Era (e.g. 1500 BC)', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Required Period' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _yearController,
                            decoration: const InputDecoration(labelText: 'Specific Year (Optional)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _sectionController,
                            decoration: const InputDecoration(labelText: 'Gallery Section / Wing', border: OutlineInputBorder()),
                            validator: (v) => v!.trim().isEmpty ? 'Required Section' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(labelText: 'Physical Room / Hall', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Descriptions & Story', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2C1810))),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Short Summary (English)', border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty ? 'Required Description' : null,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionSiController,
                      decoration: const InputDecoration(labelText: 'කෙටි හැඳින්වීම (සිංහල)', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _detailsController,
                      decoration: const InputDecoration(labelText: 'Comprehensive Narrative (English)', border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty ? 'Required Details' : null,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _detailsSiController,
                      decoration: const InputDecoration(labelText: 'සවිස්තරාත්මක විස්තරය (සිංහල)', border: OutlineInputBorder()),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),
                    const Text('Digital Media Assets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2C1810))),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(labelText: 'High-Res Image URL', border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty ? 'Required Image URL' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelUrlController,
                      decoration: const InputDecoration(labelText: '3D Model Embed URL (Sketchfab/GLB - Optional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _videoUrlController,
                      decoration: const InputDecoration(labelText: 'Guide Video URL (YouTube Embed - Optional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _audioUrlController,
                      decoration: const InputDecoration(labelText: 'Audio Guide Audio URL (Optional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9A84C),
                          foregroundColor: const Color(0xFF2C1810),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _saveArtifact,
                        child: Text(
                          isEditing ? 'COMMIT UPDATES' : 'PUBLISH EXHIBIT',
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
