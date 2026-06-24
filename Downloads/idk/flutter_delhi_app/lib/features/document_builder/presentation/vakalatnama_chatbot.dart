import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/vakalatnama_provider.dart';

/// Chat message model
class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
  });
}

/// Chat state enum
enum ChatState {
  start,
  courtName,
  caseType,
  caseNumber,
  jurisdictionYear,
  plaintiffs,
  plaintiffsMore,
  defendants,
  defendantsMore,
  advocates,
  advocatesMore,
  signingDay,
  signingMonth,
  signingYear,
  consent,
  review,
  complete,
}

/// Vakalatnama Chatbot — Finite-State Conversational Engine
///
/// States: START → COURT_DETAILS → PLAINTIFFS → DEFENDANTS → ADVOCATES → EXECUTION_DATE → CONSENT → REVIEW → COMPLETE
class VakalatnamaChatEngine {
  ChatState _state = ChatState.start;
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  ChatState get state => _state;

  VakalatnamaChatEngine() {
    _messages.add(ChatMessage(
      id: _generateId(),
      isUser: false,
      text: "Namaste! 🙏 I'll help you prepare your Vakalatnama. This is a legal document authorizing an advocate to represent you in court.\n\n"
          "Let's begin. What is the **name of the court** where this case will be filed?",
      timestamp: DateTime.now(),
    ));
    _state = ChatState.courtName;
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + (DateTime.now().microsecond % 1000).toString();
  }

  ({List<ChatMessage> newMessages, Map<String, dynamic> dataUpdates}) processInput(
    String input,
    VakalatnamaData currentData,
  ) {
    final userMsg = ChatMessage(
      id: _generateId(),
      isUser: true,
      text: input,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);

    final newMessages = <ChatMessage>[userMsg];
    Map<String, dynamic> dataUpdates = {};

    // Validate and process based on current state
    String? error;
    switch (_state) {
      case ChatState.courtName:
        if (input.trim().isEmpty) {
          error = 'Please enter a valid court name.';
        } else {
          dataUpdates = {'courtName': input.trim()};
        }
        break;

      case ChatState.caseType:
        final v = input.trim().toLowerCase();
        if (v != 'suit' && v != 'appeal') {
          error = 'Please enter either "Suit" or "Appeal".';
        } else {
          dataUpdates = {'caseType': v.substring(0, 1).toUpperCase() + v.substring(1)};
        }
        break;

      case ChatState.caseNumber:
        final trimmed = input.trim().toLowerCase();
        dataUpdates = {'caseNumber': trimmed == 'none' ? '' : input.trim()};
        break;

      case ChatState.jurisdictionYear:
        final y = int.tryParse(input.trim());
        if (y == null || y < 2000 || y > 2100) {
          error = 'Please enter a valid year (e.g., 2025).';
        } else {
          dataUpdates = {'jurisdictionYear': input.trim()};
        }
        break;

      case ChatState.plaintiffs:
        if (input.trim().isEmpty) {
          error = 'Please enter a valid name.';
        } else {
          dataUpdates = {'plaintiffs': [input.trim()]};
        }
        break;

      case ChatState.plaintiffsMore:
        if (input.trim().toLowerCase() == 'done') {
          // Keep existing plaintiffs
        } else if (input.trim().isNotEmpty) {
          final newPlaintiffs = List<String>.from(currentData.plaintiffs)..add(input.trim());
          dataUpdates = {'plaintiffs': newPlaintiffs};
        }
        break;

      case ChatState.defendants:
        if (input.trim().isEmpty) {
          error = 'Please enter a valid name.';
        } else {
          dataUpdates = {'defendants': [input.trim()]};
        }
        break;

      case ChatState.defendantsMore:
        if (input.trim().toLowerCase() == 'done') {
          // Keep existing defendants
        } else if (input.trim().isNotEmpty) {
          final newDefendants = List<String>.from(currentData.defendants)..add(input.trim());
          dataUpdates = {'defendants': newDefendants};
        }
        break;

      case ChatState.advocates:
        if (input.trim().isEmpty) {
          error = 'Please enter a valid advocate name.';
        } else {
          dataUpdates = {'advocates': [input.trim()]};
        }
        break;

      case ChatState.advocatesMore:
        if (input.trim().toLowerCase() == 'done') {
          // Keep existing advocates
        } else if (input.trim().isNotEmpty) {
          final newAdvocates = List<String>.from(currentData.advocates)..add(input.trim());
          dataUpdates = {'advocates': newAdvocates};
        }
        break;

      case ChatState.signingDay:
        final d = int.tryParse(input.trim());
        if (d == null || d < 1 || d > 31) {
          error = 'Please enter a valid day (1-31).';
        } else {
          dataUpdates = {'signingDay': input.trim()};
        }
        break;

      case ChatState.signingMonth:
        final v = input.trim();
        final num = int.tryParse(v);
        if (num != null && num >= 1 && num <= 12) {
          dataUpdates = {'signingMonth': months[num - 1]};
        } else if (months.any((m) => m.toLowerCase() == v.toLowerCase())) {
          final match = months.firstWhere((m) => m.toLowerCase() == v.toLowerCase());
          dataUpdates = {'signingMonth': match};
        } else {
          error = 'Please enter a valid month name or number (1-12).';
        }
        break;

      case ChatState.signingYear:
        final y = int.tryParse(input.trim());
        if (y == null || y < 2000 || y > 2100) {
          error = 'Please enter a valid year.';
        } else {
          dataUpdates = {'signingYear': input.trim()};
        }
        break;

      case ChatState.consent:
        final v = input.trim().toLowerCase();
        if (v != 'yes' && v != 'confirm' && v != 'no' && v != 'reject') {
          error = 'Please reply with "Yes" or "No".';
        } else {
          dataUpdates = {'consentConfirmed': v == 'yes' || v == 'confirm'};
        }
        break;

      case ChatState.review:
        // Any input moves to complete
        break;

      case ChatState.complete:
        // Already complete
        break;

      case ChatState.start:
        // Should not reach here
        break;
    }

    if (error != null) {
      final errorMsg = ChatMessage(
        id: _generateId(),
        isUser: false,
        text: "⚠️ $error",
        timestamp: DateTime.now(),
      );
      _messages.add(errorMsg);
      newMessages.add(errorMsg);
      return (newMessages: newMessages, dataUpdates: {});
    }

    // Apply data updates
    final updatedData = _applyUpdates(currentData, dataUpdates);

    // Advance state
    _advanceState(input, updatedData);

    // Get next prompt
    String? nextPrompt = _getNextPrompt(updatedData);
    if (nextPrompt != null) {
      final botMsg = ChatMessage(
        id: _generateId(),
        isUser: false,
        text: nextPrompt,
        timestamp: DateTime.now(),
      );
      _messages.add(botMsg);
      newMessages.add(botMsg);
    }

    return (newMessages: newMessages, dataUpdates: dataUpdates);
  }

