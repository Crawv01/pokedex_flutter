import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/auth/auth_bloc.dart';

// Retro Pokedex Colors
class _Colors {
  static const Color redDark = Color(0xFFB71C1C);
  static const Color redPrimary = Color(0xFFD32F2F);
  static const Color screenGreen = Color(0xFF9EBC9E);
  static const Color screenDark = Color(0xFF2D4F2D);
  static const Color blueLight = Color(0xFF03A9F4);
  static const Color blackFrame = Color(0xFF1A1A1A);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    final savedPassword = prefs.getString('saved_password');
    final remember = prefs.getBool('remember_me') ?? false;
    
    if (remember && savedUsername != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword ?? '';
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_username', _usernameController.text);
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter username and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Save credentials if remember me is checked
    await _saveCredentials();

    // Simulate login delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Simple validation - accept any non-empty credentials
    // In a real app, you'd validate against a server
    context.read<AuthBloc>().add(
      AuthLoginRequested(username: username, password: password),
    );

    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Colors.redPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPokedexDevice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPokedexDevice() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        color: _Colors.redDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Colors.blackFrame, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section with lights
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Big blue light
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _Colors.blueLight,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: _Colors.blueLight.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Small indicator lights
                _buildSmallLight(Colors.red),
                _buildSmallLight(Colors.yellow),
                _buildSmallLight(Colors.green),
              ],
            ),
          ),

          // Main screen area
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _Colors.screenGreen,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _Colors.blackFrame, width: 4),
            ),
            child: Column(
              children: [
                // Title
                const Text(
                  'POKÉDEX',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: _Colors.screenDark,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TRAINER LOGIN',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: _Colors.screenDark.withOpacity(0.7),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),

                // Username field
                _buildInputField(
                  controller: _usernameController,
                  label: 'USERNAME',
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),

                // Password field
                _buildInputField(
                  controller: _passwordController,
                  label: 'PASSWORD',
                  icon: Icons.lock,
                  obscure: true,
                ),
                const SizedBox(height: 12),

                // Remember me checkbox
                GestureDetector(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A9A7A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _rememberMe ? _Colors.blueLight : Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: _Colors.screenDark, width: 2),
                          ),
                          child: _rememberMe
                              ? const Icon(Icons.check, size: 12, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'REMEMBER ME',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: _Colors.screenDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bottom buttons area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // D-pad decoration
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _Colors.blackFrame,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Login button (A button)
                GestureDetector(
                  onTap: _isLoading ? null : _login,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _Colors.blueLight,
                      border: Border.all(color: _Colors.blackFrame, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'A',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // B button (decorative)
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red[700],
                    border: Border.all(color: _Colors.blackFrame, width: 3),
                  ),
                  child: const Center(
                    child: Text(
                      'B',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom text
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'PRESS A TO LOGIN',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLight(Color color) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: _Colors.blackFrame, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF7A9A7A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _Colors.screenDark, width: 2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          fontFamily: 'monospace',
          color: _Colors.screenDark,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _Colors.screenDark, size: 20),
          hintText: label,
          hintStyle: TextStyle(
            fontFamily: 'monospace',
            color: _Colors.screenDark.withOpacity(0.5),
            fontSize: 12,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
