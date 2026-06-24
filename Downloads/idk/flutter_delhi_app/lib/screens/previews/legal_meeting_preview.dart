import 'package:flutter/material.dart';

class LegalMeetingPreview extends StatelessWidget {
  final Map<String, String> data;
  const LegalMeetingPreview({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'The Jail Superintendent,\n${data['jailName'] ?? '____________________'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text('Subject: Application for Legal Meeting', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Respected Sir/Madam,', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Text(
              'I am ${data['advocateName'] ?? '____________________'}, Advocate for the applicant ${_getAccusedName()}.\n\n'
              'I wish to apply for a legal meeting with the under-trial prisoner in the case:\n'
              'State Vs. ${_getAccusedName()}\n'
              'Jail No.: ${data['jailNo'] ?? '__________'}\n'
              'FIR No.: ${data['firNo'] ?? '__________'} dated ${data['firDate'] ?? '__________'}',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Date: ${data['date'] ?? '_/_/_/_'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerRight,
              child: Text('(${data['advocateName'] ?? 'Advocate Name'})\nAdvocate', style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  String _getAccusedName() => data['accusedName'] ?? '____________________';
}