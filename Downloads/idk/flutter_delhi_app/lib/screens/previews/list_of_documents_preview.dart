import 'package:flutter/material.dart';

class ListOfDocumentsPreview extends StatelessWidget {
  final Map<String, String> data;
  const ListOfDocumentsPreview({super.key, required this.data});

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
              'LIST OF DOCUMENTS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'List of documents produced by plaintiff or defendant with the plaint or first hearing.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),
            _buildRow('Suit No:', data['suitNo']),
            _buildRow('Year:', data['year']),
            const SizedBox(height: 20),
            _buildRow('Plaintiff Name:', data['plaintiffName']),
            const SizedBox(height: 20),
            _buildRow('Defendant Name:', data['defendantName']),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildRow('Date of Hearing:', data['dateOfHearing']),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildRow('Filed By:', data['filedBy']),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildRow('Filed Day:', data['filedDay']),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildRow('Filed Month:', data['filedMonth']),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildRow('Filed Year:', data['filedYear']),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Documents:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRow('Serial No.:', data['sno']),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : '____________________',
              style: TextStyle(
                fontSize: 14,
                color: value?.isNotEmpty == true ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
