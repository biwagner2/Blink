
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class RestaurantFilterSelectionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const RestaurantFilterSelectionPage({super.key, required this.onFilterChanged});

  @override
  _RestaurantFilterSelectionPageState createState() => _RestaurantFilterSelectionPageState();
}

class _RestaurantFilterSelectionPageState extends State<RestaurantFilterSelectionPage> {

  final ScrollController _scrollController = ScrollController();
  String? _selectedPricing;
  String? _selectedDistance;
  String? _selectedOccasion;
  List<String> _selectedCuisines = [];
  bool _isCuisineDropdownOpen = false;

  double _minRating = 3.0;
  double _maxRating = 5.0;
  bool _isRatingsSelected = false;

  final List<String> _cuisineOptions = [
    'American', 'Bakery', 'Caribbean', 'Coffee', 'East Asian', 'Fast Food',
    'Halal', 'Healthy', 'Indian', 'Italian', 'Mediterranean', 'Mexican',
    'Sweet', 'Tea', 'Vegan', 'Vegetarian'
  ];

  void _toggleCuisineDropdown() {
    setState(() {
      _isCuisineDropdownOpen = !_isCuisineDropdownOpen;
    });
  }

  void _toggleCuisineSelection(String cuisine) {
    setState(() {
      if (_selectedCuisines.contains(cuisine.toLowerCase())) {
        _selectedCuisines.remove(cuisine.toLowerCase());
      } else {
        _selectedCuisines.add(cuisine.toLowerCase());
      }
    });
    _updateFilters();
  }

  void _removeCuisine(String cuisine) {
    setState(() {
      _selectedCuisines.remove(cuisine);
    });
    _updateFilters();
  }

  @override
  void initState() {
    super.initState();
  }

  void _selectOccasion(String occasion) {
    setState(() {
      if(occasion == _selectedOccasion) {
        _selectedOccasion = null;
        return;
      }
      else {
        _selectedOccasion = occasion;
      }
    });
    _updateFilters();
  }

  void _selectPricing(String pricing) {
    setState(() {
      if(pricing == _selectedPricing) {
        _selectedPricing = null;
        return;
      }
      else {
        _selectedPricing = pricing;
      }
    });
    _updateFilters();
  }

  void _selectDistance(String distance) {
    setState(() {
      if(distance == _selectedDistance) {
        _selectedDistance = null;
        return;
      }
      else {
        _selectedDistance = distance;
      }
    });
    _updateFilters();
  }

