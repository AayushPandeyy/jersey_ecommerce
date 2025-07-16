import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jersey_ecommerce/screens/NavigationScreen.dart';
import 'package:jersey_ecommerce/screens/admin/AdminNavigationScreen.dart';
import 'package:jersey_ecommerce/screens/auth/AuthPage.dart';
import 'package:jersey_ecommerce/service/FirestoreService.dart';

class LoginChecker extends StatelessWidget {
  const LoginChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }

          if (userSnapshot.hasData && userSnapshot.data != null) {
            final userEmail = userSnapshot.data!.email!;
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService().getUserDataByEmail(userEmail),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (asyncSnapshot.hasError) {
                  return const Center(child: Text('Something went wrong!'));
                }

                final userDataList = asyncSnapshot.data;

                if (userDataList != null && userDataList.isNotEmpty) {
                  final userData = userDataList.first;
                  final role = userData['role'];

                  if (role == 'admin') {
                    return const AdminNavigationScreen();
                  } else if (role == 'customer') {
                    return const NavigationScreen();
                  } else {
                    return const Center(child: Text('Unknown role'));
                  }
                } else {
                  return const Center(child: Text('No user data found'));
                }
              },
            );
          }

          // If not logged in, show AuthPage
          return const AuthPage();
        },
      ),
    );
  }
}
