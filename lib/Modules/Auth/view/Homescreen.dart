import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/Model.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/Menuscreen.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/navbar.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final AuthController kitchenController = Get.find<AuthController>();

  final PageController _pageController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  static const Duration bannerInterval = Duration(seconds: 4);
  static const Duration bannerAnimDuration = Duration(milliseconds: 400);

  final List<String> banners = [
    "https://images.unsplash.com/photo-1604382354936-07c5d9983bd3",
    "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe",
    "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38",
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
    _startAutoBanner();

    /// ✅ CALL API HERE
    kitchenController.fetchNearbyKitchens();
  }

  void _startAutoBanner() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(bannerInterval, (_) {
      if (!_pageController.hasClients) return;
      _currentBanner = (_currentBanner + 1) % banners.length;
      _pageController.animateToPage(
        _currentBanner,
        duration: bannerAnimDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          _header(),
          const SizedBox(height: 16),

          /// 🔥 DYNAMIC CONTENT
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Obx(() {
                  if (kitchenController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (kitchenController.kitchens.isEmpty) {
                    return const Center(
                      child: Text("No nearby kitchens found"),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _bannerSection(),
                      const SizedBox(height: 28),
                      _sectionTitle(),
                      const SizedBox(height: 12),

                      /// 🍽️ KITCHEN LIST
                      ...kitchenController.kitchens.map(
                        (kitchen) => _KitchenCard(kitchen: kitchen),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔝 HEADER
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.background],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// LEFT TEXT
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Padoshi Kitchen 🍴",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Fresh food made with love",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),

          const Spacer(),

          /// 🔔 NOTIFICATION
          _headerIcon(
            icon: Icons.notifications_none,
            onTap: () {
              // TODO: Notifications screen
            },
          ),

          const SizedBox(width: 10),

          /// 🛒 CART
          _headerIcon(
            icon: Icons.shopping_cart_outlined,
            onTap: () {
              Get.offAll(() => const RestaurantBottomNav(initialIndex: 2));
            },
          ),
        ],
      ),
    );
  }

  Widget _headerIcon({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }

  /// 🖼️ BANNER
  Widget _bannerSection() {
    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: _pageController,
        itemCount: banners.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            banners[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✨ SECTION TITLE
  Widget _sectionTitle() {
    return const Text(
      "Nearby Kitchen",
      style: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.bold,
        color: AppColors.background,
      ),
    );
  }
}

/// 🍽️ DYNAMIC KITCHEN CARD
class _KitchenCard extends StatelessWidget {
  final Kitchen kitchen;
  const _KitchenCard({required this.kitchen});

  @override
  Widget build(BuildContext context) {
    final capabilities = kitchen.deliveryCapabilities;
    final pricing = kitchen.deliveryPricing;
    final service = kitchen.serviceability;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🏠 NAME
          Text(
            kitchen.restaurantInfo?.name ?? "Kitchen",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          _row(Icons.location_on, "${kitchen.distanceKm ?? 0} km away"),
          _row(Icons.home_work, kitchen.location?.societyName ?? ""),

          const SizedBox(height: 6),

          _row(
            Icons.delivery_dining,
            "Kitchen Rider: ${capabilities?.kitchenRider == true ? "Yes" : "No"}",
          ),
          _row(
            Icons.shopping_bag,
            "Self Pickup: ${capabilities?.selfPickup == true ? "Yes" : "No"}",
          ),
          _row(
            Icons.local_shipping,
            "Partner Delivery: ${capabilities?.partner == true ? "Yes" : "No"}",
          ),
          _row(
            Icons.motorcycle,
            "Third Party: ${capabilities?.thirdParty == true ? "Yes" : "No"}",
          ),

          const SizedBox(height: 6),

          _row(
            Icons.map,
            "Max Radius: ${service?.maxDeliveryRadiusKm ?? 0} km",
          ),

          const SizedBox(height: 10),

          _row(Icons.currency_rupee, "Base Fee: ₹${pricing?.baseFee ?? 0}"),
          _row(Icons.route, "Per Km Charge: ₹${pricing?.perKmCharge ?? 0}"),
          _row(
            Icons.trending_up,
            "Partner Rate: ₹${pricing?.partnerRatePerKm ?? 0}/km",
          ),

          const SizedBox(height: 16),

          /// 👉 VIEW MENU
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                debugPrint("PASSING KITCHEN ID => ${kitchen.id}");

                if (kitchen.id == null) {
                  Get.snackbar("Error", "Kitchen ID missing");
                  return;
                }

                Get.to(
                  () => const Menuscreen(),
                  arguments: {"kitchenId": kitchen.id},
                );
              },

              child: const Text(
                "View Menu",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
