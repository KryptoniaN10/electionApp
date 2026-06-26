// authentication_code_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationCodeScreen extends StatefulWidget {
  final String initialAuthCode;
  final int machineId;
  final String officerId;
  final String officerName;

  const AuthenticationCodeScreen({
    super.key,
    required this.initialAuthCode,
    this.machineId = 1,
    this.officerId = 'unknown_officer',
    this.officerName = 'Election Officer',
  });

  @override
  State<AuthenticationCodeScreen> createState() =>
      _AuthenticationCodeScreenState();
}

class _AuthenticationCodeScreenState extends State<AuthenticationCodeScreen>
    with SingleTickerProviderStateMixin {
  late String authCode;
  late Timer _timer;
  int _remainingSeconds = 30;
  final int _maxSeconds = 30;
  late AnimationController _animationController;

  StreamSubscription<DocumentSnapshot>? _codeListener;

  @override
  void initState() {
    super.initState();
    authCode = widget.initialAuthCode;
    _startTimer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _animationController.forward();

    // Write initial code and start listening
    _setupCode(authCode);
  }

  @override
  void dispose() {
    _timer.cancel();
    _codeListener?.cancel();

    // Clean up: delete the current auth code doc when officer leaves this screen
    if (authCode.isNotEmpty) {
      _deleteAuthCodeDoc(authCode);
    }

    _animationController.dispose();
    super.dispose();
  }

  /// Creates the auth code doc and starts listening for consumption.
  Future<void> _setupCode(String code) async {
    await _writeCodeToFirebase(code);
    _listenToAuthCodeDoc(code);
  }

  /// Listens to the specific auth code doc.
  /// When the machine consumes it (status == 'used'), immediately regenerate.
  void _listenToAuthCodeDoc(String code) {
    final docRef = FirebaseFirestore.instance
        .collection('system')
        .doc('registry')
        .collection('machines')
        .doc(widget.machineId.toString())
        .collection('auth_codes')
        .doc(code);

    _codeListener = docRef.snapshots().listen((snapshot) {
      if (!mounted) return;
      if (!snapshot.exists) return; // We deleted it ourselves, ignore

      final data = snapshot.data();
      if (data == null) return;

      final status = data['status'] as String?;
      if (status == 'used') {
        // Machine consumed this code, generate a fresh one immediately
        _generateNewCode();
      }
    });
  }

  void _startTimer() {
    _remainingSeconds = _maxSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
      });
      if (_remainingSeconds == 0) {
        _generateNewCode();
      }
    });
  }

  Future<void> _generateNewCode() async {
    final oldCode = authCode;

    // Cancel old listener and delete old code doc
    await _codeListener?.cancel();
    if (oldCode.isNotEmpty) {
      await _deleteAuthCodeDoc(oldCode);
    }

    // Generate new code
    final random = Random();
    final newCode = (100000 + random.nextInt(900000)).toString();

    await _writeCodeToFirebase(newCode);

    if (mounted) {
      setState(() {
        authCode = newCode;
        _remainingSeconds = _maxSeconds;
      });
      _animationController.reset();
      _animationController.forward();
    }

    _listenToAuthCodeDoc(newCode);
  }

  /// Writes the auth code to a dedicated doc under the machine's auth_codes sub-collection.
  /// Each officer gets their own independent doc — no overwriting, no clashes.
  Future<void> _writeCodeToFirebase(String code) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('system')
          .doc('registry')
          .collection('machines')
          .doc(widget.machineId.toString())
          .collection('auth_codes')
          .doc(code);

      final expiry = DateTime.now().add(const Duration(seconds: 30));

      await docRef.set({
        'code': code,
        'machine_id': widget.machineId,
        'officer_id': widget.officerId,
        'officer_name': widget.officerName,
        'created_at': FieldValue.serverTimestamp(),
        'expires_at': Timestamp.fromDate(expiry),
        'status': 'active',
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sync code: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  /// Deletes an auth code doc from the sub-collection.
  Future<void> _deleteAuthCodeDoc(String code) async {
    try {
      await FirebaseFirestore.instance
          .collection('system')
          .doc('registry')
          .collection('machines')
          .doc(widget.machineId.toString())
          .collection('auth_codes')
          .doc(code)
          .delete();
    } catch (e) {
      // Silently ignore — doc may already be consumed/deleted
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Authenticator",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Machine Icon
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Machine ${widget.machineId}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Officer: ${widget.officerName}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter this code to authenticate",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Code Display with Timer
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Code
                        Text(
                          authCode,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: Colors.deepPurple.shade700,
                            letterSpacing: 6,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Timer Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Timer Circle
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: _remainingSeconds / _maxSeconds,
                                    strokeWidth: 3,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _remainingSeconds < 6
                                          ? Colors.red.shade600
                                          : Colors.deepPurple.shade600,
                                    ),
                                  ),
                                  Text(
                                    '$_remainingSeconds',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _remainingSeconds < 6
                                          ? Colors.red.shade600
                                          : Colors.deepPurple.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "seconds remaining",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _remainingSeconds > 10
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _remainingSeconds > 10 ? "Active" : "Expiring soon",
                            style: TextStyle(
                              color: _remainingSeconds > 10
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Code copied to clipboard"),
                                backgroundColor: Colors.deepPurple,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text(
                            "Copy",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.deepPurple.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Back",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Code refreshes automatically every 30 seconds",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
