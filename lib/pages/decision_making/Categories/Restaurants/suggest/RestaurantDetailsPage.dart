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
import 'package:flutter/widgets.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
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
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const FriendHub(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        // Navigate to the Categories page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const CategoriesPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;

      case 2:
        // Navigate to the Profile page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const ProfilePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
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
                      height: screenHeight / 3.9,
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
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
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
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: const Color.fromRGBO(209, 209, 209, 1), width: 1.1),
                      ),
                      height: screenWidth/5,
                      width: screenWidth/2.8,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '0', //Eventually make it a counter variable. Maybe convert numbers into 1K, 21.6K format etc. 
                            style: TextStyle(fontSize: 25, fontFamily: "OpenSans",)
                          ),
                          Text(
                            'friends also saved this',
                            style: TextStyle(fontSize: 10, fontFamily: "OpenSans", color: Color.fromRGBO(120, 120, 120, 1))
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                          'Hours',
                          style: TextStyle(fontSize: 22),
                        ),
                        Row(
                          children: [
                            Text(widget.restaurant.isClosed ? 'Closed now' : 'Open',
                                  style: TextStyle(color: widget.restaurant.isClosed ? Colors.red : Colors.green, fontSize: 14, fontFamily: "OpenSans-Bold")
                            ),
                            SizedBox(width: screenWidth / 110),
                            const Icon(Icons.circle, size: 4,),
                            SizedBox(width: screenWidth / 110),
                            Text(widget.restaurant.businessHours?[weekday] ?? '*Check Hours',
                                style: const TextStyle(fontSize: 14, fontFamily: "OpenSans")
                            ),
                          ],
                        )
                        ]
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        onPressed: () { 
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Business Hours', textAlign: TextAlign.center,),
                                content: SingleChildScrollView(child: _buildHoursContent()),
                                actions: [
                                  TextButton(
                                    child: const Text('Close', style: TextStyle(fontSize: 18)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Image.asset('assets/images/icons8-arrow-right-96.png', height: screenWidth/13, width: screenWidth/13,),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                          'Website',
                          style: TextStyle(fontSize: 22),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.restaurant.name.length > 20 ? 'https://www.yelp.com/${widget.restaurant.name.substring(0,20).replaceAll(' ', '-').toLowerCase()}' : 'https://www.yelp.com/${widget.restaurant.name.replaceAll(' ', '-').toLowerCase()}',                             
                              style: const TextStyle(fontSize: 14, fontFamily: "OpenSans")
                            ),
                          ],
                        )
                        ]
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(onPressed: widget.restaurant.visitWebsite, icon: Image.asset('assets/images/icons8-arrow-right-96.png', height: screenWidth/13, width: screenWidth/13,)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          'Menu',
                          style: TextStyle(fontSize: 22),
                        ),
                        Row(children: [
                            Text(
                              '*Available on website',
                              style: TextStyle(fontSize: 14, fontFamily: "OpenSans")
                            )
                          ],
                        )
                        ]
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(onPressed: widget.restaurant.visitWebsite, icon: Image.asset('assets/images/icons8-arrow-right-96.png', height: screenWidth/13, width: screenWidth/13,)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          'Reserve',
                          style: TextStyle(fontSize: 22),
                        ),
                        Row(children: [
                            Text(
                              'Call to reserve a table',
                              style: TextStyle(fontSize: 14, fontFamily: "OpenSans")
                            )
                          ],
                        ),
                        ]
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(onPressed: _handleCallPress, icon: Image.asset('assets/images/icons8-arrow-right-96.png', height: screenWidth/13, width: screenWidth/13,)),
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
                icon: Image.asset("assets/images/blink-icon-color.png", height: 45),
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

  Widget _buildHoursContent() {
    if (widget.restaurant.businessHours == null) {
      return const Text('No hours information available. Check with the restaurant.');
    }

    List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: daysOfWeek.map((day) {
        String hours = widget.restaurant.businessHours![day] ?? 'Closed';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                hours,
                style: TextStyle(
                  color: hours == 'Closed' ? Colors.red : null,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}