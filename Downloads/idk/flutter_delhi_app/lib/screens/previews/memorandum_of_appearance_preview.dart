import 'package:flutter/material.dart';

class MemorandumOfAppearancePreview extends StatelessWidget {
  final Map<String, String> data;
  const MemorandumOfAppearancePreview({super.key, required this.data});

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
              'MEMORANDUM OF APPEARANCE',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Memorandum of Appearance for Advocates/Pleaders',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),
            _buildRow('Court Name:', data['courtName']),
            _buildRow('In Rs:', data['inRs']),
            const SizedBox(height: 20),
            _buildRow('Versus:', data['versus']),
            const SizedBox(height: 20),
            _buildRow('On Behalf Of:', data['onBehalfOf']),
            _buildRow('On Behalf Of 1:', data['onBehalfOf1']),
            _buildRow('On Behalf Of 2:', data['onBehalfOf2']),
            const SizedBox(height: 20),
            _buildRow('Authorized By:', data['authorizedBy']),
            _buildRow('Authorized By 1:', data['authorizedBy1']),
            const SizedBox(height: 20),
            _buildRow('Date:', data['date']),
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
            width: 180,
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
