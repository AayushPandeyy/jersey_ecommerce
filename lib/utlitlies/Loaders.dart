import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loaders {
  void showOrderPlacedPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottiejson/success.json',
                  height: 150,
                  repeat: false,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order Placed!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => PopScope(
            onPopInvokedWithResult: (pop, res) => false,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              content: Center(
                child: LottieBuilder.asset("assets/lottiejson/loading.json"),
              ),
            ),
          ),
    );
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }
}
