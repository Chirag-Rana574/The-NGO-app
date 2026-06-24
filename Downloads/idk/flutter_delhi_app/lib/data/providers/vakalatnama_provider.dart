import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vakalatnama Data Model
class VakalatnamaData {
  final String courtName;
  final String caseType;
  final String caseNumber;
  final String jurisdictionYear;
  final List<String> plaintiffs;
  final List<String> defendants;
  final List<String> advocates;
  final String signingDay;
  final String signingMonth;
  final String signingYear;
  final bool consentConfirmed;
  final String? activeField;

  const VakalatnamaData({
    this.courtName = '',
    this.caseType = 'Suit',
    this.caseNumber = '',
    this.jurisdictionYear = '',
    this.plaintiffs = const [''],
    this.defendants = const [''],
    this.advocates = const [''],
    this.signingDay = '',
    this.signingMonth = '',
    this.signingYear = '',
    this.consentConfirmed = false,
    this.activeField,
  });

  VakalatnamaData copyWith({
    String? courtName,
    String? caseType,
    String? caseNumber,
    String? jurisdictionYear,
    List<String>? plaintiffs,
    List<String>? defendants,
    List<String>? advocates,
    String? signingDay,
    String? signingMonth,
    String? signingYear,
    bool? consentConfirmed,
    String? activeField,
  }) {
    return VakalatnamaData(
      courtName: courtName ?? this.courtName,
      caseType: caseType ?? this.caseType,
      caseNumber: caseNumber ?? this.caseNumber,
      jurisdictionYear: jurisdictionYear ?? this.jurisdictionYear,
      plaintiffs: plaintiffs ?? this.plaintiffs,
      defendants: defendants ?? this.defendants,
      advocates: advocates ?? this.advocates,
      signingDay: signingDay ?? this.signingDay,
      signingMonth: signingMonth ?? this.signingMonth,
      signingYear: signingYear ?? this.signingYear,
      consentConfirmed: consentConfirmed ?? this.consentConfirmed,
      activeField: activeField ?? this.activeField,
    );
  }

  Map<String, dynamic> toJson() => {
        'courtName': courtName,
        'caseType': caseType,
        'caseNumber': caseNumber,
        'jurisdictionYear': jurisdictionYear,
        'plaintiffs': plaintiffs,
        'defendants': defendants,
        'advocates': advocates,
        'signingDay': signingDay,
        'signingMonth': signingMonth,
        'signingYear': signingYear,
        'consentConfirmed': consentConfirmed,
        'activeField': activeField,
      };

