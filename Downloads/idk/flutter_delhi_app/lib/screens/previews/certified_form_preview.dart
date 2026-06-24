import 'package:flutter/material.dart';

class CertifiedFormPreview extends StatelessWidget {
  final Map<String, String> data;
  const CertifiedFormPreview({super.key, required this.data});

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
              'CERTIFIED FORM CRIMINAL C.A.I.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Application for Certified Copy (Urgent/Ordinary)',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),
            _buildRow('Dist. Off. Name:', data['distoffname']),
            _buildRow('Applicant Name:', data['applname']),
            _buildRow('Relation Name:', data['relname']),
            _buildRow('Applicant Address:', data['appladdr']),
            _buildRow('P.D. and Dist.:', data['pdanddist']),
            _buildRow('Description and Case No.:', data['descandcaseno']),
            _buildRow('P.S. Name:', data['psname']),
            _buildRow('Goshwara No.:', data['goshwarano']),
            _buildRow('District:', data['district']),
            _buildRow('Name of Parties:', data['nameOfParties']),
            _buildRow('Nature of Case:', data['natureOfCase']),
            _buildRow('Next Date:', data['nextDate']),
            _buildRow('Court Name:', data['courtName']),
            _buildRow('Date of Order etc.:', data['dateOfOrderEtc']),
            _buildRow('Name of Description:', data['nameOfDescription']),
            _buildRow('Purpose for Copy:', data['purposeForCopy']),
            _buildRow('App. No.:', data['appno']),
            _buildRow('Value:', data['valu']),
            _buildRow('Attendee Name:', data['attendeename']),
            _buildRow('Date:', data['date']),
            _buildRow('App. Lord:', data['applord']),
            _buildRow('Date:', data['Date']),
            _buildRow('DATE:', data['DATE']),
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
