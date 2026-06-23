import '../machine_models/auth/officer_auth_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Uncomment when firebase dependencies are added

class ApiService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<OfficerAuthResponse> authenticateOfficer(OfficerAuthRequest request) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000)); // Network delay simulation

      /*
      // --- REAL FIREBASE FLUID IMPLEMENTATION WHEN READY ---
      final querySnapshot = await _firestore
          .collection('officer_auths')
          .where('machine_id', isEqualTo: request.machineId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return OfficerAuthResponse(success: false, message: 'No active session found for this machine.');
      }

      final doc = querySnapshot.docs.first;
      final authData = OfficerAuth.fromJson(doc.data());

      // Validate expiration
      if (DateTime.now().isAfter(authData.expiresAt)) {
        await doc.reference.update({'status': 'expired'});
        return OfficerAuthResponse(success: false, message: 'Code has expired.');
      }

      // Check if entered code matches codeHash / random number generated on officer panel
      if (authData.codeHash == request.code) {
        // OVERWRITE to null/used and set machine status to logged
        await doc.reference.update({
          'code_hash': null,          // Clear code
          'status': 'used',          // Transition state
          'used_at': FieldValue.serverTimestamp(),
          'machine_logged_status': 'logged' 
        });

        return OfficerAuthResponse(
          success: true,
          sessionToken: 'fb_session_${doc.id}',
          officerName: 'Officer ID: ${authData.officerId}',
          message: 'Success',
        );
      } else {
        return OfficerAuthResponse(success: false, message: 'Invalid code.');
      }
      */

      // ---- TEMPORARY FIREBASE SIMULATION MOCK ----
      if (request.code == '123456') {
        return OfficerAuthResponse(
          success: true,
          sessionToken: 'firebase_mock_token_123',
          officerName: 'Officer Verified',
          message: 'Success',
        );
      } else {
        return OfficerAuthResponse(
          success: false,
          message: 'Invalid authorization code.',
        );
      }
    } catch (e) {
      return OfficerAuthResponse(
        success: false,
        message: 'Firebase connection exception.',
      );
    }
  }
}