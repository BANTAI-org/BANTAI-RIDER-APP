import 'package:flutter/material.dart';

class CommsChatPanel extends StatelessWidget {
  const CommsChatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: Color(0xFFB8E8C3),
                child: Icon(Icons.person, color: Color(0xFF318A4A), size: 30),
              ),
              SizedBox(height: 10),
              Text(
                'Radio channel ready',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'OAuth is not configured for this screen yet.',
                style: TextStyle(color: Color(0xFF858894), fontSize: 12),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.mic_none),
                  label: Text('Request Channel'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nearby Rider Chat',
          style: TextStyle(color: Color(0xFF858894), fontSize: 12),
        ),
        const SizedBox(height: 8),
        const Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Authenticated rider messaging will be connected when OAuth is enabled.',
              style: TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
        ),
      ],
    );
  }
}
