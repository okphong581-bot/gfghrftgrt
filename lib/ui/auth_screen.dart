import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel.dart';
import '../theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  
  bool _isLoginMode = true;
  
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    super.dispose();
  }

  void _submit() async {
    final vm = Provider.of<XocketViewModel>(context, listen: false);
    final user = _usernameController.text.trim();
    final pass = _passwordController.text.trim();
    final display = _displayNameController.text.trim();
    
    if (user.isEmpty || pass.isEmpty) return;

    if (_isLoginMode) {
      final success = await vm.login(user, pass);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sai tài khoản hoặc mật khẩu')));
      }
    } else {
      if (display.isEmpty) return;
      final success = await vm.register(user, pass, display);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tài khoản đã tồn tại')));
      }
    }
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<XocketViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Animation
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.5 + _bgAnimController.value * 0.2),
                    radius: 1.5,
                    colors: [
                      XocketTheme.primaryDark.withOpacity(0.3),
                      XocketTheme.background,
                    ],
                  ),
                ),
              );
            },
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Xocket
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: XocketTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 64, color: XocketTheme.primary),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Xocket",
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: XocketTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLoginMode ? "Chào mừng trở lại!" : "Tạo tài khoản mới để kết nối",
                      style: const TextStyle(fontSize: 16, color: XocketTheme.textSecondary),
                    ),
                    const SizedBox(height: 48),
                    
                    _buildGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isLoginMode)
                            TextField(
                              controller: _displayNameController,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(hintText: "Tên hiển thị (VD: Thuỷ SG)"),
                            ),
                          if (!_isLoginMode) const SizedBox(height: 16),
                          TextField(
                            controller: _usernameController,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(hintText: "Tên đăng nhập (ID)"),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                            decoration: const InputDecoration(hintText: "Mã PIN bí mật"),
                            obscureText: true,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 32),
                          if (vm.isLoading)
                            const Center(child: CircularProgressIndicator(color: XocketTheme.primary))
                          else
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: XocketTheme.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: XocketTheme.primary.withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text(_isLoginMode ? "VÀO XOCKET" : "ĐĂNG KÝ NGAY"),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                      child: Text(
                        _isLoginMode ? "Chưa có tài khoản? Tham gia ngay" : "Đã có tài khoản? Đăng nhập",
                        style: const TextStyle(color: XocketTheme.primary, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