  VakalatnamaData _applyUpdates(VakalatnamaData data, Map<String, dynamic> updates) {
    var result = data;
    for (final entry in updates.entries) {
      switch (entry.key) {
        case 'courtName':
          result = result.copyWith(courtName: entry.value as String);
        case 'caseType':
          result = result.copyWith(caseType: entry.value as String);
        case 'caseNumber':
          result = result.copyWith(caseNumber: entry.value as String);
        case 'jurisdictionYear':
          result = result.copyWith(jurisdictionYear: entry.value as String);
        case 'plaintiffs':
          result = result.copyWith(plaintiffs: List<String>.from(entry.value));
        case 'defendants':
          result = result.copyWith(defendants: List<String>.from(entry.value));
        case 'advocates':
          result = result.copyWith(advocates: List<String>.from(entry.value));
        case 'signingDay':
          result = result.copyWith(signingDay: entry.value as String);
        case 'signingMonth':
          result = result.copyWith(signingMonth: entry.value as String);
        case 'signingYear':
          result = result.copyWith(signingYear: entry.value as String);
        case 'consentConfirmed':
          result = result.copyWith(consentConfirmed: entry.value as bool);
      }
    }
    return result;
  }

  void _advanceState(String input, VakalatnamaData data) {
    switch (_state) {
      case ChatState.start:
        _state = ChatState.courtName;
        break;
      case ChatState.courtName:
        _state = ChatState.caseType;
        break;
      case ChatState.caseType:
        _state = ChatState.caseNumber;
        break;
      case ChatState.caseNumber:
        _state = ChatState.jurisdictionYear;
        break;
      case ChatState.jurisdictionYear:
        _state = ChatState.plaintiffs;
        break;
      case ChatState.plaintiffs:
        _state = ChatState.plaintiffsMore;
        break;
      case ChatState.plaintiffsMore:
        if (input.trim().toLowerCase() == 'done') {
          _state = ChatState.defendants;
        } else {
          _state = ChatState.plaintiffsMore;
        }
        break;
      case ChatState.defendants:
        _state = ChatState.defendantsMore;
        break;
      case ChatState.defendantsMore:
        if (input.trim().toLowerCase() == 'done') {
          _state = ChatState.advocates;
        } else {
          _state = ChatState.defendantsMore;
        }
        break;
      case ChatState.advocates:
        _state = ChatState.advocatesMore;
        break;
      case ChatState.advocatesMore:
        if (input.trim().toLowerCase() == 'done') {
          _state = ChatState.signingDay;
        } else {
          _state = ChatState.advocatesMore;
        }
        break;
      case ChatState.signingDay:
        _state = ChatState.signingMonth;
        break;
      case ChatState.signingMonth:
        _state = ChatState.signingYear;
        break;
      case ChatState.signingYear:
        _state = ChatState.consent;
        break;
      case ChatState.consent:
        final v = input.trim().toLowerCase();
        if (v == 'yes' || v == 'confirm') {
          _state = ChatState.review;
        } else {
          _state = ChatState.review; // Go to review so user can edit instead of losing all data
        }
        break;
      case ChatState.review:
        _state = ChatState.complete;
        break;
      case ChatState.complete:
        _state = ChatState.complete;
        break;
    }
  }

