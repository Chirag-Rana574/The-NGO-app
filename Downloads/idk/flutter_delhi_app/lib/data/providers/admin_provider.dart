import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../core/network/supabase_client.dart';

/// Template Model
class DocumentTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final String templatePath;
  final Map<String, dynamic> fields;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.templatePath,
    required this.fields,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  DocumentTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? templatePath,
    Map<String, dynamic>? fields,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      templatePath: templatePath ?? this.templatePath,
      fields: fields ?? this.fields,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'template_path': templatePath,
        'fields': fields,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory DocumentTemplate.fromJson(Map<String, dynamic> json) {
    return DocumentTemplate(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      templatePath: json['template_path'] as String? ?? '',
      fields: json['fields'] as Map<String, dynamic>? ?? {},
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// Court Directory Model
class CourtDirectory {
  final String id;
  final String name;
  final String type;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final String email;
  final String website;
  final double latitude;
  final double longitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourtDirectory({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    required this.email,
    required this.website,
    required this.latitude,
    required this.longitude,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  CourtDirectory copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? phone,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourtDirectory(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'phone': phone,
        'email': email,
        'website': website,
        'latitude': latitude,
        'longitude': longitude,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory CourtDirectory.fromJson(Map<String, dynamic> json) {
    return CourtDirectory(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'District Court',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? 'Delhi',
      pincode: json['pincode'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// Admin Statistics Model
class AdminStatistics {
  final int totalTemplates;
  final int activeTemplates;
  final int totalCourts;
  final int activeCourts;
  final int totalUsers;
  final int documentsGenerated;
  final DateTime lastUpdated;

  const AdminStatistics({
    this.totalTemplates = 0,
    this.activeTemplates = 0,
    this.totalCourts = 0,
    this.activeCourts = 0,
    this.totalUsers = 0,
    this.documentsGenerated = 0,
    required this.lastUpdated,
  });

  AdminStatistics copyWith({
    int? totalTemplates,
    int? activeTemplates,
    int? totalCourts,
    int? activeCourts,
    int? totalUsers,
    int? documentsGenerated,
    DateTime? lastUpdated,
  }) {
    return AdminStatistics(
      totalTemplates: totalTemplates ?? this.totalTemplates,
      activeTemplates: activeTemplates ?? this.activeTemplates,
      totalCourts: totalCourts ?? this.totalCourts,
      activeCourts: activeCourts ?? this.activeCourts,
      totalUsers: totalUsers ?? this.totalUsers,
      documentsGenerated: documentsGenerated ?? this.documentsGenerated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Admin State
class AdminState {
  final List<DocumentTemplate> templates;
  final List<CourtDirectory> courts;
  final AdminStatistics? statistics;
  final bool isLoading;
  final String? error;
  final bool isAdmin;

  const AdminState({
    this.templates = const [],
    this.courts = const [],
    this.statistics,
    this.isLoading = false,
    this.error,
    this.isAdmin = false,
  });

  AdminState copyWith({
    List<DocumentTemplate>? templates,
    List<CourtDirectory>? courts,
    AdminStatistics? statistics,
    bool? isLoading,
    String? error,
    bool? isAdmin,
  }) {
    return AdminState(
      templates: templates ?? this.templates,
      courts: courts ?? this.courts,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

/// Admin Notifier
class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(const AdminState());

  final SupabaseClient _client = AppSupabaseClient.instance;

  /// Check if current user has admin role via database user_profiles role check
  Future<void> checkAdminStatus() async {
    try {
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser == null) {
        state = state.copyWith(isAdmin: false);
        return;
      }

      final response = await _client
          .from('user_profiles')
          .select('role')
          .eq('user_id', fbUser.uid)
          .maybeSingle();

      final isAdmin = response != null && (response['role'] == 'admin' || response['role'] == 'superadmin');
      state = state.copyWith(isAdmin: isAdmin);
    } catch (e) {
      state = state.copyWith(isAdmin: false, error: e.toString());
    }
  }

  /// Fetch all document templates
  Future<void> fetchTemplates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client
          .from('document_templates')
          .select()
          .order('created_at', ascending: false);

      final templates = (response as List)
          .map((json) => DocumentTemplate.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new document template
  Future<bool> createTemplate(DocumentTemplate template) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client
          .from('document_templates')
          .insert(template.toJson())
          .select();

      if ((response as List).isNotEmpty) {
       final newTemplate = DocumentTemplate.fromJson(response.first);
        state = state.copyWith(
          templates: [...state.templates, newTemplate],
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update an existing document template
  Future<bool> updateTemplate(DocumentTemplate template) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client
          .from('document_templates')
          .update(template.toJson())
          .eq('id', template.id)
          .select();

      if ((response as List).isNotEmpty) {
        final updatedTemplate = DocumentTemplate.fromJson(response.first);
        final updatedTemplates = state.templates.map((t) {
          return t.id == template.id ? updatedTemplate : t;
        }).toList();
        state = state.copyWith(templates: updatedTemplates, isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Delete a document template
  Future<bool> deleteTemplate(String templateId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _client
          .from('document_templates')
          .delete()
          .eq('id', templateId);

      final updatedTemplates = state.templates.where((t) => t.id != templateId).toList();
      state = state.copyWith(templates: updatedTemplates, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Fetch all courts
  Future<void> fetchCourts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client
          .from('court_directory')
          .select()
          .order('name', ascending: true);

      final courts = (response as List)
          .map((json) => CourtDirectory.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(courts: courts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new court entry
  Future<bool> createCourt(CourtDirectory court) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client
          .from('court_directory')
          .insert(court.toJson())
          .select();

      if ((response as List).isNotEmpty) {
        final newCourt = CourtDirectory.fromJson(response.first);
        state = state.copyWith(
          courts: [...state.courts, newCourt],
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update an existing court entry
  Future<bool> updateCourt(CourtDirectory court) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client
          .from('court_directory')
          .update(court.toJson())
          .eq('id', court.id)
          .select();

      if ((response as List).isNotEmpty) {
        final updatedCourt = CourtDirectory.fromJson(response.first);
        final updatedCourts = state.courts.map((c) {
          return c.id == court.id ? updatedCourt : c;
        }).toList();
        state = state.copyWith(courts: updatedCourts, isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Delete a court entry
  Future<bool> deleteCourt(String courtId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _client
          .from('court_directory')
          .delete()
          .eq('id', courtId);

      final updatedCourts = state.courts.where((c) => c.id != courtId).toList();
      state = state.copyWith(courts: updatedCourts, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Fetch admin statistics
  Future<void> fetchStatistics() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Fetch counts from various tables
      final templatesResponse = await _client
          .from('document_templates')
          .select('id, is_active');

      final courtsResponse = await _client
          .from('court_directory')
          .select('id, is_active');

      final usersResponse = await _client
          .from('user_profiles')
          .select('id');

      final documentsResponse = await _client
          .from('documents')
          .select('id');

      final templates = templatesResponse as List;
      final courts = courtsResponse as List;

      final statistics = AdminStatistics(
        totalTemplates: templates.length,
        activeTemplates: templates.where((t) => t['is_active'] == true).length,
        totalCourts: courts.length,
        activeCourts: courts.where((c) => c['is_active'] == true).length,
        totalUsers: usersResponse.length,
        documentsGenerated: documentsResponse.length,
        lastUpdated: DateTime.now(),
      );

      state = state.copyWith(statistics: statistics, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Admin Provider
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});

/// Template List Provider
final templateListProvider = Provider<List<DocumentTemplate>>((ref) {
  return ref.watch(adminProvider).templates;
});

/// Court List Provider
final courtListProvider = Provider<List<CourtDirectory>>((ref) {
  return ref.watch(adminProvider).courts;
});

/// Admin Statistics Provider
final adminStatisticsProvider = Provider<AdminStatistics?>((ref) {
  return ref.watch(adminProvider).statistics;
});

/// Is Admin Provider
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(adminProvider).isAdmin;
});