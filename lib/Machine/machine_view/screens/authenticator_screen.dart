import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../machine_provider/auth_provider.dart';

class AuthenticatorScreen extends StatefulWidget {
  final int machineId;
  final VoidCallback onSuccess;

  const AuthenticatorScreen({
    super.key,
    required this.machineId,
    required this.onSuccess,
  });

  @override
  State<AuthenticatorScreen> createState() => _AuthenticatorScreenState();
}

class _AuthenticatorScreenState extends State<AuthenticatorScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().resetAuth();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onNum(String n, AuthProvider p) {
    if (p.isAuthenticated || p.isLoading || p.enteredCode.length >= 6) return;
    HapticFeedback.lightImpact();
    p.updateCode(p.enteredCode + n);
  }

  void _onDel(AuthProvider p) {
    if (p.isAuthenticated || p.isLoading || p.enteredCode.isEmpty) return;
    HapticFeedback.lightImpact();
    p.updateCode(p.enteredCode.substring(0, p.enteredCode.length - 1));
  }

  Future<void> _onSubmit(AuthProvider p) async {
    if (p.isAuthenticated || p.isLoading) return;
    HapticFeedback.mediumImpact();

    final success = await p.authenticateOfficer(widget.machineId);
    if (mounted && success) {
      widget.onSuccess();
    }
  }

  void _handleKeyEvent(KeyEvent event, AuthProvider p) {
    if (event is KeyDownEvent) {
      final String? character = event.character;

      if (character != null && RegExp(r'^[0-9]$').hasMatch(character)) {
        _onNum(character, p);
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _onDel(p);
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        if (p.enteredCode.length == 6) {
          _onSubmit(p);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, p, _) {
            return KeyboardListener(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: (event) => _handleKeyEvent(event, p),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.18,
                        child: Container(),
                      ),
                    ),
                  ),
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isShortScreen = constraints.maxHeight < 640;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 250, 250, 250),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.fingerprint_rounded,
                                    color: Color.fromARGB(255, 89, 33, 157),
                                    size: 36,
                                  ),
                                ),
                                SizedBox(height: isShortScreen ? 16 : 32),
                                const Text(
                                  'Officer Authentication',
                                  style: TextStyle(
                                    color: Color(0xFF1A1A2E),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Enter your 6-digit PIN to unlock',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isShortScreen ? 20 : 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(6, (i) {
                                    final filled = i < p.enteredCode.length;
                                    return Container(
                                      width: 44,
                                      height: 52,
                                      margin: const EdgeInsets.symmetric(horizontal: 5),
                                      decoration: BoxDecoration(
                                        color: filled
                                            ? const Color(0xFF6C4AB6).withAlpha(20)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: p.isAuthenticated
                                              ? const Color(0xFF22C55E)
                                              : p.errorMessage != null
                                                  ? const Color(0xFFDC2626)
                                                  : filled
                                                      ? const Color(0xFF6C4AB6)
                                                      : const Color(0xFFE5E7EB),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: p.isAuthenticated
                                            ? const Icon(
                                                Icons.check,
                                                color: Color(0xFF22C55E),
                                                size: 20,
                                              )
                                            : filled
                                                ? Text(
                                                    p.enteredCode[i],
                                                    style: const TextStyle(
                                                      color: Color(0xFF1A1A2E),
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  )
                                                : null,
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 16),
                                if (p.errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626).withAlpha(15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: Color(0xFFDC2626),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            p.errorMessage!,
                                            style: const TextStyle(
                                              color: Color(0xFFDC2626),
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(height: isShortScreen ? 20 : 32),
                                _buildNumpad(p),
                                SizedBox(height: isShortScreen ? 16 : 24),
                                Text(
                                  'Machine ID: ${widget.machineId}',
                                  style: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNumpad(AuthProvider p) {
    final bool disabled = p.isAuthenticated || p.isLoading;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _numBtn('1', disabled, p),
            _numBtn('2', disabled, p),
            _numBtn('3', disabled, p),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _numBtn('4', disabled, p),
            _numBtn('5', disabled, p),
            _numBtn('6', disabled, p),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _numBtn('7', disabled, p),
            _numBtn('8', disabled, p),
            _numBtn('9', disabled, p),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _actionBtn(Icons.backspace_outlined, () => _onDel(p), disabled, false),
            _numBtn('0', disabled, p),
            _actionBtn(
              Icons.arrow_forward,
              () => _onSubmit(p),
              disabled || p.enteredCode.length != 6,
              true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _numBtn(String num, bool disabled, AuthProvider p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : () => _onNum(num, p),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 72,
            height: 56,
            alignment: Alignment.center,
            child: Text(
              num,
              style: TextStyle(
                color: disabled ? const Color(0xFFD1D5DB) : const Color(0xFF1A1A2E),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback? onTap, bool disabled, bool isSubmit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: isSubmit && !disabled ? const Color(0xFF6C4AB6) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 72,
            height: 56,
            alignment: Alignment.center,
            child: context.watch<AuthProvider>().isLoading && isSubmit
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(
                    icon,
                    color: disabled
                        ? const Color(0xFFD1D5DB)
                        : isSubmit
                            ? Colors.white
                            : const Color(0xFF6B7280),
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}
