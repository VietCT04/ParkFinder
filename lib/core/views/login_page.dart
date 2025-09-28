import 'package:flutter/material.dart';
import 'package:park_finder/core/controllers/auth_controller.dart';
import 'package:park_finder/core/views/sign_up_page.dart';
import 'package:park_finder/core/views/home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthController _authController = AuthController();

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 3. if(email field empty)
    if (email.isEmpty) {
      _showMessage("Please enter your email and password!");
      return;
    }

    // 5. if(email field is of wrong type)
    if (!email.contains('@')) {
      _showMessage("Please include an '@' at the email address.");
      return;
    }

    // 7. if(password field empty)
    if (password.isEmpty) {
      _showMessage("Please enter your email and password!");
      return;
    }

    // 9. if(password length < 6)
    if (password.length < 6) {
      _showMessage("Password must be at least 6 characters long!");
      return;
    }

    // 11. authentication
    final user = await _authController.signIn(email, password);

    // 12. if(authentication successful)
    if (user != null) {
      // 15. success
      _showMessage("Log in successfully");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // 13. invalid credentials
      _showMessage("Invalid login credentials");
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('Assets/ParkFinderLogo.png', width: 200, height: 200),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF009b50),
                ),
              ),
              const SizedBox(height: 30),

              // Email
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // Password
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed:
                          () => setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          }),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Login button
              GestureDetector(
                onTap: _signIn,
                child: Container(
                  width: 300,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF009b50),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUp()),
                  );
                },
                child: const Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Color(0xFF009b50),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
