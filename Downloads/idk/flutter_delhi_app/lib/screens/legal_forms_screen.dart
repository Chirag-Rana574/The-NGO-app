import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';

class LegalFormsScreen extends StatelessWidget {
  const LegalFormsScreen({super.key});

  final List<Map<String, dynamic>> formCategories = const [
    {
      "category": "Delhi High Court Specific",
      "forms": [
        { "name": "Delhi High Court Checklist", "desc": "Mandatory pre-filing checklist for writ petitions and appeals.", "file": "delhi_high_court_checklist" },
        { "name": "Listing Proforma", "desc": "Required proforma to categorize and list cases in the High Court.", "file": "listing_performa" },
        { "name": "Urgent Mentioning Form", "desc": "Application for out-of-turn urgent hearing of a matter.", "file": "urgent_mentioning" },
        { "name": "Vakalatnama (Delhi High Court)", "desc": "Specialized Vakalatnama format for the Delhi High Court.", "file": "vakalatnama_delhi" },
        { "name": "Gate Pass Application", "desc": "Application for issue of visitors pass for entry into the High Court.", "file": "gate_pass" },
        { "name": "Supreme Court Form", "desc": "Supreme Court specific legal forms.", "file": "supreme_court_form" },
        { "name": "District Courts Form", "desc": "District Court specific legal forms.", "file": "district_courts_form" },
      ]
    },
    {
      "category": "Criminal Law & Bail",
      "forms": [
        { "name": "138 NI Act Complaint", "desc": "Draft complaint for cheque bounce under Sec 138 NI Act.", "file": "niact_complaint" },
        { "name": "Check List 138 NI Act", "desc": "Filing checklist for Negotiable Instruments Act complaints.", "file": "checklist_138" },
        { "name": "Bail Application Proforma", "desc": "Standard proforma accompanying bail applications.", "file": "bail_performa" },
        { "name": "Form 45 Bail Bond", "desc": "Surety/Personal bond under Section 437/438/439 Cr.P.C.", "file": "form45_bail_bond" },
        { "name": "Bail Bond U/S 437-A CR.P.C", "desc": "Surety/Personal bond under Section 437-A Cr.P.C.", "file": "bail_bond_437a" },
        { "name": "Bail Bond 116 (3) Cr.P.C.", "desc": "Bail Bond U/S 116 (3) Cr.P.C. (Hindi/English).", "file": "bail_bond_116" },
        { "name": "Annexure B Bail Bond", "desc": "Supplementary bail bond form.", "file": "annexure_b_bail_bond" },
        { "name": "Certified Form Criminal C.A.I.", "desc": "Application to obtain certified copies of criminal court records.", "file": "criminal_cai" },
        { "name": "Affidavit of Convict", "desc": "Standard affidavit format required from a convict.", "file": "affidavit_convict" },
        { "name": "Inspection Form", "desc": "Humble Application for Inspection of the Court File.", "file": "inspection_form" },
      ]
    },
    {
      "category": "Commercial & Civil Courts",
      "forms": [
        { "name": "List of Documents (Commercial)", "desc": "Format for filing documents under the Commercial Courts Act.", "file": "list_documents_commercial" },
        { "name": "Extra Party Information", "desc": "Detailed format for providing information of additional parties.", "file": "extra_party_info" },
        { "name": "Index Form", "desc": "Standard Index page attached to the front of a case file.", "file": "index_form" },
        { "name": "Civil Certified Copy Form", "desc": "Application for certified copies in civil cases.", "file": "civil_certified_copy" },
      ]
    },
    {
      "category": "General Practice & Applications",
      "forms": [
        { "name": "Case Information Format", "desc": "Standard format for filing case information.", "file": "case_information" },
        { "name": "Address Form", "desc": "Form for providing party address details.", "file": "address_form" },
        { "name": "Vakalatnama (General)", "desc": "Standard Power of Attorney authorizing an advocate to represent a client.", "file": "vakalatnama" },
        { "name": "Memorandum of Appearance", "desc": "Memo filed by an advocate to formally appear in a case.", "file": "memo_appearance" },
        { "name": "Process Fee Form", "desc": "Form filed for depositing process fee and diet money.", "file": "process_fee" },
        { "name": "Legal Meeting Form", "desc": "Application to the Jail Superintendent for a legal interview with an inmate.", "file": "legal_meeting" },
        { "name": "RTI Application Form", "desc": "Application for Information under RTI Act, 2005.", "file": "rti_application" },
        { "name": "List of Documents", "desc": "List of documents produced with plaint or first hearing.", "file": "listOfDocuments" },
      ]
    }
  ];

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ground,
      appBar: const LalAppBar(title: 'Legal Forms Directory'),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeSlide(
                  child: Text(
                    'Access and generate rigorously formatted, court-compliant legal templates.',
                    style: AppTextStyles.bodySec(color: context.textSec),
                  ),
                ),
                const SizedBox(height: 24),
                
                FadeSlide(
                  delay: const Duration(milliseconds: 100),
                  child: PietraCard(
                    accentColor: Colors.orange,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Compliance Notice', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold, color: Colors.orange)),
                              const SizedBox(height: 4),
                              Text(
                                'These templates have been specifically calibrated to match strict court formatting guidelines (e.g., precise grid structures, margins, and typography) for the Delhi High Court and District Courts.',
                                style: AppTextStyles.bodySmall(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ...formCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  return FadeSlide(
                    delay: Duration(milliseconds: 150 + (index * 50)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category['category'] as String, style: AppTextStyles.screenTitle(color: context.textPri)),
                          const SizedBox(height: 12),
                          ...(category['forms'] as List).map((form) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: PietraCard(
                                accentColor: Colors.transparent,
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(form['name'] as String, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(form['desc'] as String, style: AppTextStyles.bodySmall(color: context.textSec)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => context.push('/document_builder?formId=${form['file']}'),
                                      icon: Icon(Icons.arrow_forward, size: 16, color: context.surface),
                                      label: Text('Open', style: AppTextStyles.bodySmall(color: context.surface).copyWith(fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: context.success,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),

                FadeSlide(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.raised,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Official Court Resources', style: AppTextStyles.screenTitle(color: context.textPri).copyWith(fontSize: 18)),
                        const SizedBox(height: 16),
                        _buildResourceLink(context, 'Delhi District Courts - Official Forms', 'https://delhicourts.nic.in/forms.htm'),
                        const SizedBox(height: 12),
                        _buildResourceLink(context, 'Delhi High Court - Forms & Formats', 'https://delhihighcourt.nic.in/web/online-forms-downloadable-forms'),
                        const SizedBox(height: 12),
                        _buildResourceLink(context, 'Supreme Court of India - Forms', 'https://www.sci.gov.in/forms/'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceLink(BuildContext context, String title, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Row(
        children: [
          Icon(Icons.open_in_new, size: 16, color: AppColors.lal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodySmall(color: context.textSec).copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
