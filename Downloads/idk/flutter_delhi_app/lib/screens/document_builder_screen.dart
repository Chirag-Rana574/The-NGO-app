import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';
import 'package:printing/printing.dart';
import '../utils/pdf_generator_service.dart';

class FormFieldConfig {
  final String key;
  final String label;
  final String hint;

  FormFieldConfig({required this.key, required this.label, required this.hint});
}

class DocumentBuilderScreen extends StatefulWidget {
  final String formId;
  const DocumentBuilderScreen({super.key, required this.formId});

  @override
  State<DocumentBuilderScreen> createState() => _DocumentBuilderScreenState();
}

class _DocumentBuilderScreenState extends State<DocumentBuilderScreen> {
  final Map<String, TextEditingController> _controllers = {};
  
  late List<FormFieldConfig> _fields;
  late String _title;

  @override
  void initState() {
    super.initState();
    _setupFormConfig();
  }

  void _setupFormConfig() {
    switch (widget.formId) {
      case 'address_form':
        _title = 'Address Form';
        _fields = [
          FormFieldConfig(key: 'court_name', label: 'Court Name', hint: 'e.g. Tis Hazari District Court'),
          FormFieldConfig(key: 'case_name', label: 'Case Name', hint: 'e.g. State'),
          FormFieldConfig(key: 'versus', label: 'Versus', hint: 'e.g. John Doe'),
          FormFieldConfig(key: 'suit', label: 'Suit Type', hint: 'e.g. Civil Suit'),
          FormFieldConfig(key: 'date_of_hearing', label: 'Date of Hearing', hint: 'e.g. 12/10/2026'),
          FormFieldConfig(key: 'name_with_father', label: 'Name with Father\'s Name', hint: ''),
          FormFieldConfig(key: 'caste', label: 'Caste', hint: ''),
          FormFieldConfig(key: 'resident_of', label: 'Resident Of', hint: 'Address'),
          FormFieldConfig(key: 'post_office', label: 'Post Office', hint: ''),
          FormFieldConfig(key: 'tehsil', label: 'Tehsil', hint: ''),
          FormFieldConfig(key: 'distt', label: 'District', hint: 'e.g. South Delhi'),
          FormFieldConfig(key: 'remarks', label: 'Remarks', hint: ''),
        ];
        break;
      case 'case_information':
        _title = 'Case Information Format';
        _fields = [
          FormFieldConfig(key: 'case_type', label: 'Case Type', hint: 'e.g. Writ Petition'),
          FormFieldConfig(key: 'case_number', label: 'Case Number', hint: 'e.g. 123/2026'),
          FormFieldConfig(key: 'plaintiff', label: 'Plaintiff/Petitioner', hint: 'Name'),
          FormFieldConfig(key: 'defendant', label: 'Defendant/Respondent', hint: 'Name'),
          FormFieldConfig(key: 'filing_date', label: 'Filing Date', hint: 'e.g. 12/10/2026'),
        ];
        break;
      case 'bail_bond_437a':
        _title = 'Bail Bond U/S 437-A';
        _fields = [
          FormFieldConfig(key: 'court_name', label: 'Court Name', hint: ''),
          FormFieldConfig(key: 'fir_no', label: 'FIR Number', hint: ''),
          FormFieldConfig(key: 'police_station', label: 'Police Station', hint: ''),
          FormFieldConfig(key: 'accused_name', label: 'Accused Name', hint: ''),
          FormFieldConfig(key: 'accused_father', label: 'Accused Father Name', hint: ''),
          FormFieldConfig(key: 'accused_address', label: 'Accused Address', hint: ''),
          FormFieldConfig(key: 'surety_name', label: 'Surety Name', hint: ''),
          FormFieldConfig(key: 'surety_father', label: 'Surety Father Name', hint: ''),
          FormFieldConfig(key: 'surety_address', label: 'Surety Address', hint: ''),
        ];
        break;
      case 'affidavit_convict':
        _title = 'Affidavit of Convict';
        _fields = [
          FormFieldConfig(key: 'convict_name', label: 'Convict Name', hint: ''),
          FormFieldConfig(key: 'convict_age', label: 'Age', hint: ''),
          FormFieldConfig(key: 'convict_address', label: 'Address', hint: ''),
          FormFieldConfig(key: 'fir_no', label: 'FIR Number', hint: ''),
          FormFieldConfig(key: 'police_station', label: 'Police Station', hint: ''),
          FormFieldConfig(key: 'conviction_date', label: 'Conviction Date', hint: ''),
          FormFieldConfig(key: 'education', label: 'Educational Qualification', hint: ''),
          FormFieldConfig(key: 'occupation', label: 'Occupation', hint: ''),
          FormFieldConfig(key: 'income', label: 'Monthly Income', hint: ''),
          FormFieldConfig(key: 'location', label: 'Verification Location', hint: 'e.g. Delhi'),
          FormFieldConfig(key: 'date', label: 'Verification Date', hint: ''),
        ];
        break;
      case 'criminal_cai':
        _title = 'Certified Form Criminal C.A.I.';
        _fields = [
          FormFieldConfig(key: 'district', label: 'District', hint: 'e.g. South'),
          FormFieldConfig(key: 'applicant_name', label: 'Applicant Name', hint: ''),
          FormFieldConfig(key: 'resident_of', label: 'Resident Of', hint: ''),
          FormFieldConfig(key: 'parties', label: 'Parties', hint: 'e.g. State vs John'),
          FormFieldConfig(key: 'nature_of_case', label: 'Nature of Case', hint: ''),
          FormFieldConfig(key: 'date_of_decision', label: 'Date of Decision', hint: ''),
          FormFieldConfig(key: 'court', label: 'Court Name', hint: ''),
        ];
        break;
      case 'memo_appearance':
        _title = 'Memorandum of Appearance';
        _fields = [
          FormFieldConfig(key: 'courtName', label: 'In the Court of', hint: ''),
          FormFieldConfig(key: 'inRs', label: 'In Re', hint: ''),
          FormFieldConfig(key: 'versus', label: 'Versus', hint: ''),
          FormFieldConfig(key: 'onBehalfOf', label: 'Appearing on behalf of', hint: ''),
          FormFieldConfig(key: 'authorizedBy', label: 'Authorized by', hint: ''),
          FormFieldConfig(key: 'date', label: 'Date', hint: ''),
        ];
        break;
      case 'legal_meeting':
        _title = 'Legal Meeting Form';
        _fields = [
          FormFieldConfig(key: 'jailNo', label: 'Jail No.', hint: ''),
          FormFieldConfig(key: 'stateVs', label: 'State Vs.', hint: ''),
          FormFieldConfig(key: 'accusedName', label: 'Accused Name', hint: ''),
          FormFieldConfig(key: 'fatherName', label: 'Father Name', hint: ''),
          FormFieldConfig(key: 'address', label: 'Address', hint: ''),
          FormFieldConfig(key: 'advocateName', label: 'Advocate Name', hint: ''),
          FormFieldConfig(key: 'date', label: 'Date', hint: ''),
        ];
        break;
      case 'process_fee':
        _title = 'Process Fee Form';
        _fields = [
          FormFieldConfig(key: 'inTheCourtOf', label: 'In the Court of', hint: ''),
          FormFieldConfig(key: 'suitNumber', label: 'Suit/Case Number', hint: ''),
          FormFieldConfig(key: 'plaintiff', label: 'Plaintiff/Petitioner', hint: ''),
          FormFieldConfig(key: 'defendant', label: 'Defendant/Respondent', hint: ''),
          FormFieldConfig(key: 'valueOfClaim', label: 'Value of Claim', hint: ''),
          FormFieldConfig(key: 'amountOfPFees', label: 'Amount of P. Fees', hint: ''),
          FormFieldConfig(key: 'purposeOfFiling', label: 'Purpose of Filing', hint: ''),
          FormFieldConfig(key: 'number', label: 'Number', hint: ''),
          FormFieldConfig(key: 'courtFeeAffixed', label: 'Court Fee Affixed', hint: ''),
          FormFieldConfig(key: 'courtNameShri', label: 'Court of Shri (Lower)', hint: ''),
          FormFieldConfig(key: 'caseNoLower', label: 'Case No. (Lower)', hint: ''),
          FormFieldConfig(key: 'inReLeft', label: 'In Re (Left)', hint: ''),
          FormFieldConfig(key: 'inReRight', label: 'In Re (Right)', hint: ''),
          FormFieldConfig(key: 'pdohLower', label: 'P.D.O.H.', hint: ''),
          FormFieldConfig(key: 'ndohLower', label: 'N.D.O.H.', hint: ''),
          FormFieldConfig(key: 'dateOfFiling', label: 'Date of Filing', hint: ''),
        ];
        break;
      case 'extra_party_info':
        _title = 'Extra Party Information';
        _fields = [
          FormFieldConfig(key: 'party1_name', label: 'Party 1 Name', hint: ''),
          FormFieldConfig(key: 'party1_relationName', label: 'S/o, W/o, D/o', hint: ''),
          FormFieldConfig(key: 'party1_address', label: 'Address', hint: ''),
          FormFieldConfig(key: 'party1_gender', label: 'Gender', hint: ''),
          FormFieldConfig(key: 'party1_dob', label: 'Date of Birth', hint: ''),
          FormFieldConfig(key: 'party1_contactInfo', label: 'Contact Info', hint: ''),
          FormFieldConfig(key: 'party2_name', label: 'Party 2 Name', hint: ''),
          FormFieldConfig(key: 'party2_relationName', label: 'S/o, W/o, D/o', hint: ''),
          FormFieldConfig(key: 'party2_address', label: 'Address', hint: ''),
          FormFieldConfig(key: 'filledBy', label: 'Filled By (Advocate Detail)', hint: ''),
        ];
        break;
      case 'list_documents_commercial':
        _title = 'List of Documents (Commercial)';
        _fields = [
          FormFieldConfig(key: 'suitNo', label: 'Suit No', hint: ''),
          FormFieldConfig(key: 'suitYear', label: 'Suit Year', hint: ''),
          FormFieldConfig(key: 'plaintiff', label: 'Plaintiff', hint: ''),
          FormFieldConfig(key: 'defendant', label: 'Defendant', hint: ''),
          FormFieldConfig(key: 'filedBy', label: 'Filed By', hint: ''),
          FormFieldConfig(key: 'doc1_details', label: 'Document 1 Details', hint: ''),
          FormFieldConfig(key: 'doc1_custody', label: 'Custody Of', hint: ''),
          FormFieldConfig(key: 'doc1_original', label: 'Original/Photocopy', hint: ''),
          FormFieldConfig(key: 'doc1_execution', label: 'Mode of Execution', hint: ''),
          FormFieldConfig(key: 'doc1_pageNo', label: 'Page No.', hint: ''),
        ];
        break;
      case 'bail_performa':
        _title = 'Bail Application Proforma';
        _fields = [
          FormFieldConfig(key: 'firNo', label: 'FIR No.', hint: ''),
          FormFieldConfig(key: 'policeStation', label: 'Police Station', hint: ''),
          FormFieldConfig(key: 'underSection', label: 'Under Section', hint: ''),
          FormFieldConfig(key: 'nameOfAccused', label: 'Name of Accused', hint: ''),
          FormFieldConfig(key: 'fatherName', label: 'Father Name', hint: ''),
          FormFieldConfig(key: 'addressOfAccused', label: 'Address of Accused', hint: ''),
          FormFieldConfig(key: 'dateOfArrest', label: 'Date of Arrest', hint: ''),
        ];
        break;
      case 'form45_bail_bond':
        _title = 'Form 45 Bail Bond';
        _fields = [
          FormFieldConfig(key: 'policeStation', label: 'Police Station', hint: ''),
          FormFieldConfig(key: 'underSection', label: 'Under Section', hint: ''),
          FormFieldConfig(key: 'firNo', label: 'FIR No.', hint: ''),
          FormFieldConfig(key: 'accusedName', label: 'Accused Name', hint: ''),
          FormFieldConfig(key: 'bondAmount', label: 'Bond Amount (Rs.)', hint: ''),
          FormFieldConfig(key: 'suretyName', label: 'Surety Name', hint: ''),
        ];
        break;
      case 'niact_complaint':
        _title = '138 NI Act Complaint';
        _fields = [
          FormFieldConfig(key: 'courtName', label: 'Court Name', hint: ''),
          FormFieldConfig(key: 'complainant', label: 'Complainant Name', hint: ''),
          FormFieldConfig(key: 'accused', label: 'Accused Name', hint: ''),
          FormFieldConfig(key: 'chequeNo', label: 'Cheque No.', hint: ''),
          FormFieldConfig(key: 'chequeAmount', label: 'Cheque Amount', hint: ''),
          FormFieldConfig(key: 'bankName', label: 'Bank Name', hint: ''),
        ];
        break;
      case 'checklist_138':
        _title = 'Check List 138 NI Act';
        _fields = [
          FormFieldConfig(key: 'courtName', label: 'Court Name', hint: ''),
          FormFieldConfig(key: 'complainant', label: 'Complainant', hint: ''),
          FormFieldConfig(key: 'accused', label: 'Accused', hint: ''),
          FormFieldConfig(key: 'dateOfCheque', label: 'Date of Cheque', hint: ''),
          FormFieldConfig(key: 'dateOfReturn', label: 'Date of Return Memo', hint: ''),
          FormFieldConfig(key: 'dateOfNotice', label: 'Date of Legal Notice', hint: ''),
        ];
        break;
      case 'gate_pass':
        _title = 'Gate Pass Application';
        _fields = [
          FormFieldConfig(key: 'visitorName', label: 'Visitor Name', hint: ''),
          FormFieldConfig(key: 'fatherName', label: 'Father Name', hint: ''),
          FormFieldConfig(key: 'age', label: 'Age', hint: ''),
          FormFieldConfig(key: 'address', label: 'Address', hint: ''),
          FormFieldConfig(key: 'courtNo', label: 'Court No.', hint: ''),
          FormFieldConfig(key: 'itemNo', label: 'Item No.', hint: ''),
          FormFieldConfig(key: 'date', label: 'Date', hint: ''),
          FormFieldConfig(key: 'purposeOfVisit', label: 'Purpose of Visit', hint: ''),
          FormFieldConfig(key: 'recommendedByRole', label: 'Recommended By (Role)', hint: 'e.g. Advocate'),
          FormFieldConfig(key: 'recommendedByName', label: 'Recommended By (Name)', hint: ''),
        ];
        break;
      case 'urgent_mentioning':
        _title = 'Urgent Mentioning Proforma';
        _fields = [
          FormFieldConfig(key: 'natureOfMatter', label: 'Nature of Matter', hint: ''),
          FormFieldConfig(key: 'appellant', label: 'Appellant/Petitioner', hint: ''),
          FormFieldConfig(key: 'respondent', label: 'Respondent', hint: ''),
          FormFieldConfig(key: 'detailsOfJudgement', label: 'Details of Judgement', hint: ''),
          FormFieldConfig(key: 'suitNo', label: 'Suit/Appeal No.', hint: ''),
          FormFieldConfig(key: 'reasonForUrgency', label: 'Reason for Urgency', hint: ''),
          FormFieldConfig(key: 'dateOfFiling', label: 'Date of Filing', hint: ''),
          FormFieldConfig(key: 'counselName', label: 'Counsel Name', hint: ''),
          FormFieldConfig(key: 'mobileNo', label: 'Mobile No.', hint: ''),
        ];
        break;
      case 'listing_performa':
        _title = 'Listing Proforma';
        _fields = [
          FormFieldConfig(key: 'category', label: 'Category', hint: ''),
          FormFieldConfig(key: 'natureOfCase', label: 'Nature of Case', hint: ''),
          FormFieldConfig(key: 'appellant', label: 'Appellant', hint: ''),
          FormFieldConfig(key: 'respondent', label: 'Respondent', hint: ''),
          FormFieldConfig(key: 'dateOfJudgement', label: 'Date of Judgement', hint: ''),
          FormFieldConfig(key: 'act', label: 'Act', hint: ''),
          FormFieldConfig(key: 'natureOfOffence', label: 'Nature of Offence', hint: ''),
          FormFieldConfig(key: 'dateOfFiling', label: 'Date of Filing', hint: ''),
          FormFieldConfig(key: 'counselName', label: 'Counsel Name', hint: ''),
          FormFieldConfig(key: 'enrolmentNo', label: 'Enrolment No.', hint: ''),
          FormFieldConfig(key: 'mobileNo', label: 'Mobile No.', hint: ''),
          FormFieldConfig(key: 'email', label: 'Email', hint: ''),
          FormFieldConfig(key: 'address', label: 'Address', hint: ''),
        ];
        break;
      case 'vakalatnama':
      case 'vakalatnama_delhi':
        _title = 'Vakalatnama';
        _fields = [
          FormFieldConfig(key: 'court', label: 'Court', hint: 'e.g. Delhi High Court'),
          FormFieldConfig(key: 'case_type', label: 'Case Type', hint: 'e.g. Writ Petition (Civil)'),
          FormFieldConfig(key: 'case_number', label: 'Case Number (if known)', hint: 'e.g. 123/2026'),
          FormFieldConfig(key: 'plaintiffs', label: 'Plaintiffs / Petitioners', hint: 'Names, comma separated'),
          FormFieldConfig(key: 'defendants', label: 'Defendants / Respondents', hint: 'Names, comma separated'),
          FormFieldConfig(key: 'advocate_name', label: 'Advocate Name', hint: 'e.g. Mr. John Doe'),
          FormFieldConfig(key: 'advocate_enrollment', label: 'Enrollment Number', hint: 'e.g. D/123/2010'),
        ];
        break;
      case 'rti_application':
        _title = 'RTI Application Form';
        _fields = [
          FormFieldConfig(key: 'pio', label: 'Public Information Officer (PIO)', hint: 'e.g. PIO, Delhi Police'),
          FormFieldConfig(key: 'applicantName', label: 'Applicant Name', hint: ''),
          FormFieldConfig(key: 'applicantAddress', label: 'Applicant Address', hint: ''),
          FormFieldConfig(key: 'informationRequired', label: 'Information Required', hint: ''),
          FormFieldConfig(key: 'feeDetails', label: 'Fee Details (IPO/DD No.)', hint: ''),
          FormFieldConfig(key: 'date', label: 'Date', hint: ''),
        ];
        break;
      case 'index_form':
        _title = 'Index Form';
        _fields = [
          FormFieldConfig(key: 'courtName', label: 'Court Name', hint: 'e.g., District & Sessions Judge, Delhi'),
          FormFieldConfig(key: 'jurisdiction', label: 'Jurisdiction Type', hint: 'e.g., Civil Appeal / Criminal Revision'),
          FormFieldConfig(key: 'caseNumber', label: 'Suit / Case Number', hint: 'e.g., Civil Suit No. 123 of 2024'),
          FormFieldConfig(key: 'petitioner', label: 'Petitioner / Appellant Name', hint: ''),
          FormFieldConfig(key: 'respondent', label: 'Respondent / Defendant Name', hint: ''),
          FormFieldConfig(key: 'indexEntries', label: 'Index Entries', hint: 'S.No | Particulars | Pages'),
          FormFieldConfig(key: 'filedDate', label: 'Date of Filing', hint: ''),
          FormFieldConfig(key: 'advocateFor', label: 'Advocate For', hint: 'Plaintiff/Appellant or Defendant'),
        ];
        break;
      case 'inspection_form':
        _title = 'Inspection Form';
        _fields = [
          FormFieldConfig(key: 'courtName', label: 'IN THE COURT OF', hint: ''),
          FormFieldConfig(key: 'caseNoYear', label: 'Case No. and Year', hint: 'e.g., 123 of 2024'),
          FormFieldConfig(key: 'inTheMatterOf', label: 'IN THE MATTER OF', hint: 'Petitioner/Appellant'),
          FormFieldConfig(key: 'versus', label: 'VERSUS', hint: 'Respondent'),
          FormFieldConfig(key: 'firCaseNo', label: 'FIR / Case No.', hint: ''),
          FormFieldConfig(key: 'ndoh', label: 'Next Date of Hearing', hint: ''),
          FormFieldConfig(key: 'counselFor', label: 'Counsel for', hint: 'Plaintiff/Defendant'),
          FormFieldConfig(key: 'advocateName', label: 'Advocate Name', hint: ''),
          FormFieldConfig(key: 'advocateAddress', label: 'Advocate Address', hint: ''),
          FormFieldConfig(key: 'date', label: 'DATED', hint: ''),
          FormFieldConfig(key: 'representing', label: 'For the Petitioner/Respondent', hint: ''),
        ];
        break;
      case 'civil_certified_copy':
        _title = 'Civil Certified Copy Form';
        _fields = [
          FormFieldConfig(key: 'courtName', label: 'Court Name', hint: ''),
          FormFieldConfig(key: 'petitioner', label: 'Petitioner', hint: ''),
          FormFieldConfig(key: 'respondent', label: 'Respondent', hint: ''),
          FormFieldConfig(key: 'caseNoDate', label: 'Case No. and Date', hint: ''),
          FormFieldConfig(key: 'descriptionOfPapers', label: 'Description of Papers', hint: ''),
          FormFieldConfig(key: 'purpose', label: 'Purpose for which copy is required', hint: ''),
          FormFieldConfig(key: 'feeAmount', label: 'Fee Amount', hint: ''),
        ];
        break;
      case 'bail_bond_116':
        _title = 'Bail Bond 116 (3) Cr.P.C.';
        _fields = [
          FormFieldConfig(key: 'courtName', label: 'न्यायालय (Court Name)', hint: ''),
          FormFieldConfig(key: 'stateVs', label: 'सरकार बनाम (State Versus)', hint: ''),
          FormFieldConfig(key: 'policeStation', label: 'थाना (Police Station)', hint: ''),
          FormFieldConfig(key: 'underSection', label: 'धारा (Under Section)', hint: ''),
          FormFieldConfig(key: 'ddNo', label: 'डी. डी. नं. (D.D. No.)', hint: ''),
          FormFieldConfig(key: 'accusedName', label: 'मैं (Accused Name)', hint: ''),
          FormFieldConfig(key: 'accusedFather', label: 'पुत्र (Accused Father)', hint: ''),
          FormFieldConfig(key: 'accusedAddress', label: 'निवासी (Accused Address)', hint: ''),
          FormFieldConfig(key: 'suretyName', label: 'जमानतनामा - मैं (Surety Name)', hint: ''),
          FormFieldConfig(key: 'suretyFather', label: 'पुत्र (Surety Father)', hint: ''),
          FormFieldConfig(key: 'suretyAddress', label: 'निवासी (Surety Address)', hint: ''),
          FormFieldConfig(key: 'bondAmountWords', label: 'Bond Amount (in words)', hint: ''),
          FormFieldConfig(key: 'deponentName', label: 'AFFIDAVIT - I (Deponent Name)', hint: ''),
        ];
        break;
      case 'annexure_b_bail_bond':
        _title = 'Annexure B - Bail Bond';
        _fields = [
          FormFieldConfig(key: 'courtName', label: 'Court Name', hint: ''),
          FormFieldConfig(key: 'underSection', label: 'Under Section', hint: ''),
          FormFieldConfig(key: 'accusedName', label: 'Accused Name', hint: ''),
          FormFieldConfig(key: 'suretyName', label: 'Surety Name', hint: ''),
          FormFieldConfig(key: 'bondAmount', label: 'Bond Amount', hint: ''),
        ];
        break;
      default:
        _title = 'Document Form';
        _fields = [
          FormFieldConfig(key: 'field1', label: 'Field 1', hint: ''),
          FormFieldConfig(key: 'field2', label: 'Field 2', hint: ''),
        ];
        break;
    }

    for (var field in _fields) {
      _controllers[field.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _generateAndPreviewPdf() async {
    final Map<String, String> data = {};
    for (var field in _fields) {
      data[field.key] = _controllers[field.key]?.text ?? '';
    }

    final bytes = await PdfGeneratorService.generatePdf(widget.formId, data);

    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: '${widget.formId}_document.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ground,
      appBar: const LalAppBar(title: 'Doc Builder'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_title, style: AppTextStyles.screenTitle(color: context.textPri)),
                Row(
                  children: [
                    Text('In Progress', style: AppTextStyles.label(color: context.info)),
                    const SizedBox(width: 8),
                    Icon(Icons.edit_document, size: 16, color: context.info),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            PietraCard(
              accentColor: context.info,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Document Details', style: AppTextStyles.chatTitle(color: context.textPri)),
                  const SizedBox(height: 16),
                  
                  ..._fields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(field.label, style: AppTextStyles.label(color: context.textSec)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _controllers[field.key],
                            decoration: InputDecoration(
                              hintText: field.hint,
                              filled: true,
                              fillColor: context.raised,
                              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(4)),
                            ),
                            style: AppTextStyles.body(color: context.textPri),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _generateAndPreviewPdf,
              icon: Icon(Icons.picture_as_pdf, color: context.sandGlow),
              label: const Text('Save & Export as PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: context.sandGlow,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                textStyle: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
