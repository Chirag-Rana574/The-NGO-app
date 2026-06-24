import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'document_builder_shell.dart';

class DocumentBuilderScreen extends ConsumerWidget {
  final String formId;
  const DocumentBuilderScreen({super.key, required this.formId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DocumentBuilderShell(formId: formId);
  }
}
