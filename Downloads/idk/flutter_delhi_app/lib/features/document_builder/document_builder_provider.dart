import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/document_registry.dart';

// All document configs
final allDocumentConfigsProvider = Provider<List<DocumentConfig>>((ref) {
  return [
    DocumentConfig(
      id: 'vakalatnama',
      title: 'Vakalatnama',
      description: 'Power of Attorney authorizing an advocate to represent a client.',
      category: 'Civil Procedure',
      icon: 'FileText',
      fields: [
        DocumentField(key: 'courtName', label: 'Court Name', type: FieldType.text, required: true),
        DocumentField(key: 'caseType', label: 'Case Type', type: FieldType.text, required: true),
        DocumentField(key: 'caseNumber', label: 'Case Number', type: FieldType.text, required: true),
        DocumentField(key: 'plaintiffs', label: 'Plaintiff(s)', type: FieldType.textarea, required: true),
        DocumentField(key: 'defendants', label: 'Defendant(s)', type: FieldType.textarea, required: true),
        DocumentField(key: 'clientNames', label: 'Client Names', type: FieldType.textarea, required: true),
        DocumentField(key: 'advocateNames', label: 'Advocate Names', type: FieldType.textarea, required: true),
      ],
    ),
    DocumentConfig(
      id: 'rtiApplication',
      title: 'RTI Application',
      description: 'Application for Information under RTI Act, 2005.',
      category: 'General',
      icon: 'FileText',
      fields: [
        DocumentField(key: 'applicantName', label: 'Applicant Name', type: FieldType.text, required: true),
        DocumentField(key: 'address', label: 'Address', type: FieldType.textarea, required: true),
        DocumentField(key: 'informationRequired', label: 'Information Required', type: FieldType.textarea, required: true),
      ],
    ),
    DocumentConfig(
      id: 'bailPerforma',
      title: 'Bail Application Proforma',
      description: 'Standard proforma accompanying bail applications.',
      category: 'Criminal',
      icon: 'FileText',
      fields: [
        DocumentField(key: 'firNo', label: 'FIR No.', type: FieldType.text, required: true),
        DocumentField(key: 'nameOfAccused', label: 'Name of Accused', type: FieldType.text, required: true),
        DocumentField(key: 'addressOfAccused', label: 'Address of Accused', type: FieldType.textarea, required: true),
      ],
    ),
  ];
});

// Document configs by category
final documentConfigsByCategoryProvider = Provider<Map<String, List<DocumentConfig>>>((ref) {
  final configs = ref.watch(allDocumentConfigsProvider);
  final Map<String, List<DocumentConfig>> byCategory = {};
  
  for (final config in configs) {
    if (!byCategory.containsKey(config.category)) {
      byCategory[config.category] = [];
    }
    byCategory[config.category]!.add(config);
  }
  
  return byCategory;
});

// Categories list
final documentCategoriesProvider = Provider<List<String>>((ref) {
  final byCategory = ref.watch(documentConfigsByCategoryProvider);
  return byCategory.keys.toList();
});