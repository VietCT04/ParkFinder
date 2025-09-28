import 'package:flutter/material.dart';
import 'package:park_finder/core/controllers/auth_controller.dart';
import 'login_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isPasswordVisible = true;

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Use AuthController instead of AuthService in the UI
  final AuthController _authController = AuthController();

  Future<void> _register() async {
    // Gather input
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 1. Name required
    if (name.isEmpty) {
      _showMessage("Please enter your full name");
      return;
    }

    // 2. Email required
    if (email.isEmpty) {
      _showMessage("Please enter your email address");
      return;
    }
    // 3. Email format
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage("Please enter a valid email address");
      return;
    }

    // 4. Phone required
    if (phone.isEmpty) {
      _showMessage("Please enter your phone number");
      return;
    }
    // 5. Phone format (digits only, length 8–15)
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 8 || digitsOnly.length > 15) {
      _showMessage("Please enter a valid phone number");
      return;
    }

    // 6. Password required
    if (password.isEmpty) {
      _showMessage("Please enter your password");
      return;
    }
    // 7. Password length
    if (password.length < 6) {
      _showMessage("Password must be at least 6 characters long");
      return;
    }

    // 8. Confirm password required
    if (confirmPassword.isEmpty) {
      _showMessage("Please confirm your password");
      return;
    }
    // 9. Password match
    if (password != confirmPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    // 10. All validations passed → call controller
    final user = await _authController.registerUser(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (user != null) {
      // Registration success
      _showMessage("Registration successful!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // Backend or mismatch error
      _showMessage("Error during registration");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          // To prevent overflow
          child: Column(
            children: [
              Image.asset('Assets/ParkFinderLogo.png', width: 200, height: 200),
              const Text(
                "Let's create your account",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF009b50),
                ),
              ),
              const SizedBox(height: 30),

              Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name field
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _nameController,
                        textAlign: TextAlign.justify,
                        decoration: InputDecoration(
                          labelText: "Name",
                          hintText: "Enter your Name",
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFC0C0C0),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Email field
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _emailController,
                        textAlign: TextAlign.justify,
                        decoration: InputDecoration(
                          hintText: "Enter your Email",
                          labelText: "Email",
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFC0C0C0),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    // Phone Number field
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: "Enter your phone number",
                          labelText: "Phone number",
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFC0C0C0),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Password field
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Enter your Password",
                          labelText: "Password",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFC0C0C0),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Confirm Password field
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Re-Enter your Password",
                          labelText: "Confirm Password",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFC0C0C0),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Register button
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _register,
                      child: Container(
                        width: 300,
                        height: 60,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF009b50),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  "Have an account?",
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
