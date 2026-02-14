import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/OrdertrackinController.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/Model.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';

class KitchenSearchScreen extends StatefulWidget {
  const KitchenSearchScreen({super.key});

  @override
  State<KitchenSearchScreen> createState() => _KitchenSearchScreenState();
}

class _KitchenSearchScreenState extends State<KitchenSearchScreen> {
  final OrdertrackinController ctrl = Get.put(OrdertrackinController());

  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController latCtrl = TextEditingController(text: "28.6289");
  final TextEditingController lngCtrl = TextEditingController(text: "77.3649");
  final TextEditingController radiusCtrl = TextEditingController(text: "3000");

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearby();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();
    radiusCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNearby() async {
    final lat = double.tryParse(latCtrl.text.trim()) ?? 28.6289;
    final lng = double.tryParse(lngCtrl.text.trim()) ?? 77.3649;
    final radius = int.tryParse(radiusCtrl.text.trim()) ?? 3000;
    await ctrl.fetchNearbyKitchensByLocation(lat: lat, lng: lng, radius: radius);
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      ctrl.searchKitchensBySociety(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Kitchen Search",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _topFilters(),
            Expanded(
              child: Obx(() {
                final loading = ctrl.isKitchenSearchLoading.value;
                final error = ctrl.kitchenSearchError.value;
                final list = ctrl.searchedKitchens;

                if (loading && list.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.background),
                  );
                }

                if (error.isNotEmpty && list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  );
                }

                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      "No kitchens found",
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadNearby,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _kitchenTile(list[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topFilters() {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: searchCtrl,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search by society name",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        searchCtrl.clear();
                        ctrl.searchKitchensBySociety("");
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _smallField(
                  controller: latCtrl,
                  label: "Lat",
                  inputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _smallField(
                  controller: lngCtrl,
                  label: "Lng",
                  inputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _smallField(
                  controller: radiusCtrl,
                  label: "Radius",
                  inputType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _loadNearby,
              child: const Text(
                "Load Nearby Kitchens",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallField({
    required TextEditingController controller,
    required String label,
    required TextInputType inputType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _kitchenTile(Kitchen item) {
    final name = item.restaurantInfo?.name ?? "Kitchen";
    final society = item.location?.societyName ?? "No society info";
    final cuisines = item.operations?.cuisines ?? <String>[];
    final distance = item.distanceKm?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E9EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            society,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: Colors.black54),
          ),
          if (distance != null) ...[
            const SizedBox(height: 6),
            Text(
              "$distance km away",
              style: const TextStyle(
                color: AppColors.background,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (cuisines.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: cuisines
                  .take(3)
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
