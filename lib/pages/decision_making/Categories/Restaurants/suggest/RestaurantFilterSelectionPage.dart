import 'package:blink_v1/pages/decision_making/Categories/Restaurants/RestaurantCriteriaPage1.dart';
import 'package:flutter/material.dart';

class RestaurantFilterSelectionPage extends StatefulWidget {
  final Set<String> selectedFoodTypes;

  const RestaurantFilterSelectionPage({Key? key, required this.selectedFoodTypes}) : super(key: key);

  @override
  _RestaurantFilterSelectionPageState createState() => _RestaurantFilterSelectionPageState();
}

class _RestaurantFilterSelectionPageState extends State<RestaurantFilterSelectionPage> {
  late Set<String> _selectedFoodTypes;
  final ScrollController _scrollController = ScrollController();
  String? _selectedPricing;
  String? _selectedDistance;

  @override
  void initState() {
    super.initState();
    _selectedFoodTypes = Set<String>.from(widget.selectedFoodTypes);
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedFoodTypes.remove(tag);
    });
    if (_selectedFoodTypes.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RestaurantCriteriaPage1()),
      );
    }
  }

  void _selectPricing(String pricing) {
    setState(() {
      _selectedPricing = pricing;
    });
  }

  void _selectDistance(String distance) {
    setState(() {
      _selectedDistance = distance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              const Text(
                'You have your criteria. Let us make you a recommendation.',
                softWrap: true,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'HammerSmithOne-Regular',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              const Text(
                "Cuisine",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedFoodTypes.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'HammerSmithOne-Regular',
                      ),
                    ),
                    backgroundColor: const Color.fromARGB(255, 237, 237, 237),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onDeleted: () => _removeTag(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    deleteIconColor: Colors.grey[600],
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              const Text(
                "Occasion",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 115,
                child: RawScrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  thumbColor: const Color.fromARGB(255, 183, 236, 236),
                  radius: const Radius.circular(20),
                  thickness: 6,
                  child: ListView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildOccasionBox(Icons.free_breakfast, 'Breakfast/Brunch'),
                      _buildOccasionBox(Icons.lunch_dining, 'Lunch'),
                      _buildOccasionBox(Icons.dinner_dining, 'Dinner'),
                      _buildOccasionBox(Icons.takeout_dining_sharp, 'Take-Out'),
                      _buildOccasionBox(Icons.nightlife, 'Late-Night'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Pricing",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPricingBox('\$'),
                  const SizedBox(width: 8),
                  _buildPricingBox('\$\$'),
                  const SizedBox(width: 8),
                  _buildPricingBox('\$\$\$'),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                "Distance",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDistanceBox('<10 min'),
                  const SizedBox(width: 8),
                  _buildDistanceBox('10-30 min'),
                  const SizedBox(width: 8),
                  _buildDistanceBox('30+ min'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOccasionBox(IconData icon, String label) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 47),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'HammerSmithOne-Regular',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingBox(String pricing) {
    final isSelected = _selectedPricing == pricing;
    return GestureDetector(
      onTap: () => _selectPricing(pricing),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 183, 236, 236) : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          pricing,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'HammerSmithOne-Regular',
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceBox(String distance) {
    final isSelected = _selectedDistance == distance;
    return GestureDetector(
      onTap: () => _selectDistance(distance),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 183, 236, 236) : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          distance,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'HammerSmithOne-Regular',
          ),
        ),
      ),
    );
  }
}