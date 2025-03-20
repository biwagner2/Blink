import 'dart:async';

import 'package:blink/backend/services/utility/SearchService.dart';
import 'package:flutter/material.dart';

class SearchBottomSheet extends StatefulWidget {
  final String title;
  final String hintText;
  final SearchService searchService;
  final Function(List<SearchResult>) onSave;
  final List<SearchResult>? initialSelections;

  const SearchBottomSheet({
    super.key,
    required this.title,
    required this.hintText,
    required this.searchService,
    required this.onSave,
    this.initialSelections,
  });

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
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
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await widget.searchService.search(query);
      // Filter out duplicate entries (same name, subtitle, and image)
      final uniqueResults = <SearchResult>[];
      final uniqueIdentifiers = <String>{};
      
      for (final result in results) {
        final identifier = '${result.title}|${result.subtitle ?? ""}|${result.imageUrl ?? ""}';
        if (!uniqueIdentifiers.contains(identifier)) {
          uniqueIdentifiers.add(identifier);
          uniqueResults.add(result);
        }
      }
      
      setState(() {
        _searchResults = uniqueResults;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching: $e');
      setState(() => _isLoading = false);
    }
  }

  void _debounceSearch(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  // Toggle selection of an item
  void _toggleSelection(SearchResult result) {
    setState(() {
      // Create a unique ID based on title and subtitle to identify items
      final resultId = '${result.title}|${result.subtitle ?? ""}|${result.imageUrl ?? ""}';
      
      // Check if the item is already selected
      final existingIndex = _selectedItems.indexWhere((item) => 
        '${item.title}|${item.subtitle ?? ""}|${item.imageUrl ?? ""}' == resultId);
      
      if (existingIndex >= 0) {
        // If selected, remove it
        _selectedItems.removeAt(existingIndex);
      } else {
        // If not selected, add it
        _selectedItems.add(result);
      }
    });
  }

  // Check if an item is selected
  bool _isSelected(SearchResult result) {
    final resultId = '${result.title}|${result.subtitle ?? ""}|${result.imageUrl ?? ""}';
    return _selectedItems.any((item) => 
      '${item.title}|${item.subtitle ?? ""}|${item.imageUrl ?? ""}' == resultId);
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                keyboardType: TextInputType.name, // Use name type for better keyboard
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

          // Search results
          Expanded(
            child: Stack(
              children: [
                // Content
                if (_searchResults.isNotEmpty)
                  ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      final isSelected = _isSelected(result);
                      return _buildSearchResultTile(result, isSelected);
                    },
                  )
                else if (_searchController.text.isNotEmpty && !_isLoading)
                  Center(
                    child: Text(
                      'No results found for "${_searchController.text}"',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                else if (_searchController.text.isEmpty && !_isLoading)
                  Center(
                    child: Text(
                      'Search for people...',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                
                // Loading indicator (centered)
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.only(bottom: 36, left: 24, right: 24, top: 12),
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

  Widget _buildSearchResultTile(SearchResult result, bool isSelected) {
    return ListTile(
      leading: result.imageUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(result.imageUrl!),
              radius: 25,
            )
          : const CircleAvatar(
              radius: 25,
              child: Icon(Icons.person),
            ),
      title: Text(
        result.title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: result.subtitle != null ? Text(result.subtitle!) : null,
      tileColor: isSelected ? const Color.fromARGB(255, 183, 236, 236).withOpacity(0.3) : null,
      onTap: () => _toggleSelection(result),
      trailing: isSelected 
          ? const Icon(Icons.check_circle, color: Color.fromARGB(255, 183, 236, 236), size: 28)
          : null,
    );
  }
}