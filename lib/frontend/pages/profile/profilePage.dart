import 'package:blink/frontend/navigation/customNavBar.dart';
import 'package:blink/frontend/pages/decision_making/category_selection.dart';
import 'package:blink/frontend/pages/friends/friendHub.dart';
import 'package:blink/frontend/pages/onboarding/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 2;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _fetchDisplayName();
  }

  Future<void> _fetchDisplayName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _displayName = user.userMetadata?['display_name'] as String? ?? '';
      });
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
        // Do nothing since we already on the correct page.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            "Profile",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUp()),
                    (route) => false,
                  );
                },
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                  ),
                )
              ),
            ),
          ],
        ),
        bottomNavigationBar: MediaQuery(
          data: MediaQuery.of(context).removePadding(removeBottom: true),
          child: CustomBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/Connect.png", height: screenHeight / 21.3),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/images/blink-icon-color.png", height: screenHeight / 18.9),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset("assets/svgs/Profile.svg", height: screenHeight / 21.3),
                label: '',
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage("assets/images/logo-white-transparent.png"),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName.isNotEmpty ? _displayName : 'Coming Soon',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}