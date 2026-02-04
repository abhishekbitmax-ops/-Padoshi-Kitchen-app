import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/Model.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/navbar.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';

class Menuscreen extends StatefulWidget {
  const Menuscreen({super.key});

  @override
  State<Menuscreen> createState() => _MenuscreenState();
}

class _MenuscreenState extends State<Menuscreen> {
  String foodFilter = "all";

  // Track selected addon IDs per item so chips toggle updates prices immediately
  final Map<String, Set<String>> _selectedAddons = {};

  ImageData? _getItemImage(Item item, List<Category> categories) {
    try {
      return categories.firstWhere((c) => c.id == item.category).image;
    } catch (_) {
      return null;
    }
  }

  final AuthController menuController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    final kitchenId = args?["kitchenId"];

    debugPrint("PASSING KITCHEN ID => $kitchenId");

    if (kitchenId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        menuController.fetchMenu(kitchenId: kitchenId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.shopping_cart_outlined, color: Colors.white),
          ),
        ],
        title: const Text("Our Menu", style: TextStyle(color: Colors.white)),
      ),

      body: SafeArea(
        child: Obx(() {
          final menu = menuController.menuResponse.value;

          if (menu == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = menuController.categories;
          final items = menuController.items;
          final selectedCategoryId = menuController.selectedCategoryId.value;

          if (items.isEmpty) {
            return const Center(child: Text("No items available"));
          }

          final filteredItems = items.where((item) {
            final matchCategory =
                selectedCategoryId.isEmpty ||
                item.category == selectedCategoryId;

            final matchFood =
                foodFilter == "all" ||
                (foodFilter == "veg" && item.foodType == "VEG") ||
                (foodFilter == "nonveg" && item.foodType != "VEG");

            return matchCategory && matchFood;
          }).toList();

          return Row(
            children: [
              /// 🟠 CATEGORY PANEL
              Container(
                width: 110,
                color: Colors.white,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (_, index) {
                    final cat = categories[index];
                    final isSelected =
                        menuController.selectedCategoryId.value == cat.id;

                    return InkWell(
                      onTap: () {
                        menuController.selectedCategoryId.value = cat.id ?? "";
                      },

                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 6,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.background,
                                  ],
                                )
                              : null,
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.network(
                                  cat.image?.url ??
                                      "https://cdn-icons-png.flaticon.com/512/3075/3075977.png",
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.fastfood),
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),
                            Text(
                              cat.name ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// 🟢 ITEMS
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _filterButton("Veg", "veg"),
                          const SizedBox(width: 8),
                          _filterButton("Non-Veg", "nonveg"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (_, index) {
                            final item = filteredItems[index];

                            Variant? defaultVariant;
                            if (item.variants != null) {
                              for (final v in item.variants!) {
                                if (v.isDefault == true) {
                                  defaultVariant = v;
                                  break;
                                }
                              }
                            }

                            final price = defaultVariant?.price ?? 0;
                            final itemKey = item.id ?? index.toString();
                            double _addonsSum = 0;
                            if (item.addons != null) {
                              final selected =
                                  _selectedAddons[itemKey] ?? <String>{};
                              for (final a in item.addons!) {
                                if (selected.contains(a.id)) {
                                  _addonsSum += (a.price ?? 0).toDouble();
                                }
                              }
                            }
                            final totalPrice = price + _addonsSum;

                            final itemImage =
                                item.image ?? _getItemImage(item, categories);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        itemImage?.url ??
                                            "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe",
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.fastfood,
                                              size: 80,
                                            ),
                                      ),
                                    ),

                                    Text(
                                      item.name ?? "",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description ?? "",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    Row(
                                      children: [
                                        Text(
                                          "₹$totalPrice",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () => _openBottomSheet(
                                            item,
                                            itemImage,
                                            initialSelected:
                                                _selectedAddons[itemKey],
                                          ),
                                          child: _addButton(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _addButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.background],
        ),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: const Text(
        "ADD +",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _openBottomSheet(
    Item item,
    ImageData? url, {
    Set<String>? initialSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddItemSheet(
        item: item,
        url: url,
        initialSelectedAddonIds: initialSelected,
      ),
    );
  }

  Widget _filterButton(String label, String value) {
    final isActive = foodFilter == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => foodFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: isActive
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.background],
                  )
                : null,
            color: isActive ? null : Colors.grey.shade200,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                value == "veg" ? Icons.eco : Icons.local_fire_department,
                size: 16,
                color: isActive ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🧾 BOTTOM SHEET (UNCHANGED UI)
class _AddItemSheet extends StatefulWidget {
  final Item item;
  final ImageData? url;
  final Set<String>? initialSelectedAddonIds;
  const _AddItemSheet({
    required this.item,
    this.url,
    this.initialSelectedAddonIds,
  });

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  int qty = 1;
  Set<String> selectedAddons = {};
  final AuthController menuController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    selectedAddons = {...?widget.initialSelectedAddonIds};
  }

  @override
  Widget build(BuildContext context) {
    final basePrice =
        widget.item.variants
            ?.firstWhereOrNull((v) => v.isDefault == true)
            ?.price ??
        0;

    double addonsSum = 0;
    if (widget.item.addons != null) {
      for (final a in widget.item.addons!) {
        if (selectedAddons.contains(a.id))
          addonsSum += (a.price ?? 0).toDouble();
      }
    }

    final totalPrice = (basePrice + addonsSum) * qty;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 10),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                widget.url?.url ??
                    widget.item.image?.url ??
                    "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.item.description ?? "",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                if (widget.item.addons != null &&
                    widget.item.addons!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 12),
                    child: Wrap(
                      spacing: 6,
                      children: widget.item.addons!.map((addon) {
                        final isSelected = selectedAddons.contains(addon.id);
                        return FilterChip(
                          label: Text("${addon.name} (+₹${addon.price})"),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              if (val)
                                selectedAddons.add(addon.id ?? "");
                              else
                                selectedAddons.remove(addon.id ?? "");
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          backgroundColor: Colors.grey.shade100,
                        );
                      }).toList(),
                    ),
                  ),
                Row(
                  children: [
                    _qtyButton(Icons.remove, () {
                      if (qty > 1) setState(() => qty--);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "$qty",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _qtyButton(Icons.add, () => setState(() => qty++)),
                    const Spacer(),
                    Text(
                      "₹$totalPrice",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () async {
                  await menuController.addToCart(
                    kitchenId: menuController.menuResponse.value!.kitchen!.id!,
                    menuItemId: widget.item.id!,
                    variantLabel:
                        widget.item.variants
                            ?.firstWhereOrNull((v) => v.isDefault == true)
                            ?.label ??
                        "Full",
                    quantity: qty,
                    addonNames:
                        widget.item.addons
                            ?.where((a) => selectedAddons.contains(a.id))
                            .map((a) => a.name!)
                            .toList() ??
                        [],
                    customization: {
                      "spiceLevel": "Medium",
                      "isJain": false,
                      "notes": "Less oil please",
                    },
                  );

                  // close sheet and navigate to cart after add+refresh complete
                  Navigator.pop(context);
                  Get.offAll(() => const RestaurantBottomNav(initialIndex: 2));
                },

                child: Text(
                  "ADD TO CART  •  ₹$totalPrice",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
