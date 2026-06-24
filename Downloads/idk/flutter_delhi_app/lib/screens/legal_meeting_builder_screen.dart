import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';

class LegalMeetingBuilderScreen extends StatefulWidget {
  const LegalMeetingBuilderScreen({super.key});

  @override
  State<LegalMeetingBuilderScreen> createState() => _LegalMeetingBuilderScreenState();
}

class _LegalMeetingBuilderScreenState extends State<LegalMeetingBuilderScreen> {
  bool _advancedOptions = false;
  String _selectedJail = 'Tihar Jail Complex';
  final jails = ['Tihar Jail Complex', 'Rohini Jail', 'Mandoli Jail'];

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
                Text('Legal Meeting (Mulakat)', style: AppTextStyles.screenTitle(color: context.textPri)),
                Row(
                  children: [
                    Text('45% Complete', style: AppTextStyles.label(color: context.accent)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(
                        value: 0.45,
                        backgroundColor: context.raised,
                        valueColor: AlwaysStoppedAnimation<Color>(context.accent),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
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
                  Text('Inmate Details', style: AppTextStyles.chatTitle(color: context.textPri)),
                  const SizedBox(height: 16),
                  
                  Text('Prison/Jail Name', style: AppTextStyles.label(color: context.textSec)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: context.raised,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedJail,
                        isExpanded: true,
                        dropdownColor: context.surface,
                        style: AppTextStyles.body(color: context.textPri),
                        onChanged: (String? val) {
                          if (val != null) setState(() => _selectedJail = val);
                        },
                        items: jails.map((String jail) {
                          return DropdownMenuItem(value: jail, child: Text(jail));
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Prisoner Name', style: AppTextStyles.label(color: context.textSec)),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter inmate name',
                      filled: true,
                      fillColor: context.raised,
                    ),
                    style: AppTextStyles.body(color: context.textPri),
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Prisoner Number / UT No.', style: AppTextStyles.label(color: context.textSec)),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'e.g. UT/1234/2024',
                      filled: true,
                      fillColor: context.raised,
                    ),
                    style: AppTextStyles.body(color: context.textPri),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            PietraCard(
              accentColor: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Visitor Details', style: AppTextStyles.chatTitle(color: context.textPri)),
                  const SizedBox(height: 16),
                  
                  Text('Name of Visitor / Advocate', style: AppTextStyles.label(color: context.textSec)),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter visitor name',
                      filled: true,
                      fillColor: context.raised,
                    ),
                    style: AppTextStyles.body(color: context.textPri),
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Purpose of Meeting', style: AppTextStyles.label(color: context.textSec)),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'e.g. Legal Interview / Case Discussion',
                      filled: true,
                      fillColor: context.raised,
                    ),
                    style: AppTextStyles.body(color: context.textPri),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            InkWell(
              onTap: () => setState(() => _advancedOptions = !_advancedOptions),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(_advancedOptions ? Icons.expand_less : Icons.expand_more, color: context.primary),
                    const SizedBox(width: 8),
                    Text('Advanced Options', style: AppTextStyles.bodySmall(color: context.primary)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
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
