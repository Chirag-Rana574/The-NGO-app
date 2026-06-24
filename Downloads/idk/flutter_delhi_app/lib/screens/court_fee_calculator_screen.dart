import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/pietra_card.dart';
import '../shared/widgets/fade_slide.dart';

class CourtFeeCalculatorScreen extends StatefulWidget {
  const CourtFeeCalculatorScreen({super.key});

  @override
  State<CourtFeeCalculatorScreen> createState() => _CourtFeeCalculatorScreenState();
}

class _CourtFeeCalculatorScreenState extends State<CourtFeeCalculatorScreen> {
  final TextEditingController _valueController = TextEditingController();
  String _courtType = 'district';
  int? _calculatedFee;

  void _calculateFee() {
    final value = double.tryParse(_valueController.text);
    if (value == null || value <= 0) {
      setState(() => _calculatedFee = null);
      return;
    }

    double fee = 0;

    if (_courtType == 'district') {
      if (value <= 500) {
        fee = 10;
      } else if (value <= 1000) {
        fee = 15;
      } else if (value <= 5000) {
        fee = 30;
      } else if (value <= 10000) {
        fee = 50;
      } else if (value <= 20000) {
        fee = 75;
      } else if (value <= 50000) {
        fee = 150;
      } else if (value <= 100000) {
        fee = 300;
      } else if (value <= 200000) {
        fee = 500;
      } else if (value <= 500000) {
        fee = 1000;
      } else if (value <= 1000000) {
        fee = 2000;
      } else {
        fee = 2000 + ((value - 1000000) / 100000).floor() * 200;
      }
    } else if (_courtType == 'high') {
      fee = 150.0 > (value * 0.05) ? 150.0 : ((value * 0.05) < 50000 ? (value * 0.05) : 50000);
    } else {
      fee = 500.0 > (value * 0.075) ? 500.0 : ((value * 0.075) < 75000 ? (value * 0.075) : 75000);
    }

    setState(() {
      _calculatedFee = fee.round();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ground,
      appBar: const LalAppBar(title: 'Court Fee Calculator'),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeSlide(
                  child: Text('Calculate court fees for civil cases', style: AppTextStyles.bodySec(color: context.textSec)),
                ),
                const SizedBox(height: 24),
                
                FadeSlide(
                  delay: const Duration(milliseconds: 100),
                  child: PietraCard(
                    accentColor: context.info,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: context.info),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Disclaimer', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold, color: context.info)),
                              const SizedBox(height: 4),
                              Text(
                                'This is a simplified calculator. Actual court fees may vary based on specific case types, amendments, and court rules. Please verify with official court fee schedules.',
                                style: AppTextStyles.bodySmall(color: context.info),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                FadeSlide(
                  delay: const Duration(milliseconds: 200),
                  child: Text('Court Type', style: AppTextStyles.bodySmall(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                FadeSlide(
                  delay: const Duration(milliseconds: 250),
                  child: Row(
                    children: [
                      _buildCourtButton('District Court', 'district'),
                      const SizedBox(width: 8),
                      _buildCourtButton('High Court', 'high'),
                      const SizedBox(width: 8),
                      _buildCourtButton('Supreme Court', 'supreme'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                FadeSlide(
                  delay: const Duration(milliseconds: 300),
                  child: Text('Case Value (₹)', style: AppTextStyles.bodySmall(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                FadeSlide(
                  delay: const Duration(milliseconds: 350),
                  child: TextField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter case value in rupees',
                      filled: true,
                      fillColor: context.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.border),
                      ),
                    ),
                    style: AppTextStyles.body(color: context.textPri),
                  ),
                ),
                
                const SizedBox(height: 24),
                FadeSlide(
                  delay: const Duration(milliseconds: 400),
                  child: ElevatedButton(
                    onPressed: _calculateFee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: context.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Calculate Fee', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),

                if (_calculatedFee != null) ...[
                  const SizedBox(height: 24),
                  FadeSlide(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: context.raised,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.border),
                      ),
                      child: Column(
                        children: [
                          Text('Estimated Court Fee', style: AppTextStyles.bodySmall(color: context.textSec)),
                          const SizedBox(height: 8),
                          Text(
                            NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(_calculatedFee),
                            style: AppTextStyles.screenTitle(color: context.textPri).copyWith(fontSize: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 48),
                FadeSlide(
                  delay: const Duration(milliseconds: 500),
                  child: Text('Fee Structure Guidelines', style: AppTextStyles.screenTitle(color: context.textPri).copyWith(fontSize: 20)),
                ),
                const SizedBox(height: 16),
                FadeSlide(
                  delay: const Duration(milliseconds: 550),
                  child: _buildInfoCard('District Courts (Delhi)', 'Based on Delhi Court Fees Act, Schedule I:\n\n• Up to ₹500: ₹10\n• ₹501 - ₹1,000: ₹15\n• ₹1,001 - ₹3,000: ₹30\n• ₹3,001 - ₹5,000: ₹50\n• ₹5,001 - ₹10,000: ₹75\n• ₹10,001 - ₹20,000: ₹150\n• Above ₹30 lakhs: ₹10,000 + ₹500 per additional lakh'),
                ),
                const SizedBox(height: 12),
                FadeSlide(
                  delay: const Duration(milliseconds: 600),
                  child: _buildInfoCard('High Courts', 'Fees vary by state. Typically range from ₹500 to ₹15,000 based on case value and type.'),
                ),
                const SizedBox(height: 12),
                FadeSlide(
                  delay: const Duration(milliseconds: 650),
                  child: _buildInfoCard('Supreme Court', 'Fees range from ₹1,000 to ₹20,000+ depending on case value and nature of proceedings.'),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtButton(String label, String value) {
    final isSelected = _courtType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _courtType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? context.primary : context.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? context.primary : context.border, width: 2),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodySmall(color: context.textSec).copyWith(
                color: isSelected ? context.surface : context.textPri,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.raised,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.bodySmall(color: context.textSec)),
        ],
      ),
    );
  }
}
