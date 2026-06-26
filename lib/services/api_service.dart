import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../machine_models/auth/officer_auth_model.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Authenticates an officer by verifying the 6-digit OTP against the
  /// machine document in Firestore:
  ///   collection('system').doc('registry').collection('machines').doc(machineId)
  ///
  /// Expected machine document fields:
  ///   - auth_code            : String  (6-digit random code from officer dashboard)
  ///   - auth_code_expires_at : Timestamp (code expiry time, 30s from generation)
  ///   - officer_name         : String? (display name for the officer)
  ///   - status               : String  (active, inactive, maintenance, voting)
  ///
  /// On success:
  ///   - Consumes the used code (sets auth_code to null)
  ///   - The officer dashboard's Firestore listener detects the null code
  ///     and generates a fresh code immediately.
  ///   - Updates last_heartbeat and machine_logged_status
  Future<OfficerAuthResponse> authenticateOfficer(OfficerAuthRequest request) async {
    try {
      final docRef = _firestore
          .collection('system')
          .doc('registry')
          .collection('machines')
          .doc(request.machineId.toString());

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return OfficerAuthResponse(
          success: false,
          message: 'Machine not found in registry.',
        );
      }

      final data = docSnapshot.data()!;
      final authCode = data['auth_code'] as String?;
      final expiresAt = data['auth_code_expires_at'] != null
          ? (data['auth_code_expires_at'] as Timestamp).toDate()
          : null;

      // No active code present (already consumed or never generated)
      if (authCode == null || authCode.isEmpty) {
        return OfficerAuthResponse(
          success: false,
          message: 'No active authentication code. Wait for the officer to generate a new code.',
        );
      }

      // Check expiration
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        return OfficerAuthResponse(
          success: false,
          message: 'Code has expired. Ask the officer to generate a new code.',
        );
      }

      // Verify code match
      if (authCode == request.code) {
        // Consume the code — officer screen will detect auth_code == null
        // and regenerate a new code immediately via its Firestore listener.
        await docRef.update({
          'auth_code': null,
          'auth_code_expires_at': null,
          'last_heartbeat': FieldValue.serverTimestamp(),
          'status': 'active',
          'machine_logged_status': 'logged',
        });

        return OfficerAuthResponse(
          success: true,
          sessionToken: 'fb_session_${docSnapshot.id}_${DateTime.now().millisecondsSinceEpoch}',
          officerName: data['officer_name'] as String? ?? 'Officer Verified',
          message: 'Authentication successful.',
        );
      }

      // Wrong code
      return OfficerAuthResponse(
        success: false,
        message: 'Invalid authorization code.',
      );
    } catch (e) {
      return OfficerAuthResponse(
        success: false,
        message: 'Firebase connection exception: $e',
      );
    }
  }

  /// Generates a random 6-digit numeric code.
  /// Note: This is kept here for reference, but the officer dashboard
  /// (AuthenticationCodeScreen) is now the primary source of code generation.
  String generateRandomCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
