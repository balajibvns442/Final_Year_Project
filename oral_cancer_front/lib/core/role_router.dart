import 'package:flutter/material.dart';
import 'package:oral_cancer_front/features/technician/technician_home_scren.dart';
import '../features/doctor/doctor_home.dart';

class RoleRouter {
  static Widget routeByRole(String role, String name)  {

    print("routing to :" + role) ;
    switch (role) {
      case 'TECHNICIAN':
        return TechnicianHomeScreen(name: name);
        // return TechnicianHome() ;
      case 'DOCTOR':
        return DoctorHome(name: name,);
      default:
        return const Scaffold(
          body: Center(child: Text("Unknown role")),
        );
    }
  }
}
