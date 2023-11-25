import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rakshak_reet/home.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _policeIdController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  final String apiEndpoint = 'https://rakshakrita0.vercel.app/api/authority';

  Future<void> signUp() async {
    final policeId = _policeIdController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    String authToken = ""; // Declare authToken variable outside if block

    if (policeId.isEmpty || email.isEmpty || password.isEmpty) {
      // Display an error message or toast indicating that all fields are required.
      return;
    }

    try {
      final Map<String, dynamic> requestData = {
        'policeId': policeId,
        'email': email,
        'password': password,
      };

      final response = await http.put(
        Uri.parse(apiEndpoint), // Use your API endpoint here
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        authToken = json.decode(response.body)['authToken'];
        print(authToken);

        _policeIdController.clear();
        _emailController.clear();
        _passwordController.clear();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', authToken);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.075,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.sizeOf(context).height * 0.04,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.08,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: _policeIdController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Police ID",
                      labelText: "Police ID",
                      labelStyle: TextStyle(
                        color: Colors.amber.shade700,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.08,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Invalid email address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Email",
                      labelText: "Email",
                      labelStyle: TextStyle(
                        color: Colors.amber.shade700,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.08,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      hintText: "Password",
                      labelText: "Password",
                      labelStyle: TextStyle(
                        color: Colors.amber.shade700,
                      ),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.amber.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.055,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.amber.shade700),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    )),
                  ),
                  onPressed: () {
                    signUp();
                  },
                  child: Text("Sign Up"),
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.05,
              ),
              Container(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(color: Colors.amber.shade700),
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
