import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jersey_ecommerce/screens/NavigationScreen.dart';
import 'package:jersey_ecommerce/service/FirebaseAuthService.dart';
import 'package:jersey_ecommerce/utlitlies/Loaders.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  bool isLogin = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerPhoneController = TextEditingController();

  // Form keys
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> signUp(BuildContext context) async {
    final AuthFirebaseService authService = AuthFirebaseService();
    try {
      Loaders().showLoadingDialog(context);
      print(_registerEmailController.text);
      print(_registerPasswordController.text);
      await authService.signUp(
        _registerEmailController.text,
        _registerPasswordController.text,
        _registerNameController.text,
        _registerPhoneController.text,
      );

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Verification Email Sent"),
              content: const Text(
                "A verification email has been sent. Please verify your email and login to your account.",
              ),
              actions: [
                TextButton(
                  onPressed:
                      () => {
                        Navigator.pop(context),
                        Navigator.pop(context),
                        setState(() {
                          isLogin = true;
                        }),
                      },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (err) {
      print(err.runtimeType);

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Error"),
              content: Text("Error: $err"),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
      throw Exception(err);
    }
  }

  void login(BuildContext context) async {
    final AuthFirebaseService authService = AuthFirebaseService();

    try {
      Loaders().showLoadingDialog(context);

      UserCredential user = await authService.signIn(
        _loginEmailController.text,
        _loginPasswordController.text,
      );

      if (!user.user!.emailVerified) {
        Navigator.pop(context);
        await authService.logout();
        Loaders().showAlertDialog(
          context,
          "Email Verification Required",
          "Your email has not yet been verified. Please verify your email and try again.",
        );
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavigationScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Please try again.';
      }

      Loaders().showAlertDialog(context, "Login Failed", errorMessage);
    } catch (e) {
      print(e);
      Navigator.pop(context);
      Loaders().showAlertDialog(
        context,
        "Login Failed",
        "An unknown error occurred.Please try again",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(32.0),
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo and Title
                          Icon(
                            Icons.sports_soccer,
                            size: 60,
                            color: Color(0xFF667eea),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Jersey Shop',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            isLogin ? 'Welcome back!' : 'Create your account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 32),

                          // Auth Form
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            child:
                                isLogin
                                    ? _buildLoginForm()
                                    : _buildRegisterForm(),
                          ),

                          SizedBox(height: 24),

                          // Toggle Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLogin
                                    ? "Don't have an account? "
                                    : "Already have an account? ",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              GestureDetector(
                                onTap: _toggleAuthMode,
                                child: Text(
                                  isLogin ? 'Sign Up' : 'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFF667eea),
                                    fontWeight: FontWeight.bold,
                                  ),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        key: ValueKey('login'),
        children: [
          _buildTextField(
            controller: _loginEmailController,
            label: 'Email',
            icon: Icons.email,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email is required';
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value!)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _loginPasswordController,
            label: 'Password',
            icon: Icons.lock,
            isPassword: true,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Password is required';
              if (value!.length < 6)
                return 'Password must be at least 6 characters';
              return null;
            },
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                login(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667eea),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        key: ValueKey('register'),
        children: [
          _buildTextField(
            controller: _registerNameController,
            label: 'Full Name',
            icon: Icons.person,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Name is required';
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _registerEmailController,
            label: 'Email',
            icon: Icons.email,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email is required';
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value!)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _registerPhoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Number is required';
              if (value!.length < 10)
                return 'Phone Number must be at least 10 characters';
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _registerPasswordController,
            label: 'Password',
            icon: Icons.lock,
            isPassword: true,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Password is required';
              if (value!.length < 6)
                return 'Password must be at least 6 characters';
              return null;
            },
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                signUp(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF764ba2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF667eea)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
