import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pietra_card.dart';
import '../../../../data/document_registry.dart';

class GenericFormPanel extends ConsumerWidget {
  final DocumentConfig config;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onFieldUpdated;

  const GenericFormPanel({
    super.key,
    required this.config,
    required this.controllers,
    required this.onFieldUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Document Details',
            style: AppTextStyles.chatTitle(color: isDark ? AppColors.darkTextPri : AppColors.ink),
          ),
          const SizedBox(height: 16),
          ...config.fields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _FormField(
                field: field,
                controller: controllers[field.key]!,
                onChanged: (value) {
                  // Update is handled by the controller directly
                  onFieldUpdated();
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final DocumentField field;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _FormField({
    required this.field,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PietraCard(
      accentColor: isDark ? AppColors.darkGoldDim : AppColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field.label,
                style: AppTextStyles.label(
                  color: isDark ? AppColors.darkTextPri : AppColors.ink,
                ),
              ),
              if (field.required ?? false) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(color: Colors.red.shade400, fontSize: 16),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          _buildFieldInput(context, isDark),
        ],
      ),
    );
  }

  Widget _buildFieldInput(BuildContext context, bool isDark) {
    switch (field.type) {
      case FieldType.text:
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
            filled: true,
            fillColor: isDark ? AppColors.darkRaised : AppColors.sandXlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.sandLt,
                width: 0.5,
              ),
            ),
            errorText: _getErrorText(),
          ),
          style: AppTextStyles.body(
            color: isDark ? AppColors.darkTextPri : AppColors.ink,
          ),
          onChanged: onChanged,
        );

      case FieldType.textarea:
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
            filled: true,
            fillColor: isDark ? AppColors.darkRaised : AppColors.sandXlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.sandLt,
                width: 0.5,
              ),
            ),
            errorText: _getErrorText(),
          ),
          style: AppTextStyles.body(
            color: isDark ? AppColors.darkTextPri : AppColors.ink,
          ),
          maxLines: 4,
          onChanged: onChanged,
        );

      case FieldType.select:
        final options = field.options ?? [];
        return DropdownButtonFormField<String>(
          initialValue: options.contains(controller.text) ? controller.text : null,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Select ${field.label.toLowerCase()}',
            filled: true,
            fillColor: isDark ? AppColors.darkRaised : AppColors.sandXlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.sandLt,
                width: 0.5,
              ),
            ),
            errorText: _getErrorText(),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: AppTextStyles.body(
                  color: isDark ? AppColors.darkTextPri : AppColors.ink,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.text = value;
              onChanged(value);
            }
          },
        );

      case FieldType.date:
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'DD/MM/YYYY',
            filled: true,
            fillColor: isDark ? AppColors.darkRaised : AppColors.sandXlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.sandLt,
                width: 0.5,
              ),
            ),
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
            errorText: _getErrorText(),
          ),
          style: AppTextStyles.body(
            color: isDark ? AppColors.darkTextPri : AppColors.ink,
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              controller.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
              onChanged(controller.text);
            }
          },
        );

      case FieldType.number:
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field.placeholder ?? '0',
            filled: true,
            fillColor: isDark ? AppColors.darkRaised : AppColors.sandXlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.sandLt,
                width: 0.5,
              ),
            ),
            errorText: _getErrorText(),
          ),
          style: AppTextStyles.body(
            color: isDark ? AppColors.darkTextPri : AppColors.ink,
          ),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        );
    }
  }

  String? _getErrorText() {
    if ((field.required ?? false) && controller.text.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
