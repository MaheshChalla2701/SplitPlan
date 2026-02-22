import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/notification_service.dart';

part 'fcm_token_service.g.dart';

/// Saves (or updates) the device's FCM token on the authenticated user's
/// Firestore document so the Cloud Function can look it up when sending a
/// push notification.
class FcmTokenService {
  FcmTokenService(this._firestore);

  final FirebaseFirestore _firestore;

  /// Call this once the user is signed in. Saves the current token and
  /// subscribes to future token refreshes.
  Future<void> saveTokenForUser(String uid) async {
    final notificationService = NotificationService.instance;

    // Save current token
    final token = await notificationService.getToken();
    if (token != null) {
      await _persistToken(uid, token);
    }

    // Keep the token up to date if it rotates
    notificationService.onTokenRefresh.listen((newToken) {
      _persistToken(uid, newToken);
    });
  }

  Future<void> _persistToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).update({'fcmToken': token});
  }

  /// Removes the FCM token when the user signs out so they stop receiving
  /// notifications after logout.
  Future<void> clearTokenForUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'fcmToken': null});
  }
}

@riverpod
FcmTokenService fcmTokenService(Ref ref) {
  return FcmTokenService(FirebaseFirestore.instance);
}
