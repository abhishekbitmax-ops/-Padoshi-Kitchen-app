import 'package:flutter/material.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController landmarkCtrl = TextEditingController();

  int addressType = 0; // 0 home, 1 work, 2 other

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
                        controller: nameCtrl,
                        label: "Full Name",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: phoneCtrl,
                        label: "Phone Number",
                        icon: Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: addressCtrl,
                        label: "Complete Address",
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: landmarkCtrl,
                        label: "Landmark (Optional)",
                        icon: Icons.map_outlined,
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
            onPressed: () {
              // TODO: save address logic
              Navigator.pop(context);
            },
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.background),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
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
