import 'dart:js' as js;

class RazorpayWeb {
  static void openPayment({
    required double amount,
    required String email,
    required String name,
    required String contact,
    required Function(String) onSuccess,
    required Function(String) onFailure,
  }) {
    // Register success callback
    js.context.callMethod('openRazorpay', [amount, email, contact, name]);

    // Listen for successful payment
    js.context['razorpaySuccess'] = (String paymentId) {
      print("✅ Payment Success: $paymentId");
      onSuccess(paymentId);
    };

    // Listen for failed payment
    js.context['razorpayFailed'] = (String message) {
      print("❌ Payment Failed: $message");
      onFailure(message);
    };
  }
}