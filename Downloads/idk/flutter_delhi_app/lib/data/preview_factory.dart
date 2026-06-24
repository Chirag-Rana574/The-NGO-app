import 'package:flutter/material.dart';
import 'package:delhi_legal_assistant/screens/previews/vakalatnama_preview.dart';
import 'package:delhi_legal_assistant/screens/previews/legal_meeting_preview.dart';
import 'package:delhi_legal_assistant/screens/previews/certified_form_preview.dart';
import 'package:delhi_legal_assistant/screens/previews/list_of_documents_preview.dart';
import 'package:delhi_legal_assistant/screens/previews/memorandum_of_appearance_preview.dart';

/// Factory function to build preview widgets for each document type
/// This is in a separate file to avoid circular imports
Widget buildDocumentPreview(String previewId, Map<String, String> data) {
  switch (previewId) {
    case 'vakalatnama':
      return VakalatnamaPreview(data: data);
    case 'legalMeeting':
      return LegalMeetingPreview(data: data);
    case 'bailBond437a':
      return _BailBond437aPreview(data: data);
    case 'bailPerforma':
      return _BailPerformaPreview(data: data);
    case 'caseInformation':
      return _CaseInformationPreview(data: data);
    case 'rtiApplication':
      return _RtiApplicationPreview(data: data);
    case 'urgentMentioning':
      return _UrgentMentioningPreview(data: data);
    case 'gatePass':
      return _GatePassPreview(data: data);
    case 'inspectionForm':
      return _InspectionFormPreview(data: data);
    case 'listingPerforma':
      return _ListingPerformaPreview(data: data);
    case 'niActComplaint':
      return _NiActComplaintPreview(data: data);
    case 'certifiedForm':
      return CertifiedFormPreview(data: data);
    case 'listOfDocuments':
      return ListOfDocumentsPreview(data: data);
    case 'memorandumOfAppearance':
      return MemorandumOfAppearancePreview(data: data);
    default:
      return const Center(child: Text('No preview available', style: TextStyle(fontSize: 24)));
  }
}

// Placeholder preview widgets - will be replaced with proper implementations
class _BailBond437aPreview extends StatelessWidget {
  final Map<String, String> data;
  const _BailBond437aPreview({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text('Bail Bond 437A Preview for ${data['accusedName'] ?? 'unknown'}', style: const TextStyle(fontSize: 18)),
    );
  }
}

class _BailPerformaPreview extends StatelessWidget {
  final Map<String, String> data;
  const _BailPerformaPreview({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text('Bail Application Proforma Preview', style: const TextStyle(fontSize: 18)),
    );
  }
}

class _CaseInformationPreview extends StatelessWidget {
  final Map<String, String> data;
  const _CaseInformationPreview({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text('Case Information Format Preview', style: const TextStyle(fontSize: 18)),
    );
  }
}

class _RtiApplicationPreview extends StatelessWidget {
  final Map<String, String> data;
  const _RtiApplicationPreview({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text('RTI Application Preview', style: const TextStyle(fontSize: 18)),
    );
  }
}

class _UrgentMentioningPreview extends StatelessWidget {
  final Map<String, String> data;
  const _UrgentMentioningPreview({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text('Urgent Mentioning Proforma Preview', style: const TextStyle(fontSize: 18)),
    );
  }
}

class _GatePassPreview extends StatelessWidget {
  final Map<String, String> data;
  const _GatePassPreview({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text('Gate Pass Application Preview', style: const TextStyle(fontSize: 18)),
    );
  }
}

class _InspectionFormPreview extends StatelessWidget {
  final Map<String, String> data;
  const _InspectionFormPreview({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text('Inspection Form Preview', style: const TextStyle(fontSize: 18)),
    );
  }
}

class _ListingPerformaPreview extends StatelessWidget {
  final Map<String, String> data;
  const _ListingPerformaPreview({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text('Listing Proforma Preview', style: const TextStyle(fontSize: 18)),
    );
  }
}

class _NiActComplaintPreview extends StatelessWidget {
  final Map<String, String> data;
  const _NiActComplaintPreview({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text('138 NI Act Complaint Preview', style: const TextStyle(fontSize: 18)),
    );
  }
}