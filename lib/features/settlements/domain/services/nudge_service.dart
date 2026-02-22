import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final nudgeServiceProvider = Provider<NudgeService>((ref) {
  return NudgeService();
});

class NudgeService {
  Future<bool> sendWhatsAppNudge({
    required String phone, // Include country code, e.g., +919876543210
    required String friendName,
    required double amount,
    String? upiId,
  }) async {
    // Strip optional formatting from phone number to be purely digits for wa.me
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    final String amountStr = amount.toStringAsFixed(2);

    String message =
        'Hey $friendName! Quick reminder to settle up our pending *SplitPlan*. You currently owe *₹$amountStr*.';

    if (upiId != null && upiId.isNotEmpty) {
      message += '\nYou can pay me easily via UPI using this ID: $upiId';
    }

    final encodedMessage = Uri.encodeComponent(message);

    // Construct the WhatsApp universal link, which handles intent routing automatically
    // and falls back gracefully to a web page if the app isn't installed.
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$cleanPhone?text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
