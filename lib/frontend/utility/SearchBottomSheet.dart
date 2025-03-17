import 'dart:async';

import 'package:blink/backend/services/utility/SearchService.dart';
import 'package:flutter/material.dart';

class SearchBottomSheet extends StatefulWidget {
  final String title;
  final String hintText;
  final SearchService searchService;
  final Function(SearchResult) onSelect;

  const SearchBottomSheet({
    super.key,
    required this.title,
    required this.hintText,
    required this.searchService,
    required this.onSelect,
  });

  @override
  _SearchBottomSheetState createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
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
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

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

  void _debounceSearch(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _debounceSearch,
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return _buildSearchResultTile(result);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(SearchResult result) {
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
      title: Text(result.title),
      subtitle: result.subtitle != null ? Text(result.subtitle!) : null,
      onTap: () {
        Navigator.pop(context);
        widget.onSelect(result);
      },
    );
  }
}