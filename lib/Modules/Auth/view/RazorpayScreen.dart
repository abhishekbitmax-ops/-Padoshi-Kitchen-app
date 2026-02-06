import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayScreen extends StatefulWidget {
  const RazorpayScreen({
    super.key,
    required this.amount,
    this.orderData,
  });

  final int amount;
  final Map<String, dynamic>? orderData;

  static const String razorpayKey = "rzp_test_RqyfR6ogB6XV65";
  static const String razorpaySecret = "UZLvGr97IaOO32u74CWueKDc";

  @override
  State<RazorpayScreen> createState() => _RazorpayScreenState();
}

class _RazorpayScreenState extends State<RazorpayScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Auto-open Razorpay checkout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCheckout();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openCheckout() {
    final options = {
      'key': RazorpayScreen.razorpayKey,
      'amount': widget.amount * 100, // in paise
      'name': 'Padoshi Kitchen',
      'description': 'Order Payment',
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#6C63FF'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar("Payment Error", "Unable to open Razorpay");
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    Get.snackbar("Payment सफल", "Payment ID: ${response.paymentId}");
    Navigator.pop(context, true);
  }

  void _handleError(PaymentFailureResponse response) {
    Get.snackbar("Payment Failed", response.message ?? "Payment cancelled");
    Navigator.pop(context, false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar("External Wallet", response.walletName ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Razorpay Payment")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Proceed to Pay",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Amount: ₹${widget.amount}"),
            const SizedBox(height: 8),
            const Text(
              "Razorpay checkout should open automatically.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (widget.orderData != null) ...[
              const Text(
                "Order Response",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(widget.orderData.toString()),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _openCheckout,
                child: const Text(
                  "Pay Now",
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
    );
  }
}
