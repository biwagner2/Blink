import 'package:auto_size_text/auto_size_text.dart';
import 'package:blink_v1/navigation/customNavBar.dart';
import 'package:blink_v1/pages/decision_making/category_selection.dart';
import 'package:blink_v1/pages/friends/friendHub.dart';
import 'package:blink_v1/pages/profile/profilePage.dart';
import 'package:blink_v1/utility/labeledIconButton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:blink_v1/models/categories/Restaurant.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class RestaurantDetailsPage extends StatefulWidget{
  final Restaurant restaurant;

  const RestaurantDetailsPage({super.key, required this.restaurant});

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  int _selectedIndex = 1;
   String? _description;

  @override
  void initState() {
    super.initState();
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    final description = await widget.restaurant.getDescription();
    setState(() {
      _description = description;
    });
  }

  Future<void> _handleCallPress() async {
    final success = await widget.restaurant.makePhoneCall();
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }

  Future<void> _handleDirectionsPress() async {
    final success = await widget.restaurant.openDirections();
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open directions')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Navigate to the Friends page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendHub()),
        );
        break;
      case 1:
        // Navigate to the Categories page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CategoriesPage()),
        );
        break;

      case 2:
        // Navigate to the Profile page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  int _current = 0;
  final CarouselController _controller = CarouselController();
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final weekday = DateFormat('EEEE').format(DateTime.now());
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CarouselSlider(
                    carouselController: _controller,
                    options: CarouselOptions(
                      height: screenHeight / 3.2,
                      enlargeCenterPage: false,
                      viewportFraction: 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                    items: [ 
                      for(int x = 0; x < widget.restaurant.additionalImages!.length; x++)
                        CachedNetworkImage(
                          height: screenHeight / 3.2,
                          width: screenWidth,
                          imageUrl: widget.restaurant.additionalImages?[x] ?? widget.restaurant.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                    ],
                  ),
                  Positioned(
                    top: screenHeight/18,
                    left: screenWidth/40,
                    child: FloatingActionButton(
                      heroTag: 'backButton',
                      elevation: 0,
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      child: Icon(Icons.chevron_left_rounded, color: Colors.white, size: screenHeight/20,),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                        height: screenHeight / 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                          ),
                        ),
                        //Padded column with spacers to flex them out.
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                widget.restaurant.name,
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 22,
                                  overflowReplacement: Text(widget.restaurant.name, 
                                        style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                  ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Text(
                                          '${widget.restaurant.rating}',
                                          style: const TextStyle(color: Colors.white, fontFamily: "OpenSans", fontSize: 15),
                                        ),
                                        SizedBox(width: screenWidth / 110),
                                        const Icon(Icons.star, color: Color.fromARGB(255, 183, 236, 236), size: 20),
                                        SizedBox(width: screenWidth / 110),
                                        Text(
                                          widget.restaurant.formatReviewCount(),
                                          style: const TextStyle(color: Colors.white, fontFamily: "OpenSans-Bold", fontSize: 14, fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: widget.restaurant.additionalImages!.asMap().entries.map((entry) {
                                        return Container(
                                          width: 11,
                                          height: 11,
                                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(_current == entry.key ? 0.9 : 0.4),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 3,
                                    child: SizedBox(), // Empty space to balance the layout
                                  ),
                                ],
                              )
                            ]
                          )
                        )
                    )
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_outlined, size: 22,),
                    SizedBox(width: screenWidth / 100),
                    Text(widget.restaurant.formattedEta, 
                        style: const TextStyle(fontSize: 14, fontFamily: "OpenSans-Bold")
                    ),
                    SizedBox(width: screenWidth / 110),
                    const Icon(Icons.circle, size: 8,),
                    SizedBox(width: screenWidth / 110),
                    Text(widget.restaurant.price ?? 'N/A',
                        style: const TextStyle(fontSize: 14, fontFamily: "OpenSans-Bold")
                    ),
                    SizedBox(width: screenWidth / 110),
                    const Icon(Icons.circle, size: 8,),
                    SizedBox(width: screenWidth / 110),
                    Text(widget.restaurant.isClosed ? 'Closed' : 'Open',
                        style: TextStyle(color: widget.restaurant.isClosed ? Colors.red : Colors.green, fontSize: 14, fontFamily: "OpenSans-Bold")
                    ),
                    SizedBox(width: screenWidth / 110),
                    const Icon(Icons.circle, size: 8,),
                    SizedBox(width: screenWidth / 110),
                    Text(widget.restaurant.businessHours?[weekday] ?? '*Check Hours',
                        style: const TextStyle(fontSize: 14, fontFamily: "OpenSans-Bold")
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AutoSizeText(
                  _description ?? 'Loading description...',
                  style: const TextStyle(fontSize: 13, fontFamily: "OpenSans", height: 1.2),
                ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LabeledIconButton(
                      onPressed: _handleCallPress,
                      icon: Icons.phone,
                      label: 'Call',
                    ),
                    LabeledIconButton(
                      onPressed: _handleDirectionsPress,
                      icon: Icons.directions_outlined,
                      label: 'Directions',
                    ),
                    LabeledIconButton(
                      onPressed: () {
                        // Implement save logic here
                      },
                      icon: Icons.bookmark_border_rounded,
                      label: 'Save',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.yellow),
                        Text('${widget.restaurant.rating} (${widget.restaurant.reviewCount} reviews)'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Distance: ${widget.restaurant.getFormattedDistance()}'),
                    Text('Hours: ${widget.restaurant.businessHours != null ? widget.restaurant.businessHours!.entries.map((e) => '${e.key}: ${e.value}').join(', ') : 'N/A'}'),
                    Text('Status: ${widget.restaurant.isClosed ? 'Closed' : 'Open'}'),
                    const SizedBox(height: 16),
                    
                    if (widget.restaurant.menuUrl != null)
                      ElevatedButton(
                        onPressed: () {
                          // Implement menu opening logic here
                        },
                        child: const Text('View Menu'),
                      ),
                    if (widget.restaurant.reservationUrl != null)
                      ElevatedButton(
                        onPressed: () {
                          // Implement reservation logic here
                        },
                        child: const Text('Make Reservation'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/Connect.png", height: 40),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/blink-icon-color.png", height: 40),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/svgs/Profile.svg", height: 40),
                label: '',
              ),
            ],
        ),
      ),
    );
  }
}