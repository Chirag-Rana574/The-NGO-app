import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../services/gemini_chat_service.dart';
import '../../../../data/document_registry.dart';

class GenericChatbotPanel extends ConsumerStatefulWidget {
  final DocumentConfig config;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onFieldUpdated;

  const GenericChatbotPanel({
    super.key,
    required this.config,
    required this.controllers,
    required this.onFieldUpdated,
  });

  @override
  ConsumerState<GenericChatbotPanel> createState() => _GenericChatbotPanelState();
}

class _GenericChatbotPanelState extends ConsumerState<GenericChatbotPanel> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentFieldIndex = 0;
  bool _isTyping = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startInterview();
  }

  void _startInterview() {
    if (widget.config.fields.isEmpty) {
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': 'There are no fields configured for this document template.',
        });
      });
      return;
    }

    final firstField = widget.config.fields[0];
    setState(() {
      _messages.add({
        'sender': 'ai',
        'text': _buildWelcomeMessage(firstField),
      });
    });
  }

  String _buildWelcomeMessage(DocumentField firstField) {
    final title = widget.config.title;
    return "Welcome! I'll help you fill out the *$title* form step by step.\n\n"
        "Let's start with the first field:\n\n"
        "**${firstField.label}**${firstField.required ?? false ? ' (required)' : ''}\n\n"
        "${firstField.placeholder ?? 'Please enter the value'}";
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isTyping) return;

    _inputController.clear();
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isTyping = true;
      _error = null;
    });

    // Save to controller
    final currentField = widget.config.fields[_currentFieldIndex];
    widget.controllers[currentField.key]?.text = text;
    widget.onFieldUpdated();

    // Scroll to end
    _scrollToEnd();

    // Generate AI response
    await _generateAiResponse(text);

    // Move to next field
    if (mounted && _error == null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          if (_currentFieldIndex < widget.config.fields.length - 1) {
            _currentFieldIndex++;
            final nextField = widget.config.fields[_currentFieldIndex];
            _messages.add({
              'sender': 'ai',
              'text': _buildNextFieldMessage(nextField),
            });
          } else {
            _currentFieldIndex = widget.config.fields.length;
            _messages.add({
              'sender': 'ai',
              'text': _buildCompletionMessage(),
            });
          }
        });
        _scrollToEnd();
      });
    }
  }

  String _buildNextFieldMessage(DocumentField field) {
    return "Great! Now, what is the **${field.label}**?${field.required ?? false ? ' (required)' : ''}\n\n${field.placeholder ?? 'Please enter the value'}";
  }

  String _buildCompletionMessage() {
    final filledCount = widget.controllers.values.where((c) => c.text.isNotEmpty).length;
    final totalCount = widget.config.fields.length;
    return "Excellent! You've completed the guided interview.\n\n"
        "Progress: $filledCount/$totalCount fields filled\n\n"
        "You can:\n"
        "- Switch to the Form tab to review and edit\n"
        "- Switch to the Preview tab to see the generated document\n"
        "- Use the action buttons to download or print";
  }

  Future<void> _generateAiResponse(String userInput) async {
    try {
      final chatService = ref.read(geminiChatServiceProvider);
      
      final currentField = widget.config.fields[_currentFieldIndex];
      final systemPrompt = '''You are a helpful legal document assistant helping a user fill out a ${widget.config.title} form.
      
Current field being filled: ${currentField.label}
Field type: ${currentField.type.name}
${currentField.placeholder != null ? 'Hint: ${currentField.placeholder}' : ''}

The user just entered: "$userInput"

Respond briefly (1-2 sentences) acknowledging their input. If the input seems incomplete or unclear for this field, politely ask for clarification. Otherwise, just confirm and move on. Do not ask about other fields - that will be handled separately. Keep responses concise and professional.''';

      final history = _messages
          .where((m) => m['sender'] == 'user' || m['sender'] == 'ai')
          .map((m) => {
                'role': m['sender'] == 'user' ? 'user' : 'assistant',
                'content': m['text'] ?? '',
              })
          .toList();

      final response = await chatService.sendMessage(
        message: userInput,
        history: history,
        systemPrompt: systemPrompt,
      );

      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': response});
          _isTyping = false;
        });
        _scrollToEnd();
      }
    } catch (e) {
      // Fallback to canned response
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'ai',
            'text': "Got it! I've saved that information. Let's continue.",
          });
          _isTyping = false;
          _error = null;
        });
        _scrollToEnd();
      }
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

  void _goBack() {
    if (_currentFieldIndex > 0) {
      setState(() {
        _currentFieldIndex--;
        final prevField = widget.config.fields[_currentFieldIndex];
        _messages.add({
          'sender': 'ai',
          'text': "Let's re-enter: **${prevField.label}**",
        });
      });
      _scrollToEnd();
    }
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
    final isComplete = _currentFieldIndex >= widget.config.fields.length;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isDark ? AppColors.darkSurface : AppColors.lal,
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline, size: 16, color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isComplete ? 'Interview Complete' : 'Field ${_currentFieldIndex + 1} of ${widget.config.fields.length}',
                  style: AppTextStyles.label(
                    color: isDark ? AppColors.darkSandGlow : AppColors.sandXlt,
                  ),
                ),
              ),
              if (_currentFieldIndex > 0)
                TextButton(
                  onPressed: _goBack,
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? AppColors.darkSandGlow : AppColors.sandXlt,
                  ),
                  child: const Text('Back', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),

        // Chat area
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isTyping) {
                return _buildTypingIndicator();
              }
              final msg = _messages[index];
              final isAi = msg['sender'] == 'ai';
              return _ChatBubble(
                message: msg['text'] ?? '',
                isAi: isAi,
                isDark: isDark,
              );
            },
          ),
        ),

        // Input area
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.sandLt,
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
                    fillColor: isDark ? AppColors.darkRaised : AppColors.sandXlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.sandLt,
                        width: 0.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  style: AppTextStyles.body(
                    color: isDark ? AppColors.darkTextPri : AppColors.ink,
                  ),
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
                    : Icon(Icons.send, color: isDark ? AppColors.darkGoldDim : AppColors.gold),
                onPressed: (!isComplete && !_isTyping) ? _handleSend : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
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
  final bool isAi;
  final bool isDark;

  const _ChatBubble({
    required this.message,
    required this.isAi,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Parse markdown-like formatting
    final parsedText = _parseMarkdown(message);

    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isAi
              ? (isDark ? AppColors.darkRaised : Colors.grey.shade100)
              : (isDark ? AppColors.darkGoldDim : AppColors.gold),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isAi ? Radius.zero : const Radius.circular(16),
            bottomRight: isAi ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Text(
          parsedText,
          style: TextStyle(
            color: isAi
                ? (isDark ? AppColors.darkTextPri : AppColors.ink)
                : (isDark ? AppColors.darkSurface : Colors.white),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  String _parseMarkdown(String text) {
    // Simple markdown parsing: **bold** and *italic*
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
    return result;
  }
}
