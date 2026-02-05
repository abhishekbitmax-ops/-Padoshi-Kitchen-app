import 'package:flutter/material.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/Homescreen.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/cartscreen.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/profile.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';
import 'package:padoshi_kitchen/widgets/viewcart.dart';

class RestaurantBottomNav extends StatefulWidget {
  final int initialIndex;

  const RestaurantBottomNav({
    super.key,
    this.initialIndex = 0, // default Home
  });

  @override
  State<RestaurantBottomNav> createState() => _RestaurantBottomNavState();
}

class _RestaurantBottomNavState extends State<RestaurantBottomNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // 👈 important
  }

  final List<IconData> icons = [
    Icons.home_outlined,
    Icons.menu_book_outlined,
    Icons.shopping_cart_outlined,
    Icons.person_outline,
  ];

  final List<String> labels = ["Home", "Menu", "Cart", "Profile"];

  final List<Widget> screens = [
    Homescreen(),
    Text("Menu Screen"),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          screens[_currentIndex],
          // 🛒 Global ZomatoCartBar at bottom (hide on CartScreen)
          if (_currentIndex != 2)
            Positioned(bottom: 3, left: 0, right: 0, child: ZomatoCartBar()),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            final isSelected = _currentIndex == index;

            return InkWell(
              onTap: () {
                setState(() => _currentIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.background : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(icons[index], color: Colors.white),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Text(
                        labels[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
