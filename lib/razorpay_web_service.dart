import 'dart:js' as js;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RazorpayWeb {
  static void openPayment({
    required double amount,
    required String email,
    required String name,
    required String contact,
    required Function(String) onSuccess,
    required Function(String) onFailure,
  }) {
    js.context.callMethod('openRazorpay', [amount, email, contact, name]);

    js.context['razorpaySuccess'] = (String paymentId) async {
      print("✅ Payment Success: $paymentId");

      // ✅ Store locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasPaid', true);

      try {
        // ✅ Find registration by email
        final querySnapshot = await FirebaseFirestore.instance
            .collection('registrations')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final docRef = querySnapshot.docs.first.reference;

          // ✅ Update payment status
          await docRef.update({
            'paymentDone': true,
            'paymentId': paymentId,
            'paymentAt': FieldValue.serverTimestamp(),
          });

          print("✅ Registration updated for $email");
        } else {
          print("⚠️ No registration found for $email");
        }
      } catch (e) {
        print("❌ Error updating registration: $e");
      }

      onSuccess(paymentId);
    };

    js.context['razorpayFailed'] = (String message) {
      print("❌ Payment Failed: $message");
      onFailure(message);
    };
  }
}