  factory VakalatnamaData.fromJson(Map<String, dynamic> json) {
    return VakalatnamaData(
      courtName: json['courtName'] as String? ?? '',
      caseType: json['caseType'] as String? ?? 'Suit',
      caseNumber: json['caseNumber'] as String? ?? '',
      jurisdictionYear: json['jurisdictionYear'] as String? ?? '',
      plaintiffs: (json['plaintiffs'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [''],
      defendants: (json['defendants'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [''],
      advocates: (json['advocates'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [''],
      signingDay: json['signingDay'] as String? ?? '',
      signingMonth: json['signingMonth'] as String? ?? '',
      signingYear: json['signingYear'] as String? ?? '',
      consentConfirmed: json['consentConfirmed'] as bool? ?? false,
      activeField: json['activeField'] as String?,
    );
  }

  /// Convert to `Map<String, String>` for PDF generation compatibility
  Map<String, String> toFormData() {
    return {
      'courtName': courtName,
      'caseType': caseType,
      'caseNumber': caseNumber,
      'jurisdictionYear': jurisdictionYear,
      'plaintiffs': plaintiffs.where((p) => p.trim().isNotEmpty).join(', '),
      'defendants': defendants.where((d) => d.trim().isNotEmpty).join(', '),
      'advocateNames': advocates.where((a) => a.trim().isNotEmpty).join(', '),
      'clientNames': plaintiffs.where((p) => p.trim().isNotEmpty).join(', '),
      'executionDay': signingDay,
      'executionMonth': signingMonth,
      'executionYear': signingYear,
    };
  }

  /// Validation errors for this data instance
  List<ValidationError> get errors {
    final List<ValidationError> errors = [];

    if (courtName.trim().isEmpty) {
      errors.add(const ValidationError(field: 'courtName', message: 'Court name is required'));
    }

    final validPlaintiffs = plaintiffs.where((p) => p.trim().isNotEmpty).toList();
    if (validPlaintiffs.isEmpty) {
      errors.add(const ValidationError(field: 'plaintiffs', message: 'At least one plaintiff is required'));
    }

    final validAdvocates = advocates.where((a) => a.trim().isNotEmpty).toList();
    if (validAdvocates.isEmpty) {
      errors.add(const ValidationError(field: 'advocates', message: 'At least one advocate is required'));
    }

    if (signingDay.trim().isEmpty || signingMonth.trim().isEmpty || signingYear.trim().isEmpty) {
      errors.add(const ValidationError(field: 'signingDay', message: 'Complete execution date is required'));
    }

    if (signingDay.trim().isNotEmpty) {
      final day = int.tryParse(signingDay);
      if (day == null || day < 1 || day > 31) {
        errors.add(const ValidationError(field: 'signingDay', message: 'Invalid day (1-31)'));
      }
    }

    if (signingYear.trim().isNotEmpty) {
      final year = int.tryParse(signingYear);
      if (year == null || year < 2000 || year > 2100) {
        errors.add(const ValidationError(field: 'signingYear', message: 'Invalid year'));
      }
    }

    return errors;
  }

  /// Completeness percentage (0-100)
  int get completeness {
    int filled = 0;
    const total = 6; // courtName, plaintiffs, defendants, advocates, date, consent

    if (courtName.trim().isNotEmpty) filled++;
    if (plaintiffs.any((p) => p.trim().isNotEmpty)) filled++;
    if (defendants.any((d) => d.trim().isNotEmpty)) filled++;
    if (advocates.any((a) => a.trim().isNotEmpty)) filled++;
    if (signingDay.trim().isNotEmpty && signingMonth.trim().isNotEmpty && signingYear.trim().isNotEmpty) filled++;
    if (consentConfirmed) filled++;

    return ((filled / total) * 100).round();
  }
}

const List<String> months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

/// Validation Error
class ValidationError {
  final String field;
  final String message;
  const ValidationError({required this.field, required this.message});
}

/// Vakalatnama State Notifier
class VakalatnamaNotifier extends StateNotifier<VakalatnamaData> {
  VakalatnamaNotifier() : super(const VakalatnamaData());

  void setField(String field, dynamic value) {
    switch (field) {
      case 'courtName':
        state = state.copyWith(courtName: value as String);
      case 'caseType':
        state = state.copyWith(caseType: value as String);
      case 'caseNumber':
        state = state.copyWith(caseNumber: value as String);
      case 'jurisdictionYear':
        state = state.copyWith(jurisdictionYear: value as String);
      case 'signingDay':
        state = state.copyWith(signingDay: value as String);
      case 'signingMonth':
        state = state.copyWith(signingMonth: value as String);
      case 'signingYear':
        state = state.copyWith(signingYear: value as String);
      case 'consentConfirmed':
        state = state.copyWith(consentConfirmed: value as bool);
      case 'activeField':
        state = state.copyWith(activeField: value as String?);
    }
  }

  void setArrayItem(String field, int index, String value) {
    switch (field) {
      case 'plaintiffs':
        final newList = List<String>.from(state.plaintiffs);
        if (index < newList.length) {
          newList[index] = value;
        }
        state = state.copyWith(plaintiffs: newList);
      case 'defendants':
        final newList = List<String>.from(state.defendants);
        if (index < newList.length) {
          newList[index] = value;
        }
        state = state.copyWith(defendants: newList);
      case 'advocates':
        final newList = List<String>.from(state.advocates);
        if (index < newList.length) {
          newList[index] = value;
        }
        state = state.copyWith(advocates: newList);
    }
  }

  void addArrayItem(String field) {
    switch (field) {
      case 'plaintiffs':
        state = state.copyWith(plaintiffs: [...state.plaintiffs, '']);
      case 'defendants':
        state = state.copyWith(defendants: [...state.defendants, '']);
      case 'advocates':
        state = state.copyWith(advocates: [...state.advocates, '']);
    }
  }

  void removeArrayItem(String field, int index) {
    switch (field) {
      case 'plaintiffs':
        final newList = List<String>.from(state.plaintiffs)..removeAt(index);
        state = state.copyWith(plaintiffs: newList.isEmpty ? [''] : newList);
      case 'defendants':
        final newList = List<String>.from(state.defendants)..removeAt(index);
        state = state.copyWith(defendants: newList.isEmpty ? [''] : newList);
      case 'advocates':
        final newList = List<String>.from(state.advocates)..removeAt(index);
        state = state.copyWith(advocates: newList.isEmpty ? [''] : newList);
    }
  }

  void setActiveField(String? field) {
    state = state.copyWith(activeField: field);
  }

  void bulkUpdate(Map<String, dynamic> updates) {
    state = state.copyWith(
      courtName: updates['courtName'] ?? state.courtName,
      caseType: updates['caseType'] ?? state.caseType,
      caseNumber: updates['caseNumber'] ?? state.caseNumber,
      jurisdictionYear: updates['jurisdictionYear'] ?? state.jurisdictionYear,
      plaintiffs: updates['plaintiffs'] != null ? List<String>.from(updates['plaintiffs']) : state.plaintiffs,
      defendants: updates['defendants'] != null ? List<String>.from(updates['defendants']) : state.defendants,
      advocates: updates['advocates'] != null ? List<String>.from(updates['advocates']) : state.advocates,
      signingDay: updates['signingDay'] ?? state.signingDay,
      signingMonth: updates['signingMonth'] ?? state.signingMonth,
      signingYear: updates['signingYear'] ?? state.signingYear,
      consentConfirmed: updates['consentConfirmed'] ?? state.consentConfirmed,
    );
  }

  void reset() {
    state = const VakalatnamaData();
  }
}

// Provider
final vakalatnamaProvider = StateNotifierProvider<VakalatnamaNotifier, VakalatnamaData>((ref) {
  return VakalatnamaNotifier();
});
