import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Modules/Auth/view/navbar.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';
import 'package:padoshi_kitchen/widgets/CurrentMapfetch.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({
    super.key,
    this.addressId,
    this.initialLabel,
    this.initialAddressLine,
    this.initialSocietyName,
    this.initialIsDefault,
    this.initialLat,
    this.initialLng,
  });

  final String? addressId;
  final String? initialLabel;
  final String? initialAddressLine;
  final String? initialSocietyName;
  final bool? initialIsDefault;
  final double? initialLat;
  final double? initialLng;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController landmarkCtrl = TextEditingController();

  int addressType = 0; // 0 home, 1 work, 2 other
  bool isDefault = false;
  double? selectedLat;
  double? selectedLng;

  final AuthController controller = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    if (widget.initialAddressLine != null) {
      addressCtrl.text = widget.initialAddressLine!;
    }
    if (widget.initialSocietyName != null) {
      landmarkCtrl.text = widget.initialSocietyName!;
    }
    if (widget.initialLabel != null) {
      final label = widget.initialLabel!.toLowerCase();
      if (label == "work") {
        addressType = 1;
      } else if (label == "other") {
        addressType = 2;
      } else {
        addressType = 0;
      }
    }
    if (widget.initialIsDefault != null) {
      isDefault = widget.initialIsDefault!;
    }
    selectedLat = widget.initialLat;
    selectedLng = widget.initialLng;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      /// 🔝 HEADER
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.background],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: const [
                BackButton(color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Add Delivery Address",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🧾 FORM
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  child: Column(
                    children: [
                      _inputField(
                        controller: addressCtrl,
                        label: "Address Line",
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: landmarkCtrl,
                        label: "Society / Landmark (Optional)",
                        icon: Icons.map_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// ✅ DEFAULT ADDRESS
                _card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Set as default",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Switch(
                        value: isDefault,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => isDefault = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// 📍 SELECT LOCATION
                _card(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.my_location,
                        color: AppColors.background,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedLat != null && selectedLng != null
                              ? "Location selected"
                              : "Select location on map",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: _openLocationPicker,
                        child: const Text("Choose"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// 🏷 ADDRESS TYPE
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Save address as",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _typeChip("Home", Icons.home_outlined, 0),
                          const SizedBox(width: 8),
                          _typeChip("Work", Icons.work_outline, 1),
                          const SizedBox(width: 8),
                          _typeChip("Other", Icons.location_city, 2),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),

      /// 💾 SAVE BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _submitAddress,
            child: const Text(
              "Save Address",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔤 INPUT FIELD
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    bool readOnly = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.background),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  String _labelFromType() {
    switch (addressType) {
      case 1:
        return "Work";
      case 2:
        return "Other";
      default:
        return "Home";
    }
  }

  Future<void> _openLocationPicker() async {
    final result =
        await Get.to(() => const DeliveryLocationScreen(returnResult: true));
    if (result is Map) {
      setState(() {
        selectedLat = result["lat"] as double?;
        selectedLng = result["lng"] as double?;
      });
    }
  }

  Future<void> _submitAddress() async {
    if (addressCtrl.text.trim().isEmpty) {
      Get.snackbar("Missing Info", "Please select address");
      return;
    }
    if (selectedLat == null || selectedLng == null) {
      Get.snackbar("Location Required", "Please select location on map");
      return;
    }

    final success = widget.addressId != null
        ? await controller.updateAddress(
            addressId: widget.addressId!,
            label: _labelFromType(),
            addressLine: addressCtrl.text.trim(),
            societyName: landmarkCtrl.text.trim(),
            latitude: selectedLat!,
            longitude: selectedLng!,
            isDefault: isDefault,
          )
        : await controller.addAddress(
            label: _labelFromType(),
            addressLine: addressCtrl.text.trim(),
            societyName: landmarkCtrl.text.trim(),
            latitude: selectedLat!,
            longitude: selectedLng!,
            isDefault: isDefault,
          );

    if (success) {
      Get.offAll(() => const RestaurantBottomNav(initialIndex: 2));
    }
  }

  /// 🏷 ADDRESS TYPE CHIP
  Widget _typeChip(String title, IconData icon, int index) {
    final selected = addressType == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => addressType = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.background : Colors.grey.shade300,
            ),
            color: selected
                ? AppColors.background.withOpacity(0.12)
                : Colors.white,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.background : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.background : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎨 CARD
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
