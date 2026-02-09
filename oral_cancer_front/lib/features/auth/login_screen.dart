import 'package:flutter/material.dart';
import 'package:oral_cancer_front/features/auth/success_screen.dart';
import 'auth_service.dart';
import '../../core/auth_storage.dart';
import '../../core/role_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final success = await AuthService.login(
      _phoneController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (!success) {
      setState(() => _error = "Invalid phone or password");
      return;
    }
    
    final role = await AuthStorage.getRole() ;
    final name = await AuthStorage.getName() ;
    // Temporary navigation placeholder
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RoleRouter.routeByRole(role!,name!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.health_and_safety,
                    size: 80, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  "Oral Cancer Screening",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Phone
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text("Login"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