  String? _getNextPrompt(VakalatnamaData data) {
    switch (_state) {
      case ChatState.start:
        return null; // Already handled in constructor
      case ChatState.courtName:
        return null; // Already prompted
      case ChatState.caseType:
        return 'What type of case is this? Please enter **Suit** or **Appeal**.';
      case ChatState.caseNumber:
        return 'What is the **case/suit/appeal number**? (You can type "none" if not yet assigned)';
      case ChatState.jurisdictionYear:
        return 'What is the **jurisdiction year**? (e.g., 2025, 2026)';
      case ChatState.plaintiffs:
        return 'Now, please enter the **name of the first plaintiff/petitioner/appellant/complainant**.';
      case ChatState.plaintiffsMore:
        return 'Would you like to add **another plaintiff**? Enter a name, or type **"done"** to proceed.';
      case ChatState.defendants:
        return 'Please enter the **name of the first defendant/respondent/accused**.';
      case ChatState.defendantsMore:
        return 'Would you like to add **another defendant**? Enter a name, or type **"done"** to proceed.';
      case ChatState.advocates:
        return "Now, please enter the **name of the Advocate** being appointed.";
      case ChatState.advocatesMore:
        return 'Would you like to add **another advocate**? Enter a name, or type **"done"** to proceed.';
      case ChatState.signingDay:
        return "Let's set the **execution date**. What **day** of the month? (1-31)";
      case ChatState.signingMonth:
        return 'What **month**? (Enter name or number, e.g., "January" or "1")';
      case ChatState.signingYear:
        return 'And the **year**? (e.g., 2025)';
      case ChatState.consent:
        final advNames = data.advocates.where((a) => a.trim().isNotEmpty).join(', ');
        return "📋 **Confirmation Required**\n\n"
            "You are appointing **$advNames** with authority to:\n"
            "• Act, appear, and plead on your behalf\n"
            "• Sign, file, and verify pleadings and petitions\n"
            "• Compromise, withdraw, or submit to arbitration\n"
            "• Deposit, draw, and receive money\n"
            "• Appoint substitute advocates\n\n"
            "Do you **confirm** this authorization? (Yes/No)";
      case ChatState.review:
        final plaintiffList = data.plaintiffs.where((p) => p.trim().isNotEmpty).toList();
        final defendantList = data.defendants.where((d) => d.trim().isNotEmpty).toList();
        final advocateList = data.advocates.where((a) => a.trim().isNotEmpty).toList();
        final plaintiffs = plaintiffList.isEmpty ? '(none)' : plaintiffList.join(', ');
        final defendants = defendantList.isEmpty ? '(none)' : defendantList.join(', ');
        final advocates = advocateList.isEmpty ? '(none)' : advocateList.join(', ');
        return "📄 **Vakalatnama Summary**\n\n"
            "**Court:** ${data.courtName.isEmpty ? '(not set)' : data.courtName}\n"
            "**Case:** ${data.caseType} No. ${data.caseNumber.isEmpty ? '(not assigned)' : data.caseNumber} of ${data.jurisdictionYear.isEmpty ? '____' : data.jurisdictionYear}\n\n"
            "**Plaintiffs:** $plaintiffs\n"
            "**Defendants:** $defendants\n"
            "**Advocates:** $advocates\n\n"
            "**Execution Date:** ${data.signingDay.isEmpty ? '__' : data.signingDay}${_getDaySuffix(data.signingDay)} ${data.signingMonth.isEmpty ? '________' : data.signingMonth}, ${data.signingYear.isEmpty ? '____' : data.signingYear}\n\n"
            "**Consent:** ${data.consentConfirmed ? '✅ Confirmed' : '❌ Not confirmed'}\n\n"
            "Your document is being generated. Type anything to finalize.";
      case ChatState.complete:
        return "✅ Your Vakalatnama has been prepared! You can now:\n\n"
            "• Review the document in the **Preview panel**\n"
            "• Make edits using the **Form tab**\n"
            "• **Print or export** the document\n\n"
            "The document is ready for signing.";
    }
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

  bool get isComplete => _state == ChatState.complete;

  void reset() {
    _state = ChatState.start;
    _messages.clear();
    _messages.add(ChatMessage(
      id: _generateId(),
      isUser: false,
      text: "Namaste! 🙏 I'll help you prepare your Vakalatnama. This is a legal document authorizing an advocate to represent you in court.\n\n"
          "Let's begin. What is the **name of the court** where this case will be filed?",
      timestamp: DateTime.now(),
    ));
    _state = ChatState.courtName;
  }
}

/// Vakalatnama Chatbot Panel Widget
class VakalatnamaChatbotPanel extends ConsumerStatefulWidget {
  final VakalatnamaData initialData;
  final Function(Map<String, dynamic>) onDataUpdated;
  final VoidCallback onComplete;

