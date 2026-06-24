import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/context_colors.dart';
import '../services/gemini_chat_service.dart';

/// Chat message model for the AI chat view
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

/// State notifier for AI chat
class AiChatState extends StateNotifier<List<ChatMessage>> {
  AiChatState() : super([
    ChatMessage(
      text: "👋 Hello! I'm your Legal Assistant AI.\n\nI can help you find information about courts, police stations, legal procedures, new criminal laws, and more.\n\nWhat would you like to know?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ]);

  void addMessage(String text, bool isUser) {
    state = [...state, ChatMessage(text: text, isUser: isUser, timestamp: DateTime.now())];
  }

  void reset() {
    state = [
      ChatMessage(
        text: "👋 Hello! I'm your Legal Assistant AI.\n\nI can help you find information about courts, police stations, legal procedures, new criminal laws, and more.\n\nWhat would you like to know?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

final aiChatProvider = StateNotifierProvider<AiChatState, List<ChatMessage>>((ref) => AiChatState());

/// AI Chat View widget - reusable chat interface
class AiChatView extends ConsumerStatefulWidget {
  final bool isMini;
  final VoidCallback? onExpand;
  final VoidCallback? onClose;
  final String? contextRoute;

  const AiChatView({
    super.key,
    this.isMini = false,
    this.onExpand,
    this.onClose,
    this.contextRoute,
  });

  @override
  ConsumerState<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends ConsumerState<AiChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  void _scrollToBottom() {
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

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    _controller.clear();
    ref.read(aiChatProvider.notifier).addMessage(text, true);
    setState(() => _isTyping = true);
    _scrollToBottom();

    try {
      final history = ref.read(aiChatProvider)
          .where((m) => m.text != ref.read(aiChatProvider).first.text)
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();

      final chatService = ref.read(geminiChatServiceProvider);
      final response = await chatService.sendMessage(
        message: text,
        history: history,
        systemPrompt: _getSystemPrompt(),
      );
      ref.read(aiChatProvider.notifier).addMessage(response, false);
    } catch (e) {
      // Try Kilo fallback
      try {
        final history = ref.read(aiChatProvider)
            .where((m) => m.text != ref.read(aiChatProvider).first.text)
            .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
            .toList();

        final chatService = ref.read(geminiChatServiceProvider);
        final response = await chatService.sendMessageKilo(
          message: text,
          history: history,
          systemPrompt: _getSystemPrompt(),
        );
        ref.read(aiChatProvider.notifier).addMessage(
          "⚠️ *Running via secondary AI (Kilo Code free tier)*\n\n$response",
          false,
        );
      } catch (kiloError) {
        // Use offline fallback
        ref.read(aiChatProvider.notifier).addMessage(
          _getOfflineResponse(text),
          false,
        );
      }
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  String _getSystemPrompt() {
    final route = widget.contextRoute ?? '';
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

    return '''You are a legal assistant for Indian law professionals.
$routeContext
You provide accurate, helpful information about Indian legal procedures, court practices, and legal documentation.
Always remind users to consult a qualified advocate for specific legal advice. Be concise and professional.''';
  }

  String _getOfflineResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('supreme court') || q.contains('sc') || q.contains('apex')) {
      return '''🏛️ **Supreme Court of India**

**Location:** Tilak Marg, New Delhi - 110001

**Current Chief Justice:** Justice Sanjiv Khanna (51st CJI, appointed Jan 2025)

**Composition:**
• Sanctioned Strength: 34 Judges
• Current Working: 32 Judges

**Key Statistics (Jan 2025):**
• Pending Cases: 82,423
• Disposed in 2024: 52,191

**Official Portals:**
• Website: main.sci.gov.in
• E-Filing: efiling.sci.gov.in''';
    } else if (q.contains('delhi high court') || q.contains('dhc') || q.contains('delhi hc')) {
      return '''⚖️ **Delhi High Court**

**Location:** Sher Shah Road, New Delhi - 110003

**Composition:**
• Sanctioned: 60 Judges
• Working: 47 Judges
• Chief Justice: Justice Manmohan

**Pending Cases:** 1,18,000+ (as of Jan 2025)

**Key Services:**
• E-Filing: efiling.delhihighcourt.nic.in
• Case Status: delhihighcourt.nic.in
• E-Gate Pass: Available online''';
    } else if (q.contains('bail') || q.contains('anticipatory')) {
      return '''📋 **Bail Provisions (Under BNSS 2023)**

**Types of Bail:**
1. **Regular Bail** - Section 480 BNSS
   • For persons in custody
   • Application before Magistrate/Sessions

2. **Anticipatory Bail** - Section 482 BNSS  
   • Before arrest apprehension
   • Sessions Court/High Court

3. **Default Bail** - Section 187 BNSS
   • 60/90 days custody limit
   • Right if chargesheet not filed

**Key Changes from CrPC:**
• Hearing within 30 days mandatory
• Written reasons for rejection
• No blanket anticipatory bail''';
    } else if (q.contains('fee') || q.contains('court fee') || q.contains('stamp')) {
      return '''💰 **Court Fee Structure (Delhi)**

**Civil Suits:**
• Money suits: Ad valorem (7.5%)
• Property < ₹1L: ₹500 fixed
• Property > ₹1L: As per schedule
• Injunction: ₹200 - ₹500

**Criminal Matters:**
• Bail Application: ₹50
• Revision Petition: ₹100
• Criminal Appeal: ₹200
• Anticipatory Bail: ₹100

*Note: E-stamp available at authorized vendors*''';
    } else if (q.contains('new law') || q.contains('bns') || q.contains('bnss') || q.contains('bsa')) {
      return '''📚 **New Criminal Laws (Effective July 1, 2024)**

**1. Bharatiya Nyaya Sanhita (BNS)**
Replaces: Indian Penal Code, 1860
• 358 Sections (vs 511 in IPC)
• Key: Section 103 (Murder)

**2. Bharatiya Nagarik Suraksha Sanhita (BNSS)**
Replaces: CrPC, 1973
• 531 Sections (vs 484 in CrPC)
• Key: Section 480 (Bail)

**3. Bharatiya Sakshya Adhiniyam (BSA)**
Replaces: Indian Evidence Act, 1872
• 170 Sections (vs 167 in IEA)

**Quick Conversions:**
• IPC 302 → BNS 103 (Murder)
• IPC 420 → BNS 318 (Cheating)
• IPC 376 → BNS 64 (Rape)''';
    } else if (q.contains('vakalatnama') || q.contains('vakalat') || q.contains('power of attorney')) {
      return '''📄 **Vakalatnama — Power of Attorney for Advocate**

A Vakalatnama is a legal document by which a litigant authorizes an advocate to act, appear, and plead on their behalf in court proceedings.

**🔧 Create a Vakalatnama Now:**
Use our **Vakalatnama Builder** — go to **Document Builder** in the sidebar/home and select Vakalatnama to:
• Fill details via form OR guided chatbot
• Preview the document live in A4 format
• Print or download for court filing''';
    } else {
      return '''I can help you with information about:

📌 **Quick Options:**
• "Supreme Court" - Apex court details
• "Delhi High Court" - HC services
• "Police" - Stations & helplines
• "New laws" - BNS/BNSS/BSA
• "Bail" - Provisions & procedures
• "Court fees" - Fee structure
• "Calendar" - Holidays & vacations
• "Vakalatnama" - Create power of attorney

Ask me anything specific about Indian legal system!''';
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatProvider);
    final showWarning = messages.length >= 20;

    return Container(
      decoration: BoxDecoration(
        color: context.ground,
        borderRadius: widget.isMini ? const BorderRadius.vertical(top: Radius.circular(20)) : null,
      ),
      child: Column(
        children: [
          // Header for mini version
          if (widget.isMini)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.surface,
                border: Border(bottom: BorderSide(color: context.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel, color: AppColors.lal, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Legal AI Assistant',
                      style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (widget.onExpand != null)
                    IconButton(
                      onPressed: widget.onExpand,
                      icon: const Icon(Icons.open_in_full, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 12),
                  if (widget.onClose != null)
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),

          if (showWarning)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.amber.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Conversation getting long. Consider reset.',
                      style: AppTextStyles.bodySmall(color: Colors.amber.shade900).copyWith(fontSize: 10),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(aiChatProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return _buildTypingIndicator(context);
                }
                final message = messages[index];
                return _buildMessage(context, message);
              },
            ),
          ),

          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: context.surface,
              border: Border(top: BorderSide(color: context.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _handleSend(),
                    style: AppTextStyles.body(color: context.textPri).copyWith(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask a legal question...',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.border),
                      ),
                      hintStyle: AppTextStyles.bodySmall(color: context.textSec),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.lal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _handleSend,
                    icon: const Icon(Icons.send, color: Colors.white, size: 16),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * (widget.isMini ? 0.7 : 0.8)),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: message.isUser ? AppColors.lal : context.surface,
            border: message.isUser ? null : Border.all(color: context.border),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(message.isUser ? 12 : 4),
              bottomRight: Radius.circular(message.isUser ? 4 : 12),
            ),
            boxShadow: [
              if (!message.isUser)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: AppTextStyles.body(
                  color: message.isUser ? Colors.white : context.textPri,
                ).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: AppTextStyles.bodySmall(
                  color: message.isUser ? Colors.white70 : context.textSec,
                ).copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.lal),
            ),
            const SizedBox(width: 8),
            Text('Thinking...', style: AppTextStyles.bodySmall(color: context.textSec).copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}