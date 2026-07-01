import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/context_colors.dart';

class CommandItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? shortcut;

  const CommandItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.shortcut,
  });
}

class CommandPalette extends StatefulWidget {
  final List<CommandItem> commands;
  final Function(CommandItem) onExecute;

  const CommandPalette({
    super.key,
    required this.commands,
    required this.onExecute,
  });

  static Future<void> show(BuildContext context, {
    required List<CommandItem> commands,
    required Function(CommandItem) onExecute,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Command Palette',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: const Alignment(0, -0.6), // Top 20%
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
              child: CommandPalette(commands: commands, onExecute: onExecute),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  int _selectedIndex = 0;

  static const Map<String, String> _categoryLabels = {
    'navigation': 'Navigation',
    'action': 'Actions',
    'theme': 'Theme',
    'search': 'Search',
  };

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final filteredCommands = _getFilteredCommands();
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1).clamp(0, filteredCommands.length - 1);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1).clamp(0, filteredCommands.length - 1);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (filteredCommands.isNotEmpty) {
          final selectedCommand = filteredCommands[_selectedIndex];
          widget.onExecute(selectedCommand);
          Navigator.of(context).pop();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
      }
    }
  }

  List<CommandItem> _getFilteredCommands() {
    if (_query.trim().isEmpty) return widget.commands;
    final q = _query.toLowerCase();
    return widget.commands.where((cmd) =>
        cmd.name.toLowerCase().contains(q) ||
        cmd.description.toLowerCase().contains(q)).toList();
  }

  Map<String, List<CommandItem>> _getGroupedCommands(List<CommandItem> commands) {
    final Map<String, List<CommandItem>> grouped = {};
    for (var cmd in commands) {
      grouped.putIfAbsent(cmd.category, () => []).add(cmd);
    }
    return grouped;
  }

  Widget _buildCommandItem(CommandItem cmd, List<CommandItem> filteredCommands) {
    final globalIndex = filteredCommands.indexOf(cmd);
    final isSelected = globalIndex == _selectedIndex;

    return InkWell(
      onTap: () {
        widget.onExecute(cmd);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? context.raised.withValues(alpha: 0.5) : Colors.transparent,
        child: Row(
          children: [
            Icon(Icons.terminal, color: context.textSec, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cmd.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textPri,
                    ),
                  ),
                  Text(
                    cmd.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSec,
                    ),
                  ),
                ],
              ),
            ),
            if (cmd.shortcut != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.raised,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: context.border),
                ),
                child: Text(
                  cmd.shortcut!,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: context.textSec,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCommands = _getFilteredCommands();
    final groupedCommands = _getGroupedCommands(filteredCommands);
    
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKey,
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Search Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.border)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: context.textSec),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                          _selectedIndex = 0;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Type a command or search...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(color: context.textDim),
                      ),
                      style: TextStyle(fontSize: 16, color: context.textPri),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.textSec, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Commands List
            Expanded(
              child: filteredCommands.isEmpty
                  ? Center(
                      child: Text(
                        'No commands found',
                        style: TextStyle(color: context.textSec),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: groupedCommands.length,
                      itemBuilder: (context, groupIndex) {
                        final category = groupedCommands.keys.elementAt(groupIndex);
                        final commands = groupedCommands[category]!;
                        final label = _categoryLabels[category] ?? category.toUpperCase();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: context.textSec,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            for (final cmd in commands) _buildCommandItem(cmd, filteredCommands),
                          ],
                        );
                      },
                    ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.border)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('↑↓ Navigate', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      SizedBox(width: 12),
                      Text('↵ Select', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      SizedBox(width: 12),
                      Text('ESC Close', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  Text('Cmd+P to toggle', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}