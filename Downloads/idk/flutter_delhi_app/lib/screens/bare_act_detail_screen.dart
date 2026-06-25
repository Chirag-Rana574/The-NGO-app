import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/lal_app_bar.dart';
import '../shared/widgets/fade_slide.dart';
import '../data/models/bare_act.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:io';

class BareActDetailScreen extends StatefulWidget {
  final Object? act;

  const BareActDetailScreen({super.key, this.act});

  @override
  State<BareActDetailScreen> createState() => _BareActDetailScreenState();
}

class _BareActDetailScreenState extends State<BareActDetailScreen> {
  bool _isLoading = false;
  String? _fullText;
  bool _hasError = false;
  BareAct? _act;

  @override
  void initState() {
    super.initState();
    _act = widget.act is BareAct ? widget.act as BareAct : null;
    _fullText = _act?.fullText;
    if (_fullText == null || _fullText!.isEmpty) {
      _fetchText();
    }
  }

  Future<void> _fetchText() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    if (_act != null) {
      try {
        final response = await Supabase.instance.client
            .from('bare_acts')
            .select('full_text')
            .eq('id', _act!.id)
            .maybeSingle();
        if (response != null && response['full_text'] != null) {
          final text = response['full_text'] as String;
          if (text.isNotEmpty) {
            setState(() {
              _fullText = text;
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint('BareActDetailScreen: Supabase fetch error: $e');
      }
    }

    final url = _act?.fullTextUrl;
    if (url == null || url.isEmpty) {
      setState(() {
        _fullText = 'Full text unavailable for this act.';
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    if (kIsWeb) {
      setState(() {
        _fullText = 'Full text not found in database. Tap below to view official source.';
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        throw const FormatException('URL scheme must be http or https');
      }

      final client = HttpClient();
      try {
        final request = await client.getUrl(uri);
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        final text = body.replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
        setState(() {
          _fullText = text.isEmpty ? 'Text content not available.' : text;
          _isLoading = false;
        });
      } finally {
        client.close();
      }
    } catch (e) {
      setState(() {
        _fullText = 'Unable to load text. Tap below to open original.';
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _openExternal() async {
    final url = _act?.fullTextUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_act == null) {
      return Scaffold(
        backgroundColor: context.ground,
        appBar: const LalAppBar(title: 'Bare Act'),
        body: Center(
          child: Text('Act not found', style: AppTextStyles.body(color: context.textPri)),
        ),
      );
    }
    final content = _fullText ?? 'Content unavailable.';
    return Scaffold(
      backgroundColor: context.ground,
      appBar: LalAppBar(title: _act!.name),
      body: _isLoading
          ? const Center(child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FadeSlide(
                delay: const Duration(milliseconds: 0),
                child: SelectableText(
                  content,
                  style: AppTextStyles.body(color: context.textPri),
                ),
              ),
            ),
      bottomNavigationBar: _hasError && _act!.fullTextUrl != null && _act!.fullTextUrl!.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  onPressed: _openExternal,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open original source'),
                ),
              ),
            )
          : null,
    );
  }
}
