import 'package:flutter/material.dart';

class AuthenticationCodeScreen extends StatelessWidget {
  final String authCode;

  const AuthenticationCodeScreen({super.key, required this.authCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),

          child: Column(
            children: [
              const SizedBox(height: 80),

              Container(
                height: 100,

                width: 100,

                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.lock,

                  size: 50,

                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Voting Machine Code",

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,

                  borderRadius: BorderRadius.circular(25),
                ),

                child: Column(
                  children: [
                    Text(
                      authCode,

                      style: const TextStyle(
                        fontSize: 40,

                        fontWeight: FontWeight.bold,

                        color: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text("Valid for current login session"),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,

                height: 55,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  child: const Text(
                    "BACK",

                    style: TextStyle(color: Colors.white),
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
