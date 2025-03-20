import 'dart:async';
import 'package:blink/backend/services/utility/SearchService.dart';
import 'package:flutter/material.dart';

// This class is a bottom sheet that displays a search bar and search results
// Search results are displayed in a two-column grid view
class GridSearchBottomSheet extends StatefulWidget {
  final String title;
  final String hintText;
  final SearchService searchService;
  final Function(List<SearchResult>) onSave;
  final List<SearchResult>? initialSelections;

  const GridSearchBottomSheet({
    super.key,
    required this.title,
    required this.hintText,
    required this.searchService,
    required this.onSave,
    this.initialSelections,
  });

  @override
  State<GridSearchBottomSheet> createState() => _GridSearchBottomSheetState();
}

class _GridSearchBottomSheetState extends State<GridSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  List<SearchResult> _selectedItems = [];
  Timer? _debounceTimer;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize with any preselected items
    if (widget.initialSelections != null) {
      _selectedItems = List.from(widget.initialSelections!);
    }
  }
  
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
  
  // Toggle selection state of an item
  void _toggleSelection(SearchResult result) {
    setState(() {
      // Check if the item is already selected by matching title and subtitle
      bool isAlreadySelected = _selectedItems.any((item) => 
        item.title == result.title && item.subtitle == result.subtitle);
      
      if (isAlreadySelected) {
        _selectedItems.removeWhere((item) => 
          item.title == result.title && item.subtitle == result.subtitle);
      } else {
        _selectedItems.add(result);
      }
    });
  }
  
  // Check if an item is selected
  bool _isSelected(SearchResult result) {
    return _selectedItems.any((item) => 
      item.title == result.title && item.subtitle == result.subtitle);
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
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              padding: const EdgeInsets.only(bottom: 1, right: 8),
              height: deviceHeight / 23,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
                child: TextField(
                  cursorHeight: 20,
                  controller: _searchController,
                  enableInteractiveSelection: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.text, // Use name type for better keyboard
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onChanged: _debounceSearch,
                ),
            ),
          ),
          
          // Results grid
          Expanded(
            child: 
              _isLoading ? 
                const Center(child: CircularProgressIndicator()) 
              : _searchResults.isEmpty ?
                Center(
                  child: Text(
                    _searchController.text.isEmpty 
                      ? widget.hintText
                      : 'No results found',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65, // Consistent poster aspect ratio
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      final isSelected = _isSelected(result);
                      return _buildGridItem(result, isSelected);
                    },
                  ),
                ),
          ),
          
          // Save button
          Padding(
            padding: const EdgeInsets.only(bottom: 36, left: 24, right: 24),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(deviceWidth/1.5, deviceHeight/20),
              ),
              onPressed: () {
                widget.onSave(_selectedItems);
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGridItem(SearchResult result, bool isSelected) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => _toggleSelection(result),
      child: Column(
        children: [
          // Poster container with fixed size to ensure consistency
          Expanded(
            child: AspectRatio(
              aspectRatio: 2/3, // Standard movie poster aspect ratio
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected 
                      ? const Color.fromARGB(255, 183, 236, 236) 
                      : Colors.transparent,
                    width: 8, // Thicker border to make selection more visible
                  ),
                ),
                child: ClipRRect(
                  child: result.imageUrl != null
                    ? Image.network(
                        result.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.movie, size: 45, color: Colors.grey),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.movie, size: 50, color: Colors.grey),
                        ),
                      ),
                ),
              ),
            ),
          ),
          
          // Title
          Container(
            height: deviceHeight/40, 
            alignment: Alignment.center,
            child: Text(
              result.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // Cut text with ellipsis if too long
            ),
          ),
          
          // Year/subtitle if available
          SizedBox(
            height: deviceHeight/60, // Fixed height for year/subtitle
            child: result.subtitle != null
              ? Text(
                  result.subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                )
              : const SizedBox(), // Empty container if no subtitle to maintain height
          ),
        ],
      ),
    );
  }
}