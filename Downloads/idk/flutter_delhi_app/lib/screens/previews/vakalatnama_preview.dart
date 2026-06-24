import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vakalatnama Preview — Pixel-accurate Legal-size document renderer
///
/// Renders a live preview matching the exact template:
/// - Page size: Legal (8.5"×14" / 215.9mm×355.6mm)
/// - Font: Carlito (metrically identical to Calibri)
/// - Margins: 25.4mm left, 19mm right, 10.9mm top, 4.9mm bottom
/// - Line height: 1.15 (Word "single")
///
/// Three states: empty (dotted placeholders), active (highlighted), filled (bold blue).
class VakalatnamaPreview extends StatelessWidget {
  final Map<String, String> data;
  final String? activeField;

  const VakalatnamaPreview({
    super.key,
    required this.data,
    this.activeField,
  });

  // Immutable legal clauses from the original DOCX
  static const List<String> _authorizationClauses = [
    'To act, appear and plead in the above-noted case in this court or in any other court in which the same may be tried or heard and also in the appellate court including High Court subject to payment of fees separately for each court by me/us.',
    'To sign file, verify and present pleadings, appeals cross-objection or petitions for executions review, revision, withdrawal, compromise or other petitions or affidavits or other documents as may be deemed necessary or proper for the prosecution of the said case in all its stages subjects to payment of fees for each stage.',
    'To file and take back documents, to admit and/or deny the documents of opposite party.',
    'To withdraw or compromise the said case or submit to arbitration any differences of disputes that may arise touching or in any manner relating to the said case.',
    'To take execution proceedings on paying separate fee.',
    'To deposit, draw and receive money, cheques, cash and grant receipts hereof and to do all other acts and things which may be necessary to be done for the progress and in the course of the prosecution on the said case.',
    'To appoint and instruct any other Legal Practitioner authorizing him to exercise the power and authority hereby conferred upon the Advocate whenever he may think fit to do so and to sign the power of attorney on our behalf.',
  ];

  static const String _ratificationClause =
      'And I/we undersigned to hereby agree to ratify and confirm all acts done by the Advocate or his substitute in the matter as my/our own acts, as if done by me/us to all intents and purpose.';

  static const String _appearanceClause =
      'And I/we undertake that I/We or my/our duly authorized agent would appear in court on all hearings and will inform the Advocate for appearance when the case is called.';

  static const String _liabilityClause =
      'And I/We undersigned do hereby agree not to hold the advocate or his substitute responsible for the result of the said case. The adjournment costs whenever ordered by the court shall be of the Advocate which he shall receive and retain for himself.';

  static const String _feeClause =
      'And I/we undersigned do hereby agree that in the event of the whole or part of the fee agreed by me/us to be paid to the advocate remaining unpaid he shall be entitled to withdraw from the prosecution of the said case until the same is paid up. The fee settle is only for the above case and above Court. I/We hereby agree that once the fee is paid, I /We will not be entitled for the refund of the same in any case whatsoever and if the case prolongs for more than 3 years the original fee shall be paid again by me/us.';

  // Clauses that use justified alignment
  static const List<int> _justifiedClauseIndices = [0, 1, 5, 6];
  // Clauses that use full left indent instead of firstLine indent
  static const List<int> _leftIndentClauseIndices = [2, 4];

