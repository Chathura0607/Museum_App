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
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;
  bool _submitted = false;

  final List<String> _impressionTags = [
    "✨ Stunning 3D Models",
    "🎧 Clear Audio Guide",
    "📜 Rich Historical Detail",
    "🏛️ Beautiful Presentation",
    "🔍 Great Translation",
    "📱 Easy Navigation",
  ];

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

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
        'tags': _selectedTags.toList(),
        'comment': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit. Please check connection.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Experience Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF2C1810),
        foregroundColor: const Color(0xFFC9A84C),
      ),
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFCFAF7),
      body: _submitted ? _buildThankYou(isDark) : _buildForm(isDark),
    );
  }

  Widget _buildThankYou(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A84C).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFFC9A84C), size: 72),
            ),
            const SizedBox(height: 24),
            Text(
              'Thank You, Explorer!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFC9A84C),
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your thoughts on "${widget.artifact.name}" have been preserved in the museum archives.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: 200,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A84C),
                  foregroundColor: const Color(0xFF2C1810),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CONTINUE TOUR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artifact header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.brown.shade100),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    widget.artifact.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.museum_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.artifact.name,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.artifact.period} • ${widget.artifact.section}',
                        style: const TextStyle(color: Color(0xFFC9A84C), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Star rating
          const Center(
            child: Text(
              'How was your exhibit experience?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNum = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = starNum),
                icon: Icon(
                  starNum <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: const Color(0xFFC9A84C),
                  size: 42,
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          // Impression chips
          const Text('Quick Impressions:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _impressionTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag, style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF2C1810) : null)),
                selected: isSelected,
                selectedColor: const Color(0xFFC9A84C),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          const Text(
            'Personal Notes or Suggestions:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Share your impressions or thoughts with the curator...',
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.brown.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A84C),
                foregroundColor: const Color(0xFF2C1810),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 6,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Color(0xFF2C1810))
                  : const Text(
                      'SUBMIT REVIEW',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
