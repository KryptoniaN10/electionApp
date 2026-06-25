import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Professional Color Palette — Deep Slate + Indigo accent
// No purple gradients, no glow orbs, no "AI-generated" magic effects.
// ---------------------------------------------------------------------------
class MachineTheme {
  static const Color background = Color(0xFFF3F4F6);      // Light cool gray
  static const Color surface = Color(0xFFFFFFFF);           // Pure white cards
  static const Color sidebar = Color(0xFF1E293B);          // Deep slate sidebar
  static const Color sidebarHover = Color(0xFF334155);    // Slightly lighter slate
  static const Color primary = Color(0xFF4F46E5);        // Indigo accent
  static const Color primaryDeep = Color(0xFF3730A3);    // Darker indigo
  static const Color accent = Color(0xFF6366F1);         // Light indigo
  static const Color success = Color(0xFF059669);        // Emerald green
  static const Color warning = Color(0xFFD97706);        // Amber
  static const Color danger = Color(0xFFDC2626);         // Red
  static const Color text = Color(0xFF111827);           // Near-black
  static const Color textLight = Color(0xFFFFFFFF);      // White text on dark
  static const Color muted = Color(0xFF6B7280);          // Cool gray
  static const Color border = Color(0xFFE5E7EB);         // Subtle border gray
  static const Color darkCanvas = Color(0xFF0F172A);      // Very dark for voting mode
  static const Color darkSurface = Color(0xFF1E293B);     // Dark card surface

  static ThemeData materialTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      fontFamily: 'sans-serif',
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MachineScaffold — Left sidebar + clean main content area
// ---------------------------------------------------------------------------
class MachineScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showSidebar;
  final double darkModeProgress;
  final bool useSafeArea;

  const MachineScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.showSidebar = true,
    this.darkModeProgress = 0,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    // Respect original showSidebar flag + mobile logic
    final effectiveShowSidebar = showSidebar && !isMobile;

    // Dark mode interpolation (kept for compatibility)
    final progress = darkModeProgress.clamp(0.0, 1.0);
    final bgColor = Color.lerp(MachineTheme.background, MachineTheme.darkCanvas, progress)!;
    final contentColor = Color.lerp(MachineTheme.surface, MachineTheme.darkSurface, progress)!;
    final textColor = Color.lerp(MachineTheme.text, Colors.white, progress)!;
    final subtitleColor = Color.lerp(MachineTheme.muted, Colors.white60, progress)!;

    return Scaffold(
      backgroundColor: bgColor,
      drawer: isMobile ? const MachineDrawer() : null,
      floatingActionButton: floatingActionButton,
      appBar: isMobile
          ? AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: actions,
            )
          : null,
      body: Row(
        children: [
          if (effectiveShowSidebar) const MachineSidebar(),
          Expanded(
            child: Column(
              children: [
                // Desktop Header
                if (!isMobile)
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...?actions,
                      ],
                    ),
                  ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 16 : 24,
                      isMobile ? 16 : 0,
                      isMobile ? 16 : 24,
                      16,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: contentColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: progress > 0.5
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withAlpha(12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                        border: Border.all(
                          color: Color.lerp(MachineTheme.border, Colors.white.withAlpha(20), progress)!,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ---------------------------------------------------------------------------
// MachineSidebar — Left navigation rail with icon + label
// ---------------------------------------------------------------------------
class MachineSidebar extends StatelessWidget {
  const MachineSidebar({super.key});

  static const List<_MachineTabDestination> _destinations = [
    _MachineTabDestination('Dashboard', '/dashboard', Icons.space_dashboard_outlined),
    _MachineTabDestination('Elections', '/election-init', Icons.how_to_vote_outlined),
    _MachineTabDestination('Ballot', '/ballot', Icons.ballot_outlined),
    _MachineTabDestination('Audit', '/audit-logs', Icons.receipt_long_outlined),
    _MachineTabDestination('Settings', '/settings', Icons.tune_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '/dashboard';

    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: MachineTheme.sidebar,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App branding
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: MachineTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.how_to_vote,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'VoteMachine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          // Navigation items
          Expanded(
            child: ListView.builder(
              itemCount: _destinations.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final dest = _destinations[index];
                final selected = route == dest.route;
                return _SidebarItem(
                  label: dest.label,
                  icon: dest.icon,
                  route: dest.route,
                  selected: selected,
                );
              },
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MachineTheme.sidebarHover,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: MachineTheme.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'System Online',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final bool selected;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          if (!selected) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? MachineTheme.primary.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border(
                    left: BorderSide(
                      color: MachineTheme.primary,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? MachineTheme.primary : Colors.white60,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : Colors.white60,
                ),
              ),
              if (selected) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: MachineTheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MachineCard — Clean white card with subtle shadow
// ---------------------------------------------------------------------------
class MachineCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool tinted;

  const MachineCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.tinted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: tinted ? const Color(0xFFF8F9FC) : MachineTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// SectionTitle — Clean typography
// ---------------------------------------------------------------------------
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MachineTheme.text,
            letterSpacing: -0.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: MachineTheme.muted,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// StatusPill — Rounded badge with background tint
// ---------------------------------------------------------------------------
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// InfoTile — Clean data display with icon
// ---------------------------------------------------------------------------
class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MachineTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: MachineTheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: MachineTheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MachineTheme.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MachineTheme.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CandidateAvatar — Clean circle with initial
// ---------------------------------------------------------------------------
class CandidateAvatar extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final double size;

  const CandidateAvatar({
    super.key,
    required this.title,
    this.imageUrl,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final initial = title.isEmpty ? '?' : title.substring(0, 1).toUpperCase();

    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        color: MachineTheme.primary.withAlpha(20),
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: MachineTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: size * 0.35,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: MachineTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: size * 0.35,
                  ),
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
String formatDateTime(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)} '
      '${two(value.hour)}:${two(value.minute)}';
}

class _MachineTabDestination {
  final String label;
  final String route;
  final IconData icon;
  const _MachineTabDestination(this.label, this.route, this.icon);
}
// ---------------------------------------------------------------------------
// MachineDrawer — Mobile navigation drawer
// ---------------------------------------------------------------------------
class MachineDrawer extends StatelessWidget {
  const MachineDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '/dashboard';

    return Drawer(
      backgroundColor: MachineTheme.sidebar,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: MachineTheme.primary,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.how_to_vote,
                    color: MachineTheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'VoteMachine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: MachineSidebar._destinations.length,
              itemBuilder: (context, index) {
                final dest = MachineSidebar._destinations[index];
                final selected = route == dest.route;

                return ListTile(
                  leading: Icon(
                    dest.icon,
                    color: selected ? MachineTheme.primary : Colors.white70,
                    size: 24,
                  ),
                  title: Text(
                    dest.label,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  selected: selected,
                  selectedTileColor: MachineTheme.primary.withAlpha(30),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    if (!selected) {
                      Navigator.pushReplacementNamed(context, dest.route);
                    }
                  },
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: MachineTheme.success, size: 20),
                SizedBox(width: 10),
                Text(
                  'System Online',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}