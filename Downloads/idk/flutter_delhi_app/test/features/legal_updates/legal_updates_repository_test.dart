import 'package:flutter_test/flutter_test.dart';
import 'package:delhi_legal_assistant/features/legal_updates/data/legal_updates_repository.dart';
import 'package:delhi_legal_assistant/features/legal_updates/data/legal_updates_service.dart';
import 'package:delhi_legal_assistant/features/legal_updates/domain/legal_update.dart';

// Manual mock service that complies with Null Safety without code generation
class MockLegalUpdatesService implements LegalUpdatesService {
  List<LegalUpdate> fetchLegalUpdatesResult = [];
  List<String> fetchCategoriesResult = [];
  
  int fetchLegalUpdatesCallCount = 0;
  int fetchCategoriesCallCount = 0;
  
  int? lastLimit;
  String? lastSearchQuery;
  String? lastCategory;

  @override
  Future<List<LegalUpdate>> fetchLegalUpdates({
    int limit = 10,
    String? searchQuery,
    String? category,
  }) async {
    fetchLegalUpdatesCallCount++;
    lastLimit = limit;
    lastSearchQuery = searchQuery;
    lastCategory = category;
    return fetchLegalUpdatesResult;
  }

  @override
  Future<List<String>> fetchCategories() async {
    fetchCategoriesCallCount++;
    return fetchCategoriesResult;
  }
}

void main() {
  group('LegalUpdatesRepository', () {
    late LegalUpdatesRepository repository;
    late MockLegalUpdatesService mockService;

    setUp(() {
      mockService = MockLegalUpdatesService();
      repository = LegalUpdatesRepository(mockService);
    });

    test('getLegalUpdates should delegate to service', () async {
      final mockUpdates = <LegalUpdate>[];
      mockService.fetchLegalUpdatesResult = mockUpdates;

      final result = await repository.getLegalUpdates(limit: 10);
      expect(result, equals(mockUpdates));
      expect(mockService.fetchLegalUpdatesCallCount, equals(1));
      expect(mockService.lastLimit, equals(10));
    });

    test('getLegalUpdates should pass search query to service', () async {
      final mockUpdates = <LegalUpdate>[];
      mockService.fetchLegalUpdatesResult = mockUpdates;

      await repository.getLegalUpdates(limit: 10, searchQuery: 'Supreme Court');
      expect(mockService.fetchLegalUpdatesCallCount, equals(1));
      expect(mockService.lastLimit, equals(10));
      expect(mockService.lastSearchQuery, equals('Supreme Court'));
    });

    test('getCategories should delegate to service', () async {
      final mockCategories = <String>['Supreme Court', 'Delhi High Court'];
      mockService.fetchCategoriesResult = mockCategories;

      final result = await repository.getCategories();
      expect(result, equals(mockCategories));
      expect(mockService.fetchCategoriesCallCount, equals(1));
    });
  });
}
