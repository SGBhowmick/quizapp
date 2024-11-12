import 'package:flutter/material.dart';
import 'package:quizapp/main.dart';
import 'package:quizapp/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Function to handle login logic
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String enteredStudentId = _studentIdController.text;
      String enteredPassword = _passwordController.text;

      // Retrieve stored credentials from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedStudentId = prefs.getString('studentId');
      String? storedPassword = prefs.getString('password');

      if (storedStudentId == null || storedPassword == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No account found. Please sign up first.'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      // Check if entered credentials match stored ones
      if (enteredStudentId == storedStudentId &&
          enteredPassword == storedPassword) {
        // Login successful, navigate to Quiz screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => quizHomePage()), // Adjust path if necessary
        );
      } else {
        // Login failed
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid Student ID or Password'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_sharp,
                  color: Colors.blueAccent,
                  size: 200,
                ),
                // Student ID Text Field
                TextFormField(
                  controller: _studentIdController,
                  decoration: InputDecoration(labelText: 'Student ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your student ID';
                    }
                    return null;
                  },
                ),
                // Password Text Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Login Button
                ElevatedButton(
                  onPressed: _login,
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.indigo[400]),
                  ),
                ),
                SizedBox(height: 20),
                // Sign-up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SignUpScreen()), // Navigate to Sign-Up screen
                        );
                      },
                      child: Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