  @override
  Widget build(BuildContext context) {
    final carlitoFont = GoogleFonts.carlito();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate scale to fit the Legal-size page in the available width
        const pageWidthMm = 215.9;
        const pageWidthPx = pageWidthMm * (96 / 25.4); // ~816px at 96dpi
        final availableWidth = constraints.maxWidth - 48; // Account for padding
        final scale = availableWidth / pageWidthPx;

        return Center(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: pageWidthPx,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                padding: const EdgeInsets.only(
                  left: 25.4 * (96 / 25.4),  // 25.4mm
                  right: 19.0 * (96 / 25.4),  // 19mm
                  top: 10.9 * (96 / 25.4),    // 10.9mm
                  bottom: 4.9 * (96 / 25.4),  // 4.9mm
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stamp box (centered on page)
                    Center(
                      child: Container(
                        width: 124.6 * (96 / 25.4),
                        height: 18.8 * (96 / 25.4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 30 * (96 / 25.4)),

                    // Header: Court Name
                    _buildField(
                      'IN THE COURT OF ${_getValue("courtName", "____________________")}',
                      fieldName: 'courtName',
                      isActive: activeField == 'courtName',
                      isFilled: data['courtName']?.isNotEmpty ?? false,
                      style: carlitoFont.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 6 * (96 / 25.4)),

                    // Case Number + Jurisdiction on same line
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _buildInlineField(
                                _getValue("caseType", "Suit/Appeal"),
                                fieldName: 'caseType',
                                isActive: activeField == 'caseType',
                                isFilled: data['caseType']?.isNotEmpty ?? false,
                                style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                                placeholder: "Suit/Appeal",
                              ),
                              const Text(' No ', style: TextStyle(fontSize: 14, height: 1.15)),
                              _buildInlineField(
                                _getValue("caseNumber", ""),
                                fieldName: 'caseNumber',
                                isActive: activeField == 'caseNumber',
                                isFilled: data['caseNumber']?.isNotEmpty ?? false,
                                style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                                placeholder: "......................................................................................................",
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 34 * (96 / 25.4)),
                        Text(
                          'JURISDICTION OF 20',
                          style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                        ),
                        _buildInlineField(
                          _getValue("jurisdictionYear", ""),
                          fieldName: 'jurisdictionYear',
                          isActive: activeField == 'jurisdictionYear',
                          isFilled: data['jurisdictionYear']?.isNotEmpty ?? false,
                          style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                          placeholder: "1_",
                        ),
                      ],
                    ),
                    SizedBox(height: 40 * (96 / 25.4)),

                    // Parties section
                    const Text('In re:-', style: TextStyle(fontSize: 14, height: 1.15)),
                    SizedBox(height: 20 * (96 / 25.4)),

                    // Plaintiffs
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            _getValue("plaintiffs", "......................................................................"),
                            fieldName: 'plaintiffs',
                            isActive: activeField == 'plaintiffs',
                            isFilled: data['plaintiffs']?.isNotEmpty ?? false,
                            style: carlitoFont.copyWith(fontSize: 14, height: 1.15, decoration: TextDecoration.underline),
                          ),
                        ),
                        SizedBox(width: 8 * (96 / 25.4)),
                        Text(
                          'Plaintiff(s) or Petitioner(s)',
                          style: carlitoFont.copyWith(fontSize: 12, height: 1.15),
                        ),
                      ],
                    ),
                    SizedBox(height: 40 * (96 / 25.4)),

                    // VERSUS
                    const Text(
                      'VERSUS',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.15),
                    ),
                    SizedBox(height: 40 * (96 / 25.4)),

                    // Defendants + "Know all..." paragraph
                    _buildField(
                      '${_getValue("defendants", "....................................")} Defendant(s)/Respondent(s)/Accused '
                      'Know all to whom these Present shall come that I/we ${_getValue("plaintiffs", "...............................................................................................................................................................")}',
                      fieldName: 'defendants',
                      isActive: activeField == 'defendants',
                      isFilled: data['defendants']?.isNotEmpty ?? false,
                      style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                    ),
                    SizedBox(height: 4 * (96 / 25.4)),

                    // "The above named..." paragraph
                    _buildField(
                      'The above named ${_getValue("plaintiffs", "...................................................................................................")} '
                      '${_getValue("advocates", "..........................................................................")} do hereby appoint',
                      fieldName: 'advocates',
                      isActive: activeField == 'advocates',
                      isFilled: data['advocates']?.isNotEmpty ?? false,
                      style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                    ),
                    SizedBox(height: 11 * (96 / 25.4)),

                    // Advocate designation
                    Text(
                      '(herein after called the advocate/s) to be my / our Advocate in the above – noted case authorize him:-',
                      style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                    ),
                    SizedBox(height: 10 * (96 / 25.4)),

                    // Authorization clauses (IMMUTABLE)
                    ...List.generate(_authorizationClauses.length, (i) {
                      final clause = _authorizationClauses[i];
                      final isJustified = _justifiedClauseIndices.contains(i);
                      final isLeftIndent = _leftIndentClauseIndices.contains(i);
                      final hasRightMargin = i >= 5;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: 10 * (96 / 25.4),
                          left: isLeftIndent ? 40 * (96 / 25.4) : 0,
                          right: hasRightMargin ? 22.4 * (96 / 25.4) : 0,
                        ),
                        child: Text(
                          clause,
                          style: carlitoFont.copyWith(
                            fontSize: 14,
                            height: 1.15,
                          ),
                          textAlign: isJustified ? TextAlign.justify : TextAlign.left,
                        ),
                      );
                    }),

                    // Ratification clause
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 10 * (96 / 25.4),
                        left: 40 * (96 / 25.4),
                        right: 22.4 * (96 / 25.4),
                      ),
                      child: Text(
                        _ratificationClause,
                        style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                        textAlign: TextAlign.justify,
                      ),
                    ),

                    // Appearance clause
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 10 * (96 / 25.4),
                        left: 40 * (96 / 25.4),
                        right: 22.4 * (96 / 25.4),
                      ),
                      child: Text(
                        _appearanceClause,
                        style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                        textAlign: TextAlign.justify,
                      ),
                    ),

                    // Liability clause
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 10 * (96 / 25.4),
                        left: 40 * (96 / 25.4),
                        right: 22.4 * (96 / 25.4),
                      ),
                      child: Text(
                        _liabilityClause,
                        style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                        textAlign: TextAlign.justify,
                      ),
                    ),

                    // Fee clause (full width, below standing rect)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10 * (96 / 25.4)),
                      child: Text(
                        _feeClause,
                        style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                        textAlign: TextAlign.justify,
                      ),
                    ),

                    // Witness clause
                    _buildField(
                      'IN WITNESS WHERE OF I/We do hereunto set my/our hand to these presents '
                      'the contents of which have been understood by me/us on this ${_getValue("signingDay", "____")}${_getDaySuffix(data['signingDay'] ?? '')} '
                      'Day of ${_getValue("signingMonth", "________")} 20${_getValue("signingYear", "____")}',
                      fieldName: 'signingDay',
                      isActive: activeField == 'signingDay' || activeField == 'signingMonth' || activeField == 'signingYear',
                      isFilled: (data['signingDay']?.isNotEmpty ?? false) || (data['signingMonth']?.isNotEmpty ?? false) || (data['signingYear']?.isNotEmpty ?? false),
                      style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                    ),
                    SizedBox(height: 3.5 * (96 / 25.4)),

                    // Accepted subject to...
                    const Text(
                      'Accepted subject to the terms of the fees.',
                      style: TextStyle(fontSize: 14, height: 1.15),
                    ),
                    SizedBox(height: 3.5 * (96 / 25.4)),

                    // Signature labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Advocate', style: carlitoFont.copyWith(fontSize: 14, height: 1.15)),
                        Text('Client', style: carlitoFont.copyWith(fontSize: 14, height: 1.15), textAlign: TextAlign.center),
                        Text('Client', style: carlitoFont.copyWith(fontSize: 14, height: 1.15), textAlign: TextAlign.right),
                      ],
                    ),
                    SizedBox(height: 3.5 * (96 / 25.4)),

                    // I Identify...
                    Padding(
                      padding: EdgeInsets.only(left: 38.1 * (96 / 25.4)),
                      child: Text(
                        'I Identify the Signature/Thumb Impression of Below Mentioned Person,',
                        style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                      ),
                    ),
                    SizedBox(height: 3.5 * (96 / 25.4)),

                    // Signed in My Presence
                    Padding(
                      padding: EdgeInsets.only(left: 101.6 * (96 / 25.4)),
                      child: Text(
                        'Signed in My Presence. The Client.',
                        style: carlitoFont.copyWith(fontSize: 14, height: 1.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(
    String text, {
    required String fieldName,
    required bool isActive,
    required bool isFilled,
    required TextStyle style,
  }) {
    if (isFilled) {
      return Text(
        text,
        style: style.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1e3a5f),
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF1e3a5f).withValues(alpha: 0.25),
          decorationThickness: 1,
        ),
      );
    }

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFFfef3c7),
          border: Border.all(color: const Color(0xFFf59e0b), style: BorderStyle.solid, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          '← ${fieldName.replaceAll('_', ' ')}',
          style: const TextStyle(
            color: Color(0xFF92400e),
            fontSize: 10,
            fontFamily: 'sans-serif',
          ),
        ),
      );
    }

    return Text(
      text,
      style: style.copyWith(color: const Color(0xFF666666)),
    );
  }

  Widget _buildInlineField(
    String text, {
    required String fieldName,
    required bool isActive,
    required bool isFilled,
    required TextStyle style,
    String placeholder = '',
  }) {
    if (isFilled) {
      return Text(
        text,
        style: style.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1e3a5f),
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF1e3a5f).withValues(alpha: 0.25),
        ),
      );
    }

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFFfef3c7),
          border: Border.all(color: const Color(0xFFf59e0b), style: BorderStyle.solid, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          '← ${fieldName.replaceAll('_', ' ')}',
          style: const TextStyle(
            color: Color(0xFF92400e),
            fontSize: 10,
            fontFamily: 'sans-serif',
          ),
        ),
      );
    }

    return Text(
      text.isEmpty ? placeholder : text,
      style: style.copyWith(color: const Color(0xFF666666)),
    );
  }

  String _getValue(String key, String fallback) {
    return data[key]?.trim().isNotEmpty == true ? data[key]! : fallback;
  }

  String _getDaySuffix(String day) {
    final d = int.tryParse(day);
    if (d == null) return '';
    if (d >= 11 && d <= 13) return 'th';
    switch (d % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}
