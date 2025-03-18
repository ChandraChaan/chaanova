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

    // Listen for payment success
    js.context['razorpaySuccess'] = (String paymentId) {
      onSuccess(paymentId);
    };

    // Listen for payment failure
    js.context['razorpayFailed'] = (String message) {
      onFailure(message);
    };
  }
}