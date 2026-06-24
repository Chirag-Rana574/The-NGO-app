// Document Registry - Maps form IDs to their configurations
// Based on React src/documents/registry.ts

import '../features/document_builder/domain/document_field.dart';
export '../features/document_builder/domain/document_field.dart';

class DocumentConfig {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? icon;
  final String? templatePdf;
  final List<DocumentField> fields;

  DocumentConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.icon,
    this.templatePdf,
    required this.fields,
  });
}

// Registry Entry - combines config with preview identifier
class RegistryEntry {
  final DocumentConfig config;
  final String previewId;

  RegistryEntry({
    required this.config,
    required this.previewId,
  });
}

class DocumentRegistry {
  static final Map<String, RegistryEntry> forms = {

    // Check List 138 NI Act
    'checkList138': RegistryEntry(
      config: DocumentConfig(
        id: 'checkList138',
        title: 'Check List 138 NI Act',
        description: 'Check List for Complaint Under Section 138 of the Negotiable Instruments Act',
        category: 'Criminal',
        templatePdf: 'assets/templates/CHECK LIST 138 NI ACT.pdf',
        fields: [
          DocumentField(key: 'casedetails', label: 'Case Details', type: FieldType.text),
          DocumentField(key: 'chkamt', label: 'Cheque Amount', type: FieldType.text),
          DocumentField(key: 'areabounchk', label: 'Area Bound Check', type: FieldType.text),
          DocumentField(key: 'name1', label: 'Name 1', type: FieldType.text),
          DocumentField(key: 'address1', label: 'Address 1', type: FieldType.text),
          DocumentField(key: 'age1', label: 'Age1', type: FieldType.text),
          DocumentField(key: 'gender1', label: 'Gender1', type: FieldType.text),
          DocumentField(key: 'cntno1', label: 'Contact No 1', type: FieldType.text),
          DocumentField(key: 'name2', label: 'Name 2', type: FieldType.text),
          DocumentField(key: 'address2', label: 'Address 2', type: FieldType.text),
          DocumentField(key: 'age2', label: 'Age2', type: FieldType.text),
          DocumentField(key: 'gender2', label: 'Gender2', type: FieldType.text),
          DocumentField(key: 'cntno2', label: 'Contact No 2', type: FieldType.text),
          DocumentField(key: 'name3', label: 'Name 3', type: FieldType.text),
          DocumentField(key: 'address3', label: 'Address 3', type: FieldType.text),
          DocumentField(key: 'age3', label: 'Age3', type: FieldType.text),
          DocumentField(key: 'gender3', label: 'Gender3', type: FieldType.text),
          DocumentField(key: 'cntno3', label: 'Contact No 3', type: FieldType.text),
          DocumentField(key: 'name4', label: 'Name 4', type: FieldType.text),
          DocumentField(key: 'address4', label: 'Address 4', type: FieldType.text),
          DocumentField(key: 'age4', label: 'Age4', type: FieldType.text),
          DocumentField(key: 'gender4', label: 'Gender4', type: FieldType.text),
          DocumentField(key: 'cntno4', label: 'Contact No 4', type: FieldType.text),
          DocumentField(key: 'psname', label: 'Police Station Name', type: FieldType.text),
          DocumentField(key: 'anyotherinfo', label: 'Any Other Info', type: FieldType.text),
        ],
      ),
      previewId: 'checkList138',
    ),
    // Extra Party Information Form
    'extraPartyInfo': RegistryEntry(
      config: DocumentConfig(
        id: 'extraPartyInfo',
        title: 'Extra Party Information Form',
        description: 'Extra Party Information for Court Records',
        category: 'General',
        templatePdf: 'assets/templates/EXTRA PARTY INFORMATION FORM.pdf',
        fields: [
          DocumentField(key: 'n1', label: 'Name (Person 1)', type: FieldType.text),
          DocumentField(key: 'swd1', label: 'S/W/D of (Person 1)', type: FieldType.text),
          DocumentField(key: 'add1', label: 'Address (Person 1)', type: FieldType.textarea),
          DocumentField(key: 'g1', label: 'Gender (Person 1)', type: FieldType.text),
          DocumentField(key: 'dob1', label: 'DOB (Person 1)', type: FieldType.text),
          DocumentField(key: 'mobnoemail1', label: 'Mobile / Email (Person 1)', type: FieldType.text),
          DocumentField(key: 'n2', label: 'Name (Person 2)', type: FieldType.text),
          DocumentField(key: 'swd2', label: 'S/W/D of (Person 2)', type: FieldType.text),
          DocumentField(key: 'add2', label: 'Address (Person 2)', type: FieldType.textarea),
          DocumentField(key: 'g2', label: 'Gender (Person 2)', type: FieldType.text),
          DocumentField(key: 'dob2', label: 'DOB (Person 2)', type: FieldType.text),
          DocumentField(key: 'mobnoemail2', label: 'Mobile / Email (Person 2)', type: FieldType.text),
          DocumentField(key: 'n3', label: 'Name (Person 3)', type: FieldType.text),
          DocumentField(key: 'swd3', label: 'S/W/D of (Person 3)', type: FieldType.text),
          DocumentField(key: 'add3', label: 'Address (Person 3)', type: FieldType.textarea),
          DocumentField(key: 'g3', label: 'Gender (Person 3)', type: FieldType.text),
          DocumentField(key: 'dob3', label: 'DOB (Person 3)', type: FieldType.text),
          DocumentField(key: 'mobnoemail3', label: 'Mobile / Email (Person 3)', type: FieldType.text),
          DocumentField(key: 'n4', label: 'Name (Person 4)', type: FieldType.text),
          DocumentField(key: 'swd4', label: 'S/W/D of (Person 4)', type: FieldType.text),
          DocumentField(key: 'add4', label: 'Address (Person 4)', type: FieldType.textarea),
          DocumentField(key: 'g4', label: 'Gender (Person 4)', type: FieldType.text),
          DocumentField(key: 'dob4', label: 'DOB (Person 4)', type: FieldType.text),
          DocumentField(key: 'mobnoemail4', label: 'Mobile / Email (Person 4)', type: FieldType.text),
          DocumentField(key: 'filledby', label: 'Filled By', type: FieldType.text),
        ],
      ),
      previewId: 'extraPartyInfo',
    ),

    // Vakalatnama
    'vakalatnama': RegistryEntry(
      config: DocumentConfig(
        id: 'vakalatnama',
        title: 'Vakalatnama',
        description: 'Power of Attorney authorizing an advocate to represent a client.',
        category: 'Civil Procedure',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'courtName', label: 'Court Name', type: FieldType.text, required: true, placeholder: 'e.g., DELHI HIGH COURT, NEW DELHI'),
          DocumentField(key: 'caseType', label: 'Case Type (Suit/Appeal No.)', type: FieldType.text, required: true, placeholder: 'e.g., CS(OS) / FA No.'),
          DocumentField(key: 'caseNumber', label: 'Case Number & Year', type: FieldType.text, required: true, placeholder: 'e.g., 123 of 2024'),
          DocumentField(key: 'jurisdictionYear', label: 'Jurisdiction Year (Optional)', type: FieldType.text, placeholder: 'e.g., 2024'),
          DocumentField(key: 'plaintiffs', label: 'Plaintiff(s) / Petitioner(s)', type: FieldType.textarea, required: true, placeholder: 'Names and details of plaintiffs'),
          DocumentField(key: 'defendants', label: 'Defendant(s) / Respondent(s)', type: FieldType.textarea, required: true, placeholder: 'Names and details of defendants'),
          DocumentField(key: 'clientNames', label: 'Name(s) of Client(s)', type: FieldType.textarea, required: true, placeholder: 'Names of persons appointing the advocate'),
          DocumentField(key: 'advocateNames', label: 'Advocate(s) Name', type: FieldType.textarea, required: true, placeholder: 'Names of advocates being appointed'),
          DocumentField(key: 'executionDay', label: 'Execution Day', type: FieldType.text, required: true, placeholder: 'e.g., 15th'),
          DocumentField(key: 'executionMonth', label: 'Execution Month', type: FieldType.text, required: true, placeholder: 'e.g., October'),
          DocumentField(key: 'executionYear', label: 'Execution Year', type: FieldType.text, required: true, placeholder: 'e.g., 24'),
        ],
      ),
      previewId: 'vakalatnama',
    ),
    // Legal Meeting
    'legalMeeting': RegistryEntry(
      config: DocumentConfig(
        id: 'legalMeeting',
        title: 'Legal Meeting Form',
        description: 'Application to the Jail Superintendent for a legal meeting with an inmate.',
        category: 'Applications',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'jailNo', label: 'Jail No.', type: FieldType.text, required: true),
          DocumentField(key: 'stateVs', label: 'State Vs.', type: FieldType.textarea, required: true),
          DocumentField(key: 'accusedName', label: 'Accused Name', type: FieldType.text, required: true),
          DocumentField(key: 'fatherName', label: 'Father Name', type: FieldType.text, required: true),
          DocumentField(key: 'address', label: 'Address', type: FieldType.textarea, required: true),
          DocumentField(key: 'advocateName', label: 'Advocate Name', type: FieldType.text, required: true),
          DocumentField(key: 'Day', label: 'Day', type: FieldType.text),
          DocumentField(key: 'month', label: 'Month', type: FieldType.text),
          DocumentField(key: 'year', label: 'Year', type: FieldType.text),
          DocumentField(key: 'fortheaccused', label: 'For the Accused', type: FieldType.text),
        ],
      ),
      previewId: 'legalMeeting',
    ),
    // Bail Bond 437A
    'bailBond437a': RegistryEntry(
      config: DocumentConfig(
        id: 'bailBond437a',
        title: 'Bail Bond U/S 437-A CR.P.C.',
        description: 'Surety/Personal bond under Section 437-A Cr.P.C.',
        category: 'Criminal',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'courtName', label: 'In the court of Sh.', type: FieldType.text, required: true),
          DocumentField(key: 'policeStation', label: 'P.S.', type: FieldType.text),
          DocumentField(key: 'underSection', label: 'U/S', type: FieldType.text),
          DocumentField(key: 'firNo', label: 'FIR No.', type: FieldType.text),
          DocumentField(key: 'accusedName', label: 'I (Accused Name)', type: FieldType.text, required: true),
          DocumentField(key: 'accusedFather', label: 'S/o. Sh.', type: FieldType.text),
          DocumentField(key: 'accusedAddress', label: 'R/o (Accused Address)', type: FieldType.textarea, required: true),
          DocumentField(key: 'acquittalDate', label: 'Acquitted by this Hon\'ble Court on (Date)', type: FieldType.date),
          DocumentField(key: 'bondFirNo', label: 'in above said case FIR No.', type: FieldType.text),
          DocumentField(key: 'bondPs', label: 'P.S. (in bond)', type: FieldType.text),
          DocumentField(key: 'bondUs', label: 'U/s (in bond)', type: FieldType.text),
          DocumentField(key: 'bondAmount', label: 'sum of Rs. (Accused Bond)', type: FieldType.text),
          DocumentField(key: 'suretyName', label: 'I (Surety Name)', type: FieldType.text, required: true),
          DocumentField(key: 'suretyFather', label: 'S/o. Sh. (Surety Father)', type: FieldType.text),
          DocumentField(key: 'suretyAddress', label: 'R/o (Surety Address)', type: FieldType.textarea, required: true),
          DocumentField(key: 'suretyFor', label: 'for the above said Sh. (Accused Name in Surety)', type: FieldType.text),
          DocumentField(key: 'suretyForFather', label: 'S/o (Accused Father in Surety)', type: FieldType.text),
          DocumentField(key: 'suretyAmount', label: 'sum of Rs. (Surety Bond)', type: FieldType.text),
        ],
      ),
      previewId: 'bailBond437a',
    ),
    // Bail Performa
    'bailPerforma': RegistryEntry(
      config: DocumentConfig(
        id: 'bailPerforma',
        title: 'Bail Application Proforma',
        description: 'Standard proforma accompanying bail applications.',
        category: 'Criminal',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'firNo', label: 'FIR No.', type: FieldType.text, required: true),
          DocumentField(key: 'policeStation', label: 'Police Station', type: FieldType.text),
          DocumentField(key: 'underSection', label: 'Under Section', type: FieldType.text),
          DocumentField(key: 'nameOfAccused', label: 'Name of Accused', type: FieldType.text, required: true),
          DocumentField(key: 'fatherName', label: 'Father Name', type: FieldType.text),
          DocumentField(key: 'addressOfAccused', label: 'Address of Accused', type: FieldType.textarea, required: true),
          DocumentField(key: 'dateOfArrest', label: 'Date of Arrest', type: FieldType.date),
        ],
      ),
      previewId: 'bailPerforma',
    ),
    // Case Information
    'caseInformation': RegistryEntry(
      config: DocumentConfig(
        id: 'caseInformation',
        title: 'Case Information Format',
        description: 'Standard format for filing case information.',
        category: 'General',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'case_type', label: 'Case Type', type: FieldType.text, required: true, placeholder: 'e.g. Writ Petition'),
          DocumentField(key: 'case_number', label: 'Case Number', type: FieldType.text, required: true, placeholder: 'e.g. 123/2026'),
          DocumentField(key: 'plaintiff', label: 'Plaintiff/Petitioner', type: FieldType.text, required: true, placeholder: 'Name'),
          DocumentField(key: 'defendant', label: 'Defendant/Respondent', type: FieldType.text, required: true, placeholder: 'Name'),
          DocumentField(key: 'filing_date', label: 'Filing Date', type: FieldType.date, required: true),
        ],
      ),
      previewId: 'caseInformation',
    ),
    // RTI Application
    'rtiApplication': RegistryEntry(
      config: DocumentConfig(
        id: 'rtiApplication',
        title: 'RTI Application Form',
        description: 'Application for Information under RTI Act, 2005.',
        category: 'General',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'applicantName', label: 'Applicant Name', type: FieldType.text, required: true),
          DocumentField(key: 'address', label: 'Address', type: FieldType.textarea, required: true),
          DocumentField(key: 'city', label: 'City', type: FieldType.text),
          DocumentField(key: 'state', label: 'State', type: FieldType.text),
          DocumentField(key: 'pinCode', label: 'PIN Code', type: FieldType.text),
          DocumentField(key: 'informationRequired', label: 'Information Required', type: FieldType.textarea, required: true),
        ],
      ),
      previewId: 'rtiApplication',
    ),
    // Urgent Mentioning
    'urgentMentioning': RegistryEntry(
      config: DocumentConfig(
        id: 'urgentMentioning',
        title: 'Urgent Mentioning Proforma',
        description: 'Application for out-of-turn urgent hearing of a matter.',
        category: 'Delhi High Court',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'courtName', label: 'Court Name', type: FieldType.text, required: true),
          DocumentField(key: 'caseType', label: 'Case Type', type: FieldType.text, required: true),
          DocumentField(key: 'caseNumber', label: 'Case Number', type: FieldType.text, required: true),
          DocumentField(key: 'groundsForUrgency', label: 'Reason for Urgency', type: FieldType.textarea, required: true),
          DocumentField(key: 'date', label: 'Date', type: FieldType.date, required: true),
        ],
      ),
      previewId: 'urgentMentioning',
    ),
    // Gate Pass
    'gatePass': RegistryEntry(
      config: DocumentConfig(
        id: 'gatePass',
        title: 'Gate Pass Application',
        description: 'Application for issue of visitors pass for entry into court.',
        category: 'Delhi High Court',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'visitorName', label: 'Visitor Name', type: FieldType.textarea, required: true),
          DocumentField(key: 'fatherName', label: 'Father Name', type: FieldType.textarea, required: true),
          DocumentField(key: 'age', label: 'Age', type: FieldType.textarea, required: true),
          DocumentField(key: 'address', label: 'Visitor Address', type: FieldType.textarea, required: true),
          DocumentField(key: 'courtNo', label: 'Court No.', type: FieldType.textarea, required: true),
          DocumentField(key: 'itemNo', label: 'Item No.', type: FieldType.textarea, required: true),
          DocumentField(key: 'purposeOfVisit', label: 'Purpose of Visit', type: FieldType.textarea, required: true),
          DocumentField(key: 'date', label: 'Date', type: FieldType.date, required: true),
        ],
      ),
      previewId: 'gatePass',
    ),
    // Inspection Form
    'inspectionForm': RegistryEntry(
      config: DocumentConfig(
        id: 'inspectionForm',
        title: 'Inspection Form',
        description: 'Humble Application for Inspection of the Court File.',
        category: 'General',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'courtName', label: 'Court Name', type: FieldType.text, required: true),
          DocumentField(key: 'caseType', label: 'Case Type', type: FieldType.text, required: true),
          DocumentField(key: 'caseNumber', label: 'Case Number', type: FieldType.text, required: true),
          DocumentField(key: 'applicantName', label: 'Applicant Name', type: FieldType.text, required: true),
          DocumentField(key: 'purpose', label: 'Purpose of Inspection', type: FieldType.textarea, required: true),
        ],
      ),
      previewId: 'inspectionForm',
    ),
    // Listing Performa
    'listingPerforma': RegistryEntry(
      config: DocumentConfig(
        id: 'listingPerforma',
        title: 'Listing Proforma',
        description: 'Required proforma to categorize and list cases in court.',
        category: 'Delhi High Court',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'courtNo', label: 'Court No.', type: FieldType.text, required: true),
          DocumentField(key: 'caseType', label: 'Case Type', type: FieldType.text, required: true),
          DocumentField(key: 'caseNumber', label: 'Case Number', type: FieldType.text, required: true),
          DocumentField(key: 'parties', label: 'Parties', type: FieldType.textarea, required: true),
          DocumentField(key: 'listingCategory', label: 'Listing Category', type: FieldType.select, options: ['Urgent', 'Normal', 'Conditional', 'Adjournment']),
        ],
      ),
      previewId: 'listingPerforma',
    ),
    // NI Act Complaint
    'niActComplaint': RegistryEntry(
      config: DocumentConfig(
        id: 'niActComplaint',
        title: '138 NI Act Complaint',
        description: 'Draft complaint for cheque bounce under Sec 138 NI Act.',
        category: 'Criminal',
        icon: 'FileText',
        fields: [
          DocumentField(key: 'courtName', label: 'Court Name', type: FieldType.text, required: true),
          DocumentField(key: 'complainant', label: 'Complainant Name', type: FieldType.text, required: true),
          DocumentField(key: 'accused', label: 'Accused Name', type: FieldType.text, required: true),
          DocumentField(key: 'chequeNo', label: 'Cheque No.', type: FieldType.text, required: true),
          DocumentField(key: 'chequeAmount', label: 'Cheque Amount', type: FieldType.text, required: true),
          DocumentField(key: 'bankName', label: 'Bank Name', type: FieldType.text, required: true),
          DocumentField(key: 'chequeDate', label: 'Cheque Date', type: FieldType.date, required: true),
        ],
      ),
      previewId: 'niActComplaint',
    ),
    // Certified Form (Criminal C.A.I.)
    'certifiedForm': RegistryEntry(
      config: DocumentConfig(
        id: 'certifiedForm',
        title: 'Certified Form Criminal CAI',
        description: 'Application for copy Urgent/Ordinary',
        category: 'Criminal Documents',
        templatePdf: 'assets/templates/CERTIFIED FORM CRIMINAL CAI.pdf',
        fields: [
          DocumentField(key: 'distoffname', label: 'Dist. Off. Name', type: FieldType.text, required: true),
          DocumentField(key: 'applname', label: 'Applicant Name', type: FieldType.text, required: true),
          DocumentField(key: 'relname', label: 'Relation Name', type: FieldType.text, required: true),
          DocumentField(key: 'appladdr', label: 'Applicant Address', type: FieldType.text, required: true),
          DocumentField(key: 'pdanddist', label: 'P.D. and Dist.', type: FieldType.text, required: true),
          DocumentField(key: 'descandcaseno', label: 'Description and Case No.', type: FieldType.text, required: true),
          DocumentField(key: 'psname', label: 'P.S. Name', type: FieldType.text, required: true),
          DocumentField(key: 'goshwarano', label: 'Goshwara No.', type: FieldType.text, required: true),
          DocumentField(key: 'district', label: 'District', type: FieldType.text, required: true),
          DocumentField(key: 'nameOfParties', label: 'Name of Parties', type: FieldType.text, required: true),
          DocumentField(key: 'natureOfCase', label: 'Nature of Case', type: FieldType.text, required: true),
          DocumentField(key: 'nextDate', label: 'Next Date', type: FieldType.text, required: true),
          DocumentField(key: 'courtName', label: 'Court Name', type: FieldType.text, required: true),
          DocumentField(key: 'dateOfOrderEtc', label: 'Date of Order etc.', type: FieldType.text, required: true),
          DocumentField(key: 'nameOfDescription', label: 'Name of Description', type: FieldType.text, required: true),
          DocumentField(key: 'purposeForCopy', label: 'Purpose for Copy', type: FieldType.text, required: true),
          DocumentField(key: 'appno', label: 'App. No.', type: FieldType.text, required: true),
          DocumentField(key: 'valu', label: 'Value', type: FieldType.text, required: true),
          DocumentField(key: 'attendeename', label: 'Attendee Name', type: FieldType.text, required: true),
          DocumentField(key: 'date', label: 'Date', type: FieldType.text, required: true),
          DocumentField(key: 'applord', label: 'App. Lord', type: FieldType.text, required: true),
          DocumentField(key: 'Date', label: 'Date', type: FieldType.text, required: true),
          DocumentField(key: 'DATE', label: 'DATE', type: FieldType.text, required: true),
        ],
      ),
      previewId: 'certifiedForm',
    ),
    // List of Documents
    'listOfDocuments': RegistryEntry(
      config: DocumentConfig(
        id: 'listOfDocuments',
        title: 'List of Documents',
        description: 'List of documents produced by plaintiff or defendant with the plaint or first hearing.',
        category: 'General Documents',
        templatePdf: 'assets/templates/LIST OF DOCUMENTS.pdf',
        fields: [
          DocumentField(key: 'suitNo', label: 'Suit No', type: FieldType.text, required: true),
          DocumentField(key: 'year', label: 'Year', type: FieldType.text, required: true),
          DocumentField(key: 'plaintiffName', label: 'Plaintiff Name', type: FieldType.text, required: true),
          DocumentField(key: 'defendantName', label: 'Defendant Name', type: FieldType.text, required: true),
          DocumentField(key: 'dateOfHearing', label: 'Date of Hearing', type: FieldType.date, required: true),
          DocumentField(key: 'filedBy', label: 'Filed By', type: FieldType.text, required: true),
          DocumentField(key: 'filedDay', label: 'Filed Day', type: FieldType.text, required: true),
          DocumentField(key: 'filedMonth', label: 'Filed Month', type: FieldType.text, required: true),
          DocumentField(key: 'filedYear', label: 'Filed Year', type: FieldType.text, required: true),
          DocumentField(key: 'sno', label: 'Serial Number', type: FieldType.text, required: false),
        ],
      ),
      previewId: 'listOfDocuments',
    ),
    // Memorandum of Appearance
    'memorandumOfAppearance': RegistryEntry(
      config: DocumentConfig(
        id: 'memorandumOfAppearance',
        title: 'Memorandum of Appearance',
        description: 'Memorandum of Appearance for Advocates/Pleaders.',
        category: 'General Documents',
        templatePdf: 'assets/templates/Memorandum of Appearance.pdf',
        fields: [
          DocumentField(key: 'courtName', label: 'Court Name', type: FieldType.text, required: true),
          DocumentField(key: 'inRs', label: 'In Rs', type: FieldType.text, required: true),
          DocumentField(key: 'versus', label: 'Versus', type: FieldType.text, required: true),
          DocumentField(key: 'onBehalfOf', label: 'On Behalf Of', type: FieldType.text, required: true),
          DocumentField(key: 'onBehalfOf1', label: 'On Behalf Of 1', type: FieldType.text, required: true),
          DocumentField(key: 'onBehalfOf2', label: 'On Behalf Of 2', type: FieldType.text, required: true),
          DocumentField(key: 'authorizedBy', label: 'Authorized By', type: FieldType.text, required: true),
          DocumentField(key: 'authorizedBy1', label: 'Authorized By 1', type: FieldType.text, required: true),
          DocumentField(key: 'date', label: 'Date', type: FieldType.text, required: true),
        ],
      ),
      previewId: 'memorandumOfAppearance',
    ),
  };

  static List<RegistryEntry> getByCategory(String category) {
    return forms.values.where((entry) => entry.config.category == category).toList();
  }

  static List<RegistryEntry> getAll() => forms.values.toList();
  
  static RegistryEntry? getById(String id) {
    if (forms.containsKey(id)) {
      return forms[id];
    }
    final normalizedId = id.toLowerCase().replaceAll('_', '');
    for (final entry in forms.entries) {
      final normalizedKey = entry.key.toLowerCase().replaceAll('_', '');
      if (normalizedKey == normalizedId) {
        return entry.value;
      }
    }
    return null;
  }
}