  const VakalatnamaChatbotPanel({
    super.key,
    required this.initialData,
    required this.onDataUpdated,
    required this.onComplete,
  });

  @override
  ConsumerState<VakalatnamaChatbotPanel> createState() => _VakalatnamaChatbotPanelState();
}

class _VakalatnamaChatbotPanelState extends ConsumerState<VakalatnamaChatbotPanel> {
  late VakalatnamaChatEngine _engine;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _engine = VakalatnamaChatEngine();
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isTyping) return;

    _inputController.clear();
    setState(() => _isTyping = true);

    // Simulate typing delay
    await Future.delayed(Duration(milliseconds: 400 + (DateTime.now().millisecond % 400)));

    final result = _engine.processInput(text, widget.initialData);

    // Update state with data changes
    if (result.dataUpdates.isNotEmpty) {
      ref.read(vakalatnamaProvider.notifier).bulkUpdate(result.dataUpdates);
      widget.onDataUpdated(result.dataUpdates);
    }

    if (_engine.isComplete) {
      widget.onComplete();
    }

    if (mounted) {
      setState(() => _isTyping = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleReset() {
    _engine.reset();
    ref.read(vakalatnamaProvider.notifier).reset();
    _inputController.clear();
    setState(() {});
    _scrollToEnd();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComplete = _engine.isComplete;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFF8B0000),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline, size: 16, color: isDark ? const Color(0xFFd4af37) : const Color(0xFFf5e6c8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isComplete ? 'Interview Complete' : 'Step-by-step guidance',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFd4af37) : const Color(0xFFf5e6c8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: _handleReset,
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? const Color(0xFFd4af37) : const Color(0xFFf5e6c8),
                ),
                child: const Text('Start Over', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        // Chat area
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _engine.messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _engine.messages.length && _isTyping) {
                return _buildTypingIndicator(isDark);
              }
              final msg = _engine.messages[index];
              return _ChatBubble(
                message: msg.text,
                isUser: msg.isUser,
                isDark: isDark,
              );
            },
          ),
        ),

        // Input area
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF333355) : const Color(0xFFe0d5c1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  enabled: !isComplete && !_isTyping,
                  decoration: InputDecoration(
                    hintText: isComplete ? 'Interview completed' : 'Type your answer...',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF252540) : const Color(0xFFf5e6c8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF333355) : const Color(0xFFe0d5c1),
                        width: 0.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  style: TextStyle(color: isDark ? const Color(0xFFe0e0e0) : const Color(0xFF1a1a2e)),
                  onSubmitted: (_) => !isComplete && !_isTyping ? _handleSend() : null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isTyping
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.send, color: isDark ? const Color(0xFFd4af37) : const Color(0xFF8B0000)),
                onPressed: (!isComplete && !_isTyping) ? _handleSend : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252540) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: Radius.zero),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Thinking...', style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isDark;

  const _ChatBubble({
    required this.message,
    required this.isUser,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final parsedText = _parseMarkdown(message);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? (isDark ? const Color(0xFFd4af37) : const Color(0xFF8B0000))
              : (isDark ? const Color(0xFF252540) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Text(
          parsedText,
          style: TextStyle(
            color: isUser
                ? (isDark ? const Color(0xFF1a1a2e) : Colors.white)
                : (isDark ? const Color(0xFFe0e0e0) : const Color(0xFF1a1a2e)),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  String _parseMarkdown(String text) {
    var result = text;
    // Bold: **text**
    result = result.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*'),
      (match) => match.group(1) ?? match.group(0)!,
    );
    // Italic: *text* (but not inside bold)
    result = result.replaceAllMapped(
      RegExp(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)'),
      (match) => match.group(1) ?? match.group(0)!,
    );
    // Bullet points
    result = result.replaceAll(RegExp(r'^• ', multiLine: true), '• ');
    return result;
  }
}