   void _updateFilters() {
    widget.onFilterChanged({
      'cuisines': _selectedCuisines,
      'occasion': _selectedOccasion,
      'pricing': _selectedPricing,
      'distance': _selectedDistance,
      'minRating': _minRating,
      'maxRating': _maxRating,
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = screenWidth * 0.05;
    
    return Scaffold(
      backgroundColor: Colors.white,
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
              const SizedBox(height: 8),
               _buildCuisineDropdown(),
              const SizedBox(height: 18),
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
              const SizedBox(height: 20),
              _buildRatingsBottomSheet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOccasionBox(IconData icon, String occasion) {
     final isSelected = _selectedOccasion == occasion;
    return GestureDetector(
      onTap: () => _selectOccasion(occasion),
      child: Container(
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: Colors.black) : Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(20),
        ),
        width: 130,
        margin: const EdgeInsets.only(right: 5, bottom: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 47),
            const SizedBox(height: 8),
            Text(
              occasion,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'HammerSmithOne-Regular',
              ),
            ),
          ],
        ),
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

  Widget _buildCuisineDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: _toggleCuisineDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: MediaQuery.of(context).size.width / 2.5,
          decoration: BoxDecoration(
            color: _selectedCuisines.isNotEmpty
                ? const Color.fromARGB(255, 183, 236, 236)
                : Colors.white,
            border: _selectedCuisines.isNotEmpty
                ? Border.all(color: Colors.transparent)
                : Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Cuisine",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                _isCuisineDropdownOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.black,
                size: 30,
              ),
            ],
          ),
        ),
      ),
      if (_isCuisineDropdownOpen)
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cuisineOptions.map((cuisine) {
              final isSelected = _selectedCuisines.contains(cuisine);
              return GestureDetector(
                onTap: () => _toggleCuisineSelection(cuisine),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromARGB(255, 183, 236, 236)
                        : Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cuisine,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'HammerSmithOne-Regular',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      if (_selectedCuisines.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedCuisines.map((cuisine) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color.fromARGB(255, 137, 137, 137)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cuisine.substring(0,1).toUpperCase() + cuisine.substring(1),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 101, 101, 101),
                        fontFamily: 'HammerSmithOne-Regular',
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _removeCuisine(cuisine),
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
    ],
  );
}


 Widget _buildRatingsBottomSheet() {
  String formatRating(double rating) {
    return (rating % 1 == 0) ? rating.toStringAsFixed(0) : rating.toStringAsFixed(1);
  }

  String getRatingDisplay() {
    if (_minRating == _maxRating) {
      return formatRating(_minRating);
    } else {
      return "${formatRating(_minRating)} - ${formatRating(_maxRating)}";
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: _showRatingsBottomSheet,
        child: Container(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          width: MediaQuery.of(context).size.width / 2.1,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin:  const EdgeInsets.only(bottom: 5),
                child:  const Icon(
                  Icons.star_rate_rounded,
                  color: Color.fromARGB(255, 183, 236, 236),
                  size: 33,
                ),
              ),
              _isRatingsSelected
                  ? Text(
                      getRatingDisplay(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Text(
                      "Ratings",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.black,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

void _showRatingsBottomSheet() {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          final deviceHeight = MediaQuery.of(context).size.height;
          final deviceWidth = MediaQuery.of(context).size.width;
          return Container(
            height: deviceHeight / 2.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: deviceHeight/20 - 10),
                const Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Move the slider to adjust the range you\'re looking for.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 84, 84, 84),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'HammerSmithOne-Regular',
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  child: SfSliderTheme(
                    data: const SfSliderThemeData(
                      activeTrackColor: Color.fromARGB(255, 183, 236, 236),
                      labelOffset: Offset(0, 55),
                  ),
                    child: SfRangeSlider(
                        min: 3.0,
                        max: 5.0,
                        interval: .5,
                        dragMode: SliderDragMode.onThumb,
                        values: SfRangeValues(_minRating, _maxRating),
                        showLabels: true,
                        activeColor: const Color.fromARGB(255, 183, 236, 236),
                        inactiveColor: const Color.fromARGB(255, 191, 191, 191),
                        stepSize: .5,
                        showDividers: true,
                        dividerShape: _DividerShape(),
                        trackShape: _SfTrackShape(),
                        thumbShape: _SfThumbShape(),
                        onChanged: (SfRangeValues values) {
                          setState(() {
                            _minRating = values.start;
                            _maxRating = values.end;
                          });
                        },
                      ),
                  )
                ),
                SizedBox(height: deviceHeight/20 - 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 183, 236, 236),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize:  Size(deviceWidth/1.5, deviceHeight/20),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // You can add logic here to use the _minRating and _maxRating values
                    this.setState(() {
                      _isRatingsSelected = true;
                    });
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color:Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
}

class _DividerShape extends SfDividerShape {
  @override
  void paint(PaintingContext context, Offset center, Offset? thumbCenter,
      Offset? startThumbCenter, Offset? endThumbCenter,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection}) 
  {
    final bool isActive = center.dx >= startThumbCenter!.dx && center.dx <= endThumbCenter!.dx;
    if (!isActive) {
      context.canvas.drawCircle(center, 8.0,
          Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.fill
            ..color = const Color.fromARGB(255, 100, 100, 100));
    }
  }
}

class _SfTrackShape extends SfTrackShape {
  @override
  void paint(PaintingContext context, Offset offset, Offset? thumbCenter,
      Offset? startThumbCenter, Offset? endThumbCenter,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Animation<double> enableAnimation,
      required Paint? inactivePaint,
      required Paint? activePaint,
      required TextDirection textDirection}) 
  {
    final Paint activePaint = Paint()
      ..color = const Color.fromARGB(255, 183, 236, 236)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    final Paint inactivePaint = Paint()
      ..color = const Color.fromARGB(255, 191, 191, 191)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    super.paint(context, offset, thumbCenter, startThumbCenter, endThumbCenter,
        parentBox: parentBox,
        themeData: themeData,
        enableAnimation: enableAnimation,
        inactivePaint: inactivePaint,
        activePaint: activePaint,
        textDirection: textDirection
    );
  }
}

class _SfThumbShape extends SfThumbShape {
  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required SfThumb? thumb}) {
    context.canvas.drawCircle(
      center,
      16.0,
      Paint()
        ..color = const Color.fromARGB(255, 183, 236, 236)
        ..style = PaintingStyle.fill
        ..strokeWidth = 10
    );
    context.canvas.drawCircle(
      center,
      8.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
    );
  }
}