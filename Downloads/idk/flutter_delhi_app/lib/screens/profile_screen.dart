import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/context_colors.dart';
import '../shared/widgets/fade_slide.dart';
import '../shared/widgets/app_drawer.dart';
import '../core/network/network_provider.dart';
import '../theme/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _advocateName = 'Aditi Sharma';
  String _barId = 'D/2045/2018';
  String _chamberAddress = 'Chamber 432, Delhi High Court, New Delhi';
  int _favoritesCount = 8;
  int _draftsCount = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPracticeDetails();
  }

  Future<void> _loadPracticeDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Calculate drafts count dynamically by counting prefs keys
      final keys = prefs.getKeys();
      int drafts = keys.where((k) => k.startsWith('document_form_')).length;
      if (drafts == 0) drafts = 3; // Fallback to React default

      setState(() {
        _advocateName = prefs.getString('practice_advocate_name') ?? 'Aditi Sharma';
        _barId = prefs.getString('practice_bar_id') ?? 'D/2045/2018';
        _chamberAddress = prefs.getString('practice_chamber_address') ?? 'Chamber 432, Delhi High Court, New Delhi';
        _favoritesCount = prefs.getInt('practice_favorites_count') ?? 8;
        _draftsCount = drafts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePracticeDetails(String name, String bar, String chamber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('practice_advocate_name', name);
    await prefs.setString('practice_bar_id', bar);
    await prefs.setString('practice_chamber_address', chamber);
    
    setState(() {
      _advocateName = name;
      _barId = bar;
      _chamberAddress = chamber;
    });
  }

  void _showPracticeDetailsDialog() {
    final nameController = TextEditingController(text: _advocateName);
    final barController = TextEditingController(text: _barId);
    final chamberController = TextEditingController(text: _chamberAddress);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Practice Details',
            style: AppTextStyles.chatTitle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF111827)
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Advocate Name',
                      hintText: 'e.g. Aditi Sharma',
                    ),
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: barController,
                    decoration: const InputDecoration(
                      labelText: 'Bar Council ID',
                      hintText: 'e.g. D/2045/2018',
                    ),
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    validator: (v) => v == null || v.isEmpty ? 'Bar ID is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: chamberController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Chamber Address',
                      hintText: 'e.g. Chamber 432, High Court',
                    ),
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    validator: (v) => v == null || v.isEmpty ? 'Chamber is required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _savePracticeDetails(
                    nameController.text.trim(),
                    barController.text.trim(),
                    chamberController.text.trim(),
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Practice details updated successfully!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final name = (user?.userMetadata?['display_name'] != null && (user!.userMetadata!['display_name'] as String).isNotEmpty)
        ? user.userMetadata!['display_name'] as String
        : _advocateName;
    final email = user?.email ?? 'counselor@example.com';
    final initialLetter = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: context.ground,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        title: Text('My Profile', style: AppTextStyles.screenTitle(color: context.textPri)),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(context, name, email, initialLetter),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACCOUNT', style: AppTextStyles.bodySmall(color: context.textSec).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        _buildAccountSection(context, ref),
                        const SizedBox(height: 24),
                        Text('MY DATA', style: AppTextStyles.bodySmall(color: context.textSec).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        _buildDataSection(context),
                        const SizedBox(height: 24),
                        _buildSignOutButton(context, ref),
                        const SizedBox(height: 16),
                        Center(
                          child: Text('Version 2.0.0 (Build 245) · PRO Edition', style: AppTextStyles.bodySmall(color: context.textDim)),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email, String initialLetter) {
    return Container(
      width: double.infinity,
      color: context.surface,
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.lazuli, AppColors.lazuliLt],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.lazuli.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(initialLetter, style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'BodoniModa')),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: AppTextStyles.screenTitle(color: context.textPri).copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(email, style: AppTextStyles.bodySmall(color: context.textSec)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Text('PRO MEMBER', style: AppTextStyles.bodySmall(color: Colors.blue).copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    return FadeSlide(
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Column(
          children: [
            _buildListTile(
              context, 
              icon: Icons.shield, 
              iconColor: Colors.blue, 
              title: 'Practice Details',
              subtitle: 'ID: $_barId',
              showBorder: true,
              onTap: _showPracticeDetailsDialog,
            ),
            _buildListTile(
              context, 
              icon: Icons.settings, 
              iconColor: Colors.cyan, 
              title: 'App Settings',
              subtitle: 'Chamber: ${_chamberAddress.split(',').first}',
              showBorder: true,
              onTap: () => _showNotification('App configuration and settings loaded.'),
            ),
            _buildThemeToggleTile(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleTile(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
        
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: 16,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dark Theme', style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                Text(
                  themeMode == ThemeMode.system 
                      ? 'System Default' 
                      : (isDark ? 'Dark Mode Enabled' : 'Light Mode Enabled'),
                  style: AppTextStyles.bodySmall(color: context.textSec),
                ),
              ],
            ),
          ),
          Switch(
            value: isDark,
            activeTrackColor: context.primary,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).toggle();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return FadeSlide(
      delay: const Duration(milliseconds: 100),
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Column(
          children: [
            _buildListTile(
              context, 
              icon: Icons.star, 
              iconColor: Colors.orange, 
              title: 'Saved Favorites',
              trailingText: '$_favoritesCount',
              showBorder: true,
              onTap: () => _showNotification('Favorites list is up to date.'),
            ),
            _buildListTile(
              context, 
              icon: Icons.description, 
              iconColor: Colors.purple, 
              title: 'Draft Forms',
              trailingText: '$_draftsCount',
              onTap: () => context.push('/document_selection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {
    required IconData icon, 
    required Color iconColor, 
    required String title, 
    String? subtitle,
    String? trailingText,
    bool showBorder = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: showBorder ? Border(bottom: BorderSide(color: context.border)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body(color: context.textPri).copyWith(fontWeight: FontWeight.bold)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall(color: context.textSec), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(trailingText, style: AppTextStyles.bodySmall(color: context.textSec)),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, size: 16, color: context.textDim),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return FadeSlide(
      delay: const Duration(milliseconds: 200),
      child: OutlinedButton.icon(
        onPressed: () async {
          final authService = ref.read(firebaseAuthServiceProvider);
          await authService.signOut();
          if (!context.mounted) return;
          context.go('/login');
        },
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.danger,
          side: BorderSide(color: context.danger.withValues(alpha: 0.3)),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
