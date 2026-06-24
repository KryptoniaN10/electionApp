import 'package:electionapp/election_officer/views/screens/officer_login_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<String> _menuItems = [
    "Dashboard",
    "Students",
    "Candidates",
    "Election Officers",
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard,
    Icons.group,
    Icons.how_to_vote,
    Icons.admin_panel_settings,
  ];

  @override
  Widget build(BuildContext context) {
    // Define breakpoints for responsiveness
    final bool isMobile = MediaQuery.sizeOf(context).width < 850;

    return Scaffold(
      // On mobile, show an Appbar
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Colors.white,
              title: Text(
                _menuItems[_selectedIndex],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 0,
            )
          : null,
      // On mobile, the sidebar becomes a Drawer
      drawer: isMobile ? Drawer(child: _buildSidebar(isMobile: true)) : null,
      body: isMobile
          ? _buildMainContent(isMobile)
          : Row(
              children: [
                // ==================== SIDEBAR ====================
                _buildSidebar(isMobile: false),

                // ==================== MAIN CONTENT ====================
                Expanded(
                  child: _buildMainContent(isMobile),
                ),
              ],
            ),
    );
  }
//Sidebar to show the different tabs
  Widget _buildSidebar({required bool isMobile}) {
    return Container(
      // Fixed width on desktop, dynamic width in Drawer
      width: isMobile ? null : 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(2, 0))
        ],
      ),
      child: Column(
        children: [
          // Logo / Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 89, 23, 101), Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Icon(Icons.how_to_vote, size: 42, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    "Admin",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return ListTile(
                  leading: Icon(
                    _menuIcons[index],
                    color: isSelected ? const Color(0xFF6B46C1) : Colors.grey[700],
                  ),
                  title: Text(
                    _menuItems[index],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF6B46C1) : Colors.black87,
                    ),
                  ),
                  selected: isSelected,
                  tileColor: Colors.transparent,
                  selectedTileColor: const Color(0xFF6B46C1).withAlpha(20),
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    // Close the drawer automatically on mobile after selection
                    if (isMobile) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
          
          // Bottom User Info
          const Divider(),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF6B46C1),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: const Text("Admin User"),
            trailing: IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              //go back to login page by signout firebase Auth
              onPressed: () {
                //TO-DO:do the firebase auth signout
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => OfficerLoginScreen(),), ((route) => false));
              },
            ),
          ),
          const SafeArea(top: false, child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    return Column(
      children: [
        // Top Bar (Hidden on mobile since AppBar handles it)
        if (!isMobile)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Row(
              children: [
                Text(
                  _menuItems[_selectedIndex],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 148, 64, 196),
                  ),
                ),
                const Spacer(),
                // Search (Flexible width to prevent overflow on medium screens)
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: (_selectedIndex != 0)? TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ):null,
                  ),
                ),
              ],
            ),
          ),

        // Main Content Area
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF8F6FF), // Light purple tint
            padding: EdgeInsets.all(isMobile ? 16 : 32), // Adaptive padding
            child: SingleChildScrollView(
              child: _buildCurrentScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildStudentsScreen();
      case 2:
        return _buildCandidatesScreen();
      case 3:
        return _buildOfficersScreen();
      default:
        return const Center(child: Text("Coming Soon..."));
    }
  }

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Overview",
          style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        
        LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            int crossAxisCount = width < 600 ? 2 : (width < 1000 ? 4 : 8);
            double spacing = 16;
            double cardWidth = (width - (crossAxisCount - 1) * spacing) / crossAxisCount;
            double aspectRatio=1.1;
            double cardHeight = cardWidth*aspectRatio;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _buildStatCard("Total Students", "1248", Icons.group, const Color(0xFF6B46C1), cardWidth,cardHeight),
                _buildStatCard("Active Elections", "4", Icons.event, const Color(0xFF6B46C1), cardWidth,cardHeight),
                _buildStatCard("Candidates", "28", Icons.how_to_vote, const Color(0xFF6B46C1), cardWidth,cardHeight),
                _buildStatCard("Officers", "12", Icons.admin_panel_settings, const Color(0xFF6B46C1), cardWidth,cardHeight),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, double width,double height) {
    return SizedBox(
      height: height,
      width: width,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 16,
          children: [
            const Text(
              "Students Data",
              style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file, color: Colors.purpleAccent),
                label: const Text("Import CSV / Excel", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onPressed: () => _showImportDialog(context), // <--- ADDED ACTION HERE
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: const Text("Students Table will go here (Use your models)"),
        ),
      ],
    );
  }

  Widget _buildCandidatesScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 16,
          children: [
            const Text(
              "Candidates & Positions",
              style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.purpleAccent),
                label: const Text("Add Candidate", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onPressed: () => _showAddCandidateDialog(context), // <--- ADDED ACTION HERE
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: const Text("Candidates table will go here"),
        ),
      ],
    );
  }

  Widget _buildOfficersScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Officers List",
          style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.person_add, color: Colors.purpleAccent),
          label: const Text("Assign Officer Role", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B46C1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          onPressed: () => _showAssignOfficerDialog(context), // <--- ADDED ACTION HERE
        ),
      ],
    );
  }

  // ==================== DIALOG BOX METHODS ====================

  void _showImportDialog(BuildContext context) {
    String? selectedFileName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // StatefulBuilder allows the dialog to update its own state
        // independently when a file is selected.
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Import Students"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select a CSV or Excel file from your device:"),
                  const SizedBox(height: 16),
                  
                  // Browse Button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.folder_open),
                    label: const Text("Browse Files"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B46C1),
                      side: const BorderSide(color: Color(0xFF6B46C1)),
                    ),
                    onPressed: () async {
                      // Open device file explorer
                      FilePickerResult? result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['csv', 'xls', 'xlsx'],
                      );

                      if (result != null) {
                        setState(() {
                          selectedFileName = result.files.single.name;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Display selected file name
                  if (selectedFileName != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedFileName!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text(
                      "No file selected",
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  // Disable the button if no file is selected
                  onPressed: selectedFileName == null
                      ? null
                      : () {
                          // TODO: Handle the actual file import logic
                          // Access the file bytes via result.files.single.bytes (Web) 
                          // or result.files.single.path (Mobile/Desktop)
                          Navigator.of(context).pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text("Import", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCandidateDialog(BuildContext context) {
    // Local dialog state for the isVerified switch
    bool isVerified = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Candidate"),
              // Fields below map to elections/{electionId}/candidates/{candidateId}
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Student ID",
                        helperText: "Links this candidate to an existing student (userId)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Position",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.how_to_vote_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Bio",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Verified"),
                      subtitle: const Text("Mark candidate as verified/eligible"),
                      value: isVerified,
                      activeThumbColor: const Color(0xFF6B46C1),
                      onChanged: (value) => setState(() => isVerified = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Handle adding candidate logic
                    // Write to elections/{electionId}/candidates: userId, position, bio, isVerified
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B46C1)),
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAssignOfficerDialog(BuildContext context) {
    // Local dialog state for the role dropdown and isActive switch
    String selectedRole = 'officer';
    bool isActive = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Assign Election Officer"),
              // Fields below map to users/{userId}
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: "First Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'officer', child: Text("Officer")),
                        DropdownMenuItem(value: 'admin', child: Text("Admin")),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => selectedRole = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Active"),
                      subtitle: const Text("Officer account is active"),
                      value: isActive,
                      activeThumbColor: const Color(0xFF6B46C1),
                      onChanged: (value) => setState(() => isActive = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Handle assigning officer logic
                    // Write to users/{userId}: firstName, lastName, email, role, isActive
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B46C1)),
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}







// import 'package:electionapp/election_officer/views/screens/officer_login_screen.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';

// class AdminDashboard extends StatefulWidget {
//   const AdminDashboard({super.key});

//   @override
//   State<AdminDashboard> createState() => AdminDashboardState();
// }

// class AdminDashboardState extends State<AdminDashboard> {
//   int _selectedIndex = 0;

//   final List<String> _menuItems = [
//     "Dashboard",
//     "Students",
//     "Candidates",
//     "Election Officers",
//   ];

//   final List<IconData> _menuIcons = [
//     Icons.dashboard_rounded,
//     Icons.people_rounded,
//     Icons.how_to_vote_rounded,
//     Icons.admin_panel_settings_rounded,
//   ];

//   // Sample data for dashboard
//   final List<Map<String, dynamic>> _recentActivities = [
//     {'title': 'Student John Doe registered', 'time': '2 min ago', 'icon': Icons.person_add},
//     {'title': 'New candidate added: Jane Smith', 'time': '15 min ago', 'icon': Icons.how_to_vote},
//     {'title': 'Election 2026 results published', 'time': '1 hour ago', 'icon': Icons.assessment},
//     {'title': 'Officer Michael Brown assigned', 'time': '3 hours ago', 'icon': Icons.admin_panel_settings},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final bool isMobile = MediaQuery.sizeOf(context).width < 850;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F6FF),
//       appBar: isMobile
//           ? AppBar(
//               backgroundColor: Colors.white,
//               foregroundColor: Colors.deepPurple,
//               elevation: 0,
//               title: Text(
//                 _menuItems[_selectedIndex],
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Colors.deepPurple,
//                 ),
//               ),
//               leading: Builder(
//                 builder: (context) => IconButton(
//                   icon: const Icon(Icons.menu_rounded),
//                   onPressed: () => Scaffold.of(context).openDrawer(),
//                 ),
//               ),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.notifications_none_rounded),
//                   onPressed: () {},
//                 ),
//                 const CircleAvatar(
//                   radius: 16,
//                   backgroundColor: Colors.deepPurple,
//                   child: Icon(Icons.person, size: 18, color: Colors.white),
//                 ),
//                 const SizedBox(width: 8),
//               ],
//             )
//           : null,
//       drawer: isMobile ? Drawer(child: _buildSidebar(isMobile: true)) : null,
//       body: isMobile
//           ? _buildMainContent(isMobile)
//           : Row(
//               children: [
//                 _buildSidebar(isMobile: false),
//                 Expanded(
//                   child: _buildMainContent(isMobile),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildSidebar({required bool isMobile}) {
//     return Container(
//       width: isMobile ? null : 280,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x1A6B46C1),
//             blurRadius: 20,
//             offset: Offset(4, 0),
//           )
//         ],
//       ),
//       child: Column(
//         children: [
//           // Modern Header
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.deepPurple.shade700,
//                   Colors.deepPurple.shade500,
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: SafeArea(
//               bottom: false,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: const Icon(
//                           Icons.how_to_vote_rounded,
//                           size: 28,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//                       const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Election Admin",
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Text(
//                             "Dashboard Panel",
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.white70,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Menu Items with better styling
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               itemCount: _menuItems.length,
//               itemBuilder: (context, index) {
//                 final isSelected = _selectedIndex == index;
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 4),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: isSelected 
//                         ? Colors.deepPurple.withOpacity(0.08)
//                         : Colors.transparent,
//                   ),
//                   child: ListTile(
//                     leading: Icon(
//                       _menuIcons[index],
//                       color: isSelected ? Colors.deepPurple : Colors.grey[600],
//                       size: 24,
//                     ),
//                     title: Text(
//                       _menuItems[index],
//                       style: TextStyle(
//                         fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                         color: isSelected ? Colors.deepPurple : Colors.grey[800],
//                         fontSize: 15,
//                       ),
//                     ),
//                     trailing: isSelected
//                         ? Container(
//                             width: 4,
//                             height: 24,
//                             decoration: BoxDecoration(
//                               color: Colors.deepPurple,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           )
//                         : null,
//                     onTap: () {
//                       setState(() => _selectedIndex = index);
//                       if (isMobile) Navigator.pop(context);
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),

//           // User Profile Section
//           Container(
//             padding: const EdgeInsets.all(16),
//             margin: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.grey[200]!),
//             ),
//             child: Row(
//               children: [
//                 const CircleAvatar(
//                   radius: 24,
//                   backgroundColor: Colors.deepPurple,
//                   child: Icon(Icons.person, color: Colors.white, size: 28),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Admin User",
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Text(
//                         "admin@election.com",
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
//                   onPressed: () {
//                     Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(builder: (context) => const OfficerLoginScreen()),
//                       (route) => false,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainContent(bool isMobile) {
//     return Column(
//       children: [
//         // Top Bar (Desktop)
//         if (!isMobile)
//           Container(
//             height: 80,
//             padding: const EdgeInsets.symmetric(horizontal: 32),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Color(0x1A6B46C1),
//                   blurRadius: 10,
//                   offset: Offset(0, 2),
//                 )
//               ],
//             ),
//             child: Row(
//               children: [
//                 Text(
//                   _menuItems[_selectedIndex],
//                   style: const TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: (_selectedIndex != 0)
//                       ? SizedBox(
//                           width: 280,
//                           height: 44,
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: "Search...",
//                               hintStyle: TextStyle(color: Colors.grey[500]),
//                               prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500], size: 20),
//                               border: InputBorder.none,
//                               contentPadding: const EdgeInsets.symmetric(vertical: 8),
//                             ),
//                           ),
//                         )
//                       : null,
//                 ),
//                 const SizedBox(width: 16),
//                 IconButton(
//                   icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
//                   onPressed: () {},
//                 ),
//                 const CircleAvatar(
//                   radius: 20,
//                   backgroundColor: Colors.deepPurple,
//                   child: Icon(Icons.person, color: Colors.white, size: 22),
//                 ),
//                 const SizedBox(width: 8),
//               ],
//             ),
//           ),

//         // Main Content
//         Expanded(
//           child: Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(isMobile ? 16 : 24),
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: _buildCurrentScreen(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCurrentScreen() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildDashboard();
//       case 1:
//         return _buildStudentsScreen();
//       case 2:
//         return _buildCandidatesScreen();
//       case 3:
//         return _buildOfficersScreen();
//       default:
//         return const Center(child: Text("Coming Soon..."));
//     }
//   }

//   Widget _buildDashboard() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Welcome Section
//         Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Colors.deepPurple.shade700,
//                 Colors.deepPurple.shade500,
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.deepPurple.withOpacity(0.3),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Welcome back, Admin!",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "Here's what's happening with your elections today",
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: const Icon(
//                   Icons.celebration_rounded,
//                   color: Colors.white,
//                   size: 36,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 24),

//         // Stats Cards
//         LayoutBuilder(
//           builder: (context, constraints) {
//             double width = constraints.maxWidth;
//             int crossAxisCount = width < 600 ? 2 : (width < 1000 ? 2 : 4);
//             double spacing = 16;
//             double cardWidth = (width - (crossAxisCount - 1) * spacing) / crossAxisCount;
//             double cardHeight = cardWidth * 0.7;

//             return Wrap(
//               spacing: spacing,
//               runSpacing: spacing,
//               children: [
//                 _buildStatCard(
//                   "Total Students",
//                   "1,248",
//                   Icons.people_rounded,
//                   const Color(0xFF6B46C1),
//                   cardWidth,
//                   cardHeight,
//                   "+12%",
//                 ),
//                 _buildStatCard(
//                   "Active Elections",
//                   "4",
//                   Icons.event_rounded,
//                   const Color(0xFFE74C3C),
//                   cardWidth,
//                   cardHeight,
//                   "2 ongoing",
//                 ),
//                 _buildStatCard(
//                   "Candidates",
//                   "28",
//                   Icons.how_to_vote_rounded,
//                   const Color(0xFF27AE60),
//                   cardWidth,
//                   cardHeight,
//                   "+5 new",
//                 ),
//                 _buildStatCard(
//                   "Officers",
//                   "12",
//                   Icons.admin_panel_settings_rounded,
//                   const Color(0xFFF39C12),
//                   cardWidth,
//                   cardHeight,
//                   "8 active",
//                 ),
//               ],
//             );
//           },
//         ),
//         const SizedBox(height: 24),

//         // Recent Activity
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 20,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Recent Activity",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text(
//                       "View All",
//                       style: TextStyle(
//                         color: Colors.deepPurple,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               ..._recentActivities.map((activity) => Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(color: Colors.grey[200]!),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.deepPurple.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         activity['icon'],
//                         color: Colors.deepPurple,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             activity['title'],
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14,
//                             ),
//                           ),
//                           Text(
//                             activity['time'],
//                             style: TextStyle(
//                               color: Colors.grey[500],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(Icons.more_vert_rounded, color: Colors.grey[400], size: 20),
//                   ],
//                 ),
//               )),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color, double width, double height, String subtitle) {
//     return SizedBox(
//       height: height,
//       width: width,
//       child: Card(
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         color: Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(icon, size: 28, color: color),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       subtitle,
//                       style: TextStyle(
//                         color: Colors.green[700],
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStudentsScreen() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header Section
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Student Management",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     "Manage all registered students",
//                     style: TextStyle(color: Colors.grey, fontSize: 14),
//                   ),
//                 ],
//               ),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 20),
//                 label: const Text(
//                   "Import CSV",
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 onPressed: () => _showImportDialog(context),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),

//         // Table Section
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Table Header
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.deepPurple.withOpacity(0.04),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Row(
//                   children: [
//                     Expanded(flex: 2, child: Text("Student ID", style: TextStyle(fontWeight: FontWeight.w600))),
//                     Expanded(flex: 3, child: Text("Name", style: TextStyle(fontWeight: FontWeight.w600))),
//                     Expanded(flex: 2, child: Text("Email", style: TextStyle(fontWeight: FontWeight.w600))),
//                     Expanded(flex: 1, child: Text("Status", style: TextStyle(fontWeight: FontWeight.w600))),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Placeholder data
//               ...List.generate(5, (index) => Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(color: Colors.grey[100]!),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(flex: 2, child: Text("STU${1000 + index}", style: const TextStyle(fontWeight: FontWeight.w500))),
//                     Expanded(flex: 3, child: Text("Student ${index + 1}")),
//                     Expanded(flex: 2, child: Text("student$index@email.com")),
//                     Expanded(flex: 1, child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Text("Active", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
//                     )),
//                   ],
//                 ),
//               )),
//               const SizedBox(height: 12),
//               // Pagination
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Showing 1-5 of 1,248 students",
//                     style: TextStyle(color: Colors.grey[600], fontSize: 13),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.chevron_left_rounded),
//                         onPressed: () {},
//                         style: IconButton.styleFrom(
//                           backgroundColor: Colors.grey[100],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.deepPurple,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Text("1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: const Icon(Icons.chevron_right_rounded),
//                         onPressed: () {},
//                         style: IconButton.styleFrom(
//                           backgroundColor: Colors.grey[100],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCandidatesScreen() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Candidates & Positions",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     "Manage election candidates",
//                     style: TextStyle(color: Colors.grey, fontSize: 14),
//                   ),
//                 ],
//               ),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
//                 label: const Text(
//                   "Add Candidate",
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 onPressed: () => _showAddCandidateDialog(context),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: const Text("Candidates table will go here"),
//         ),
//       ],
//     );
//   }

//   Widget _buildOfficersScreen() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Election Officers",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     "Manage officer roles and permissions",
//                     style: TextStyle(color: Colors.grey, fontSize: 14),
//                   ),
//                 ],
//               ),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
//                 label: const Text(
//                   "Assign Officer",
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 onPressed: () => _showAssignOfficerDialog(context),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // ==================== DIALOG METHODS ====================

//   void _showImportDialog(BuildContext context) {
//     String? selectedFileName;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               title: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.deepPurple.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(Icons.upload_file_rounded, color: Colors.deepPurple),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text("Import Students"),
//                 ],
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Select a CSV or Excel file to import student data.",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   const SizedBox(height: 16),
//                   InkWell(
//                     onTap: () async {
//                       FilePickerResult? result = await FilePicker.pickFiles(
//                         type: FileType.custom,
//                         allowedExtensions: ['csv', 'xls', 'xlsx'],
//                       );
//                       if (result != null) {
//                         setState(() {
//                           selectedFileName = result.files.single.name;
//                         });
//                       }
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[300]!, width: 2),
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.grey[50],
//                       ),
//                       child: Column(
//                         children: [
//                           Icon(Icons.cloud_upload_rounded, size: 48, color: Colors.deepPurple),
//                           const SizedBox(height: 8),
//                           Text(
//                             selectedFileName ?? "Choose file to upload",
//                             style: TextStyle(
//                               color: selectedFileName != null ? Colors.deepPurple : Colors.grey,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           if (selectedFileName == null) ...[
//                             const SizedBox(height: 4),
//                             Text(
//                               "CSV, XLS, XLSX (Max 10MB)",
//                               style: TextStyle(color: Colors.grey[400], fontSize: 12),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
//                 ),
//                 ElevatedButton(
//                   onPressed: selectedFileName == null ? null : () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     disabledBackgroundColor: Colors.grey[300],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text("Import", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showAddCandidateDialog(BuildContext context) {
//     bool isVerified = false;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               title: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.deepPurple.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(Icons.person_add_rounded, color: Colors.deepPurple),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text("Add New Candidate"),
//                 ],
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildDialogTextField("Student ID", Icons.badge_outlined),
//                     const SizedBox(height: 12),
//                     _buildDialogTextField("Position", Icons.how_to_vote_outlined),
//                     const SizedBox(height: 12),
//                     TextField(
//                       maxLines: 3,
//                       decoration: InputDecoration(
//                         labelText: "Bio",
//                         alignLabelWithHint: true,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
//                         ),
//                         prefixIcon: Icon(Icons.notes, color: Colors.grey[500]),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     SwitchListTile(
//                       contentPadding: EdgeInsets.zero,
//                       title: const Text(
//                         "Verified",
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       subtitle: const Text("Mark candidate as verified/eligible"),
//                       value: isVerified,
//                       activeColor: Colors.deepPurple,
//                       onChanged: (value) => setState(() => isVerified = value),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text("Add Candidate", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showAssignOfficerDialog(BuildContext context) {
//     String selectedRole = 'officer';
//     bool isActive = true;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               title: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.deepPurple.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.deepPurple),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text("Assign Election Officer"),
//                 ],
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildDialogTextField("First Name", Icons.person_outline),
//                     const SizedBox(height: 12),
//                     _buildDialogTextField("Last Name", Icons.person_outline),
//                     const SizedBox(height: 12),
//                     _buildDialogTextField("Email Address", Icons.email_outlined),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue: selectedRole,
//                       decoration: InputDecoration(
//                         labelText: "Role",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
//                         ),
//                         prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: Colors.grey[500]),
//                       ),
//                       items: const [
//                         DropdownMenuItem(value: 'officer', child: Text("Officer")),
//                         DropdownMenuItem(value: 'admin', child: Text("Admin")),
//                       ],
//                       onChanged: (value) {
//                         if (value != null) setState(() => selectedRole = value);
//                       },
//                     ),
//                     const SizedBox(height: 8),
//                     SwitchListTile(
//                       contentPadding: EdgeInsets.zero,
//                       title: const Text(
//                         "Active",
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       subtitle: const Text("Officer account is active"),
//                       value: isActive,
//                       activeColor: Colors.deepPurple,
//                       onChanged: (value) => setState(() => isActive = value),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text("Assign Officer", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // Helper method for dialog text fields
//   Widget _buildDialogTextField(String label, IconData icon) {
//     return TextField(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
//         ),
//         prefixIcon: Icon(icon, color: Colors.grey[500]),
//       ),
//     );
//   }
// }
