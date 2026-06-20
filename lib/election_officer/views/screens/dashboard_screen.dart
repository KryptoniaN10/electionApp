import 'package:flutter/material.dart';
import 'authentication_code_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final String authCode;

  @override
  void initState() {
    super.initState();

    authCode = generateCode();
  }

  String generateCode() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return (now % 1000000).toString().padLeft(6, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),

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
                  "Election Dashboard",

                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Manage student approvals",

                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,

                          borderRadius: BorderRadius.circular(25),
                        ),

                        child: const Column(
                          children: [
                            Text(
                              "15",

                              style: TextStyle(
                                fontSize: 32,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 10),

                            Text("Students Voted"),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade100,

                          borderRadius: BorderRadius.circular(25),
                        ),

                        child: const Column(
                          children: [
                            Text(
                              "20",

                              style: TextStyle(
                                fontSize: 32,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 10),

                            Text("Remaining"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Authentication Code
                SizedBox(
                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                              AuthenticationCodeScreen(authCode: authCode),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),

                    child: const Text(
                      "VIEW VOTING MACHINE CODE",

                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const SizedBox(height: 40),

                const Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    "Approve Student",

                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    labelText: "Search Admission Number",

                    hintText: "Type or search student",

                    prefixIcon: const Icon(Icons.search),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Voting machine unlocked"),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),

                    child: const Text(
                      "APPROVE",

                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    "Recent Activity",

                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,

                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text("2025001 • Approved"),

                      SizedBox(height: 10),

                      Text("2025002 • Voting"),

                      SizedBox(height: 10),

                      Text("2025003 • Completed"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
