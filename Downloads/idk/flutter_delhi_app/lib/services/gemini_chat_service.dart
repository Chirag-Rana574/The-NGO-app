import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/config/env.dart';

/// Gemini AI Chat Service for legal assistant conversations.
/// Use primary AI first, then Kilo Code, then local canned responses.
class GeminiChatService {
  final String apiKey;
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  final String model = 'gemini-2.0-flash';

  GeminiChatService({required this.apiKey});

  /// Send a message to Gemini and get a response
  Future<String> sendMessage({
    required String message,
    List<Map<String, dynamic>>? history,
    String? systemPrompt,
  }) async {
    final contents = <Map<String, dynamic>>[];

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      contents.add({
        'parts': [{'text': systemPrompt}],
        'role': 'user',
      });
    }

    if (history != null) {
      for (final entry in history) {
        contents.add({
          'parts': [{'text': entry['content'] ?? ''}],
          'role': entry['role'] == 'user' ? 'user' : 'model',
        });
      }
    }

    contents.add({
      'parts': [{'text': message}],
      'role': 'user',
    });

    final response = await http.post(
      Uri.parse('$baseUrl/$model:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        },
        'safetySettings': [
          {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
          {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
          {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
          {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map?;
        final parts = content?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'] as String? ?? 'No response generated.';
        }
      }
      return 'No valid response from AI.';
    } else {
      throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Send a message to Kilo Code (kilo-auto/free) as secondary fallback
  Future<String> sendMessageKilo({
    required String message,
    List<Map<String, dynamic>>? history,
    String? systemPrompt,
  }) async {
    final kilocodeKey = Env.kilocodeApiKey;
    if (kilocodeKey.isEmpty) {
      throw Exception('KILOCODE_API_KEY not configured');
    }

    final messages = <Map<String, String>>[];

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }

    if (history != null) {
      for (final entry in history) {
        messages.add({
          'role': entry['role'] == 'user' ? 'user' : 'assistant',
          'content': entry['content'] ?? '',
        });
      }
    }

    messages.add({'role': 'user', 'content': message});

    final response = await http.post(
      Uri.parse('https://api.kilo.ai/api/gateway/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $kilocodeKey',
      },
      body: jsonEncode({
        'model': 'kilo-auto/free',
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 2048,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'];
      if (content != null && content.isNotEmpty) {
        return content as String;
      }
      throw Exception('No content in Kilo response');
    } else {
      throw Exception('Kilo API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Stream a response from Gemini (for real-time chat)
  Stream<String> sendMessageStream({
    required String message,
    List<Map<String, dynamic>>? history,
    String? systemPrompt,
  }) async* {
    try {
      final contents = <Map<String, dynamic>>[];

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        contents.add({
          'parts': [{'text': systemPrompt}],
          'role': 'user',
        });
      }

      if (history != null) {
        for (final entry in history) {
          contents.add({
            'parts': [{'text': entry['content'] ?? ''}],
            'role': entry['role'] == 'user' ? 'user' : 'model',
          });
        }
      }

      contents.add({
        'parts': [{'text': message}],
        'role': 'user',
      });

      final response = await http.post(
        Uri.parse('$baseUrl/$model:streamGenerateContent?key=$apiKey&alt=sse'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = jsonDecode(line.substring(6));
            final candidates = data['candidates'] as List?;
            if (candidates != null && candidates.isNotEmpty) {
              final content = candidates[0]['content'] as Map?;
              final parts = content?['parts'] as List?;
              if (parts != null && parts.isNotEmpty) {
                yield parts[0]['text'] as String? ?? '';
              }
            }
          }
        }
      } else {
        throw Exception('Gemini API streaming error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chat stream error: $e');
    }
  }
}

/// Provider for GeminiChatService
final geminiChatServiceProvider = Provider<GeminiChatService>((ref) {
  final apiKey = Env.geminiApiKey;
  if (apiKey.isEmpty) {
    throw Exception('Gemini API key not configured. Set GEMINI_API_KEY in .env');
  }
  return GeminiChatService(apiKey: apiKey);
});

/// Chat message model
class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'] as String,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Chat state notifier
class ChatNotifier extends AutoDisposeNotifier<List<ChatMessage>> {
  String _systemPrompt = '''You are a legal assistant for Indian law professionals.
You provide accurate, helpful information about Indian legal procedures, court practices,
and legal documentation. Always remind users to consult a qualified advocate for
specific legal advice. Be concise and professional.''';

  @override
  List<ChatMessage> build() {
    return [];
  }

  /// Set context-aware system prompt based on current route
  void setContext(String route) {
    String routeContext = '';

    if (route.contains('document') || route.contains('vakalatnama')) {
      routeContext = '''
You are a legal document assistant. Help users fill out legal forms and understand document requirements.
Current context: Document Builder - Vakalatnama or other legal forms.
''';
    } else if (route.contains('court') || route.contains('delhi_high') || route.contains('supreme')) {
      routeContext = '''
You are a court information assistant. Provide details about court procedures, timings, and services.
Current context: Court information pages.
''';
    } else if (route.contains('police') || route.contains('station')) {
      routeContext = '''
You are a police administration assistant. Help with police station information and procedures.
Current context: Police station information.
''';
    } else if (route.contains('calendar') || route.contains('holiday')) {
      routeContext = '''
You are a court calendar assistant. Help with court holidays, vacation dates, and working hours.
Current context: Court calendar.
''';
    } else if (route.contains('ocr') || route.contains('case_document')) {
      routeContext = '''
You are an OCR and case document assistant. Help with document scanning and text extraction.
Current context: Case documents OCR.
''';
    }

    _systemPrompt = '''You are a legal assistant for Indian law professionals.
$routeContext
You provide accurate, helpful information about Indian legal procedures, court practices, and legal documentation.
Always remind users to consult a qualified advocate for specific legal advice. Be concise and professional.''';
  }

  Future<void> sendMessage(String userMessage) async {
    // Add user message to state
    final userMsg = ChatMessage(role: 'user', content: userMessage);
    state = [...state, userMsg];

    try {
      final history = state
          .where((m) => m.role == 'user' || m.role == 'assistant')
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final chatService = ref.read(geminiChatServiceProvider);
      final response = await chatService.sendMessage(
        message: userMessage,
        history: history,
        systemPrompt: _systemPrompt,
      );

      final assistantMsg = ChatMessage(role: 'assistant', content: response);
      state = [...state, assistantMsg];
    } catch (e) {
      // Re-throw so the UI can fall back to Kilo / local
      rethrow;
    }
  }

  Future<void> sendMessageKiloFallback(String userMessage) async {
    // User message is already in state from the failed sendMessage call
    try {
      final history = state
          .where((m) => m.role == 'user' || m.role == 'assistant')
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final chatService = ref.read(geminiChatServiceProvider);
      final response = await chatService.sendMessageKilo(
        message: userMessage,
        history: history,
        systemPrompt: _systemPrompt,
      );

      final assistantMsg = ChatMessage(role: 'assistant', content: response);
      state = [...state, assistantMsg];
    } catch (e) {
      rethrow;
    }
  }

  void clearChat() {
    state = [];
  }

  void reset() {
    state = [];
    _systemPrompt = '''You are a legal assistant for Indian law professionals.
You provide accurate, helpful information about Indian legal procedures, court practices,
and legal documentation. Always remind users to consult a qualified advocate for
specific legal advice. Be concise and professional.''';
  }
}

final chatNotifierProvider = AutoDisposeNotifierProvider<ChatNotifier, List<ChatMessage>>(() {
  return ChatNotifier();
});
