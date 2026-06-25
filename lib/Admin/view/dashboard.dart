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
  // Local state
  bool isVerified = false;
  final TextEditingController positionController = TextEditingController();
  final TextEditingController studentId = TextEditingController();
  final TextEditingController bioStudent =TextEditingController();
  String? selectedPosition;

  // Example: Available positions (you can load these from provider later)
  final List<String> availablePositions = [
    "President",
    "Vice President",
    "Secretary",
    "Treasurer",
    "Class Representative",
    "Sports Secretary",
    "Cultural Secretary",
    "Technical Secretary",
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add New Candidate"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student ID
                  TextField(
                    controller: studentId,
                    decoration: InputDecoration(
                      labelText: "Student ID",
                      helperText: "Links this candidate to an existing student",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Smart Position Field
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: selectedPosition ?? ''),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return availablePositions;
                      }
                      return availablePositions.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        selectedPosition = selection;
                        positionController.text = selection;
                      });
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      // Keep reference to controller
                      positionController.text = textEditingController.text;
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: "Position",
                          hintText: "Type or select position...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.how_to_vote_outlined),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        onSubmitted: (value) {
                          // Allow custom position
                          if (value.isNotEmpty && !availablePositions.contains(value)) {
                            setState(() {
                              availablePositions.add(value); // Add new position to suggestions
                              selectedPosition = value;
                            });
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  TextField(
                    maxLines: 3,
                    controller: bioStudent,
                    decoration: InputDecoration(
                      labelText: "Bio",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Verified Switch
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
                  final position = positionController.text.trim();
                  if (studentId.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('StudentId is required')),
                    );
                  }
                  if (position.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Position is required')),
                    );
                    return;
                  }
                  
                  // TODO: Save candidate with position
                  // Example: position, studentId, bio, isVerified
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B46C1)),
                child: const Text("Add Candidate", style: TextStyle(color: Colors.white)),
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