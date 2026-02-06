import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padoshi_kitchen/Modules/Auth/Controller/Authcontroller.dart';
import 'package:padoshi_kitchen/Modules/Auth/Model/Addressmodel.dart';
import 'package:padoshi_kitchen/Utils/app_color.dart';
import 'package:padoshi_kitchen/widgets/CurrentMapfetch.dart';

class AddressBottomSheet extends StatefulWidget {
  const AddressBottomSheet({super.key});

  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  final AuthController controller = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    controller.fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85, // 🔥 85% screen height
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            /// 🔹 DRAG HANDLE
            const SizedBox(height: 10),
            Container(
              height: 5,
              width: 46,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 14),

            /// 🔝 HEADER (GRADIENT)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.background],
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    "Select Address",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Get.back();
                      Get.to(
                        () => const DeliveryLocationScreen(returnResult: false),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "+ Add New",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 📍 ADDRESS LIST (SCROLLABLE)
            Expanded(
              child: Obx(() {
                if (controller.isAddressLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<Address> addressList = controller.addresses;

                if (addressList.isEmpty) {
                  return const Center(child: Text("No addresses found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addressList.length,
                  itemBuilder: (_, index) {
                    final addr = addressList[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.pop(context, addr);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.background.withOpacity(0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.background.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.background,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (addr.label ?? "").toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _fullAddress(addr),
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () {
                                    final coords =
                                        addr.geoLocation?.coordinates ?? [];
                                    final initialLng =
                                        coords.isNotEmpty ? coords[0] : null;
                                    final initialLat = coords.length > 1
                                        ? coords[1]
                                        : null;

                                    Get.back();
                                    Get.to(
                                      () => DeliveryLocationScreen(
                                        returnResult: false,
                                        addressId: addr.id,
                                        initialLabel: addr.label,
                                        initialAddressLine: addr.addressLine,
                                        initialSocietyName: addr.societyName,
                                        initialIsDefault: addr.isDefault,
                                        initialLat: initialLat,
                                        initialLng: initialLng,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    if (addr.id == null || addr.id!.isEmpty) {
                                      Get.snackbar(
                                        "Error",
                                        "Address ID missing",
                                      );
                                      return;
                                    }

                                    Get.defaultDialog(
                                      title: "Delete Address",
                                      middleText:
                                          "Are you sure you want to delete this address?",
                                      textCancel: "Cancel",
                                      textConfirm: "Delete",
                                      confirmTextColor: Colors.white,
                                      onConfirm: () async {
                                        if (Get.isDialogOpen == true) {
                                          Get.back();
                                        }
                                        final ok = await controller
                                            .deleteAddress(addressId: addr.id!);
                                        if (ok) {
                                          controller.fetchAddresses();
                                        }
                                      },
                                    );
                                  },
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _fullAddress(Address addr) {
    final parts = <String>[addr.addressLine ?? "", addr.societyName ?? ""];
    return parts.where((e) => e.trim().isNotEmpty).join(", ");
  }
}
