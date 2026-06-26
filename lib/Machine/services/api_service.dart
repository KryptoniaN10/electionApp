import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../machine_models/auth/officer_auth_model.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Authenticates a machine by verifying the 6-digit OTP against the
  /// officer's auth code doc in the sub-collection:
  ///   system/registry/machines/{machineId}/auth_codes/{code}
  ///
  /// Each officer generates their own independent code — no overwriting, no clashes.
  ///
  /// On success:
  ///   - Consumes the code (sets status to 'used')
  ///   - The officer screen's listener detects the 'used' status
  ///     and instantly generates a fresh code.
  ///   - Updates machine heartbeat and logged status.
  Future<OfficerAuthResponse> authenticateOfficer(OfficerAuthRequest request) async {
    try {
      final codeDocRef = _firestore
          .collection('system')
          .doc('registry')
          .collection('machines')
          .doc(request.machineId.toString())
          .collection('auth_codes')
          .doc(request.code);

      final codeSnapshot = await codeDocRef.get();

      if (!codeSnapshot.exists) {
        return OfficerAuthResponse(
          success: false,
          message: 'Invalid code. No active authentication session found.',
        );
      }

      final data = codeSnapshot.data()!;
      final status = data['status'] as String?;
      final expiresAt = data['expires_at'] != null
          ? (data['expires_at'] as Timestamp).toDate()
          : null;

      // Code already consumed by another machine or expired
      if (status != 'active') {
        return OfficerAuthResponse(
          success: false,
          message: 'Code has already been used. Ask the officer for a new code.',
        );
      }

      // Check expiration (30 seconds from generation)
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        return OfficerAuthResponse(
          success: false,
          message: 'Code has expired. Ask the officer to generate a new code.',
        );
      }

      // Valid code — consume it and update machine status
      await codeDocRef.update({
        'status': 'used',
        'used_at': FieldValue.serverTimestamp(),
      });

      // Update machine doc for heartbeat and logged status
      final machineDocRef = _firestore
          .collection('system')
          .doc('registry')
          .collection('machines')
          .doc(request.machineId.toString());

      await machineDocRef.set({
        'machine_id': request.machineId,
        'last_heartbeat': FieldValue.serverTimestamp(),
        'status': 'active',
        'machine_logged_status': 'logged',
      }, SetOptions(merge: true));

      return OfficerAuthResponse(
        success: true,
        sessionToken: 'fb_session_${request.machineId}_${request.code}_${DateTime.now().millisecondsSinceEpoch}',
        officerName: data['officer_name'] as String? ?? 'Officer Verified',
        message: 'Authentication successful.',
      );
    } catch (e) {
      return OfficerAuthResponse(
        success: false,
        message: 'Firebase connection exception: $e',
      );
    }
  }

  /// Generates a random 6-digit numeric code.
  String generateRandomCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
