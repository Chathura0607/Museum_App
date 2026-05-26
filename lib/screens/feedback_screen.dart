import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artifact.dart';

class FeedbackScreen extends StatefulWidget {
  final Artifact artifact;
  const FeedbackScreen({super.key, required this.artifact});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating!')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _firestore.collection('feedback').add({
        'artifactId': widget.artifact.id,
        'artifactName': widget.artifact.name,
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate your Experience'),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: _submitted ? _buildThankYou() : _buildForm(),
    );
  }

  Widget _buildThankYou() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 24),
          const Text('Thank you!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text('Your review of "${widget.artifact.name}" has been successfully recorded.',
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[800], foregroundColor: Colors.white),
              child: const Text('DONE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.artifact.imageUrl,
                  width: 80, height: 80, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.museum)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.artifact.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    Text(widget.artifact.section, style: TextStyle(color: Colors.brown[600], fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Center(child: Text('How would you rate this exhibit?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFC9A84C),
                  size: 40,
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          const Text('Tell us more about what you liked or disliked:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Your feedback matters...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SUBMIT FEEDBACK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}
