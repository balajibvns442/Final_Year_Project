import 'package:flutter/material.dart';
import 'core/auth_storage.dart';
import 'core/role_router.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const OralCancerApp());
}

class OralCancerApp extends StatelessWidget {
  const OralCancerApp({super.key});

  Future<Widget> _getStartScreen() async {
    final token = await AuthStorage.getToken();
    final role = await AuthStorage.getRole();
    final name = await AuthStorage.getName();

    if (token != null && role != null && name !=null) {
      return RoleRouter.routeByRole(role,name);
    }
    await AuthStorage.clear();
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oral Cancer Screening',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: FutureBuilder(
        future: _getStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          return snapshot.data!;
        },
      ),
    );
  }
}
