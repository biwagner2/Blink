abstract class SearchResult {
  String get title;
  String? get imageUrl;
  String? get subtitle;
}

abstract class SearchService {
  Future<List<SearchResult>> search(String query);
}