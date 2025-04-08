// SearchResult.dart

enum SearchResultType { cashFlow, category }

class SearchResult {
  final SearchResultType type;
  final dynamic data;

  SearchResult({required this.type, required this.data});
}
