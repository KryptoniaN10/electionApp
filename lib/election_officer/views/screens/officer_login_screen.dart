import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class OfficerLoginScreen extends StatefulWidget {
  const OfficerLoginScreen({super.key});

  @override
  State<OfficerLoginScreen> createState() => _OfficerLoginScreenState();
}

class _OfficerLoginScreenState extends State<OfficerLoginScreen> {
  bool hidePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Election Officer")),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 60),

                Container(
                  height: 100,
                  width: 100,

                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 50,
                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Election Officer Login",

                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Please login to continue",

                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 40),

                TextField(
                  decoration: InputDecoration(
                    labelText: "Teacher / Officer ID",

                    hintText: "Enter your ID",

                    prefixIcon: const Icon(Icons.person),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  obscureText: hidePassword,

                  decoration: InputDecoration(
                    labelText: "Password",

                    hintText: "Enter Password",

                    prefixIcon: const Icon(Icons.lock),

                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: const Text(
                      "LOGIN",

                      style: TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.bold,

                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,

                  height: 55,

                  child: OutlinedButton(
                    onPressed: () {
                      print("Open Voter Machine");
                    },

                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.deepPurple,

                        width: 2,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),

                    child: const Text(
                      "VOTER MACHINE",

                      style: TextStyle(
                        color: Colors.deepPurple,

                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(Icons.lock, size: 18, color: Colors.grey),

                    SizedBox(width: 10),

                    Text(
                      "Only one device can login",

                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Text(
                  "Secure & Protected",

                  style: TextStyle(
                    color: Colors.deepPurple,

                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Your session is protected",

                  textAlign: TextAlign.center,

                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
