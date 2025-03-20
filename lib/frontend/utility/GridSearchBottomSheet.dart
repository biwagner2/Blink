import 'dart:async';
import 'package:blink/backend/services/utility/SearchService.dart';
import 'package:flutter/material.dart';

// This class is a bottom sheet that displays a search bar and search results
// Search results are displayed in a two-column grid view
class GridSearchBottomSheet extends StatefulWidget {
  final String title;
  final String hintText;
  final SearchService searchService;
  final Function(SearchResult) onSelect;

  const GridSearchBottomSheet({
    super.key,
    required this.title,
    required this.hintText,
    required this.searchService,
    required this.onSelect,
  });

  @override
  State<GridSearchBottomSheet> createState() => _GridSearchBottomSheetState();
}

class _GridSearchBottomSheetState extends State<GridSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  Timer? _debounceTimer;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    // Clear search results if query is empty
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    // Perform search using the provided search service
    try {
      final results = await widget.searchService.search(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching: $e');
      setState(() => _isLoading = false);
    }
  }

  // Debounce search to prevent multiple requests
  void _debounceSearch(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }
  
  
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: deviceWidth * 0.2,
            height: deviceHeight / 180,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: _debounceSearch,
              ),
            ),
          ),
          
          // Results grid
          Expanded(
            child: 
              _isLoading ? const Center(child: CircularProgressIndicator()) : _searchResults.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty 
                        ? widget.hintText
                        : 'No results found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return _buildGridItem(result);
                      },
                    ),
                  ),
          ),
          // Save button
          ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(deviceWidth/1.5, deviceHeight/20),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
        ],
      ),
    );
  }
  
  Widget _buildGridItem(SearchResult result) {
    return GestureDetector(
      onTap: () => widget.onSelect(result),
      child: Column(
        children: [
          // Poster
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color.fromARGB(255, 183, 236, 236),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: result.imageUrl != null
                  ? Image.network(
                      result.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.movie, size: 40, color: Colors.grey),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.movie, size: 40, color: Colors.grey),
                      ),
                    ),
              ),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              result.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Year/subtitle if available
          if (result.subtitle != null)
            Text(
              result.subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
}