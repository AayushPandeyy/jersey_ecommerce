import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jersey_ecommerce/screens/HomePage.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  List<Widget> pages = [
    HomePage(),
    HomePage(),
    HomePage(),
    HomePage(),
    HomePage(),
  ];

  final List<IconData> bottomBarIcons = [
    Icons.home,
    Icons.search,
    Icons.add_shopping_cart,
    Icons.favorite,
    Icons.person,
  ];


  int currentIndex = 0;
  late AnimationController _animationController;
  late AnimationController _pageController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for navigation bar items
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Animation controller for page transitions
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Scale animation for selected item
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Slide animation for page transitions
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );

    // Fade animation for page transitions
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeIn));

    _animationController.forward();
    _pageController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != currentIndex) {
      setState(() {
        currentIndex = index;
      });

      // Restart animations
      _animationController.reset();
      _pageController.reset();
      _animationController.forward();
      _pageController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Animated page content
            AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 70),
                      child: pages[currentIndex],
                    ),
                  ),
                );
              },
            ),

            // Bottom Navigation Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(right: 20, bottom: 20, left: 20),
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [Color(0xff0F4C75), Color(0xff3282B8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff3282B8).withAlpha((0.3 * 255).toInt()),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        bottomBarIcons.asMap().entries.map((entry) {
                          int index = entry.key;
                          IconData icon = entry.value;
                          bool isSelected = currentIndex == index;

                          return Flexible(
                            child: GestureDetector(
                              onTap: () => _onItemTapped(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color:
                                      isSelected
                                          ? Colors.white.withAlpha(
                                            (0.2 * 255).toInt(),
                                          )
                                          : Colors.transparent,
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color: Colors.white.withAlpha(
                                              (0.3 * 255).toInt(),
                                            ),
                                            width: 1,
                                          )
                                          : null,
                                ),
                                child: AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale:
                                          isSelected
                                              ? _scaleAnimation.value
                                              : 1.0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              child: Icon(
                                                icon,
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : Colors.white
                                                            .withAlpha(
                                                              (0.6 * 255)
                                                                  .toInt(),
                                                            ),
                                                size: isSelected ? 24 : 22,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
