import 'package:flutter/material.dart';
import '../../../dashboard/presentation/pages/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> friends = [
    {"name": "Sujal Gauchan", "initial": "S", "owe": true, "amount": 500},
    {"name": "Sushant Shrestha", "initial": "S", "owe": false, "amount": 1200},
    {"name": "Rojan Shrestha", "initial": "R", "owe": false, "amount": 300},
    {"name": "Miraj Gansi", "initial": "M", "owe": true, "amount": 750},
    {"name": "Anil B.", "initial": "A", "owe": false, "amount": 40},
    {"name": "Kiran L.", "initial": "K", "owe": true, "amount": 220},
  ];

  static const Color kBackground = Color(0xFF0F1217);
  static const Color kSurface = Color(0xFF171C24);
  static const Color kSurfaceElevated = Color(0xFF1F2630);
  static const Color kTextPrimary = Color(0xFFF8FAFC);
  static const Color kTextSecondary = Color(0xFF94A3B8);
  static const Color kAccent = Color(0xFF22D3EE);
  static const Color kAccentDark = Color(0xFF0891B2);
  static const Color kPositive = Color(0xFF10B981);
  static const Color kNegative = Color(0xFFEF4444);
  static const Color kDivider = Color(0xFF2A3344);

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Color _avatarColor(String initial) {
    final colors = [
      Colors.teal,
      Colors.indigo,
      Colors.deepPurple,
      Colors.pink,
      Colors.orange,
      Colors.cyan,
    ];
    return colors[initial.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLargeScreen = width >= 700;

    if (isLargeScreen) {
      return Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                backgroundColor: kSurface,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                labelType: NavigationRailLabelType.all,
                selectedIconTheme: IconThemeData(color: kAccent),
                selectedLabelTextStyle: TextStyle(color: kAccent, fontWeight: FontWeight.bold),
                unselectedLabelTextStyle: TextStyle(color: kTextSecondary),
                leading: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: kAccent,
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.home_outlined), label: Text('Home')),
                  NavigationRailDestination(icon: Icon(Icons.group_outlined), label: Text('Groups')),
                  NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined), label: Text('Activity')),
                  NavigationRailDestination(icon: Icon(Icons.account_circle_outlined), label: Text('Account')),
                ],
              ),
              Expanded(child: _buildContent(isLargeScreen)),
            ],
          ),
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(child: _buildContent(isLargeScreen)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: kSurface,
        selectedItemColor: kAccent,
        unselectedItemColor: kTextSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildContent(bool isLargeScreen) {
    final padding = isLargeScreen ? 32.0 : 20.0;
    final avatarRadius = isLargeScreen ? 32.0 : 26.0;

    return Column(
      children: [
        // Header
        Container(
          height: isLargeScreen ? 260 : 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kAccentDark, kBackground],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Balance",
                  style: TextStyle(color: kTextSecondary, fontSize: isLargeScreen ? 18 : 15),
                ),
                const SizedBox(height: 12),
                Text(
                  "\$750.00",
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: isLargeScreen ? 48 : 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    FloatingActionButton.extended(
                      heroTag: "add",
                      backgroundColor: kAccent,
                      foregroundColor: kTextPrimary,
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text("Add Money", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton.extended(
                      heroTag: "send",
                      backgroundColor: kSurfaceElevated,
                      foregroundColor: kTextPrimary,
                      onPressed: () {},
                      icon: const Icon(Icons.send_outlined),
                      label: const Text("Send", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Main content
        Expanded(
          child: Container(
            color: kBackground,
            padding: EdgeInsets.all(padding),
            child: _buildSelectedPage(avatarRadius, isLargeScreen),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedPage(double avatarRadius, bool isLargeScreen) {
    switch (_selectedIndex) {
      case 0:
        return isLargeScreen
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 4,
                ),
                itemCount: friends.length,
                itemBuilder: (_, i) => _buildFriendCard(friends[i], avatarRadius, isLargeScreen),
              )
            : ListView.separated(
                itemCount: friends.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _buildFriendCard(friends[i], avatarRadius, isLargeScreen),
              );

      case 1:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group, size: 80, color: kTextSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text("Groups coming soon", style: TextStyle(color: kTextSecondary, fontSize: 20)),
            ],
          ),
        );

      case 2:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 80, color: kTextSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text("Activity log coming soon", style: TextStyle(color: kTextSecondary, fontSize: 20)),
            ],
          ),
        );

      case 3:
        return  ProfileScreen();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFriendCard(Map<String, dynamic> f, double avatarRadius, bool isLargeScreen) {
    final bool owe = f['owe'] as bool;
    final int amount = f['amount'] as int;
    final String name = f['name'] as String;
    final String initial = f['initial'] as String;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tapped on $name")),
          );
        },
        child: AnimatedScaleOnTap(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: kSurfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [kAccentDark, kAccent],
                  ),
                ),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: avatarRadius * 0.9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: isLargeScreen ? 19 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                owe ? "You owe" : "Owes you",
                style: TextStyle(color: owe ? kNegative : kPositive),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${owe ? '-' : '+'}\$$amount",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: owe ? kNegative : kPositive,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(owe ? 'Paying $name...' : 'Requesting from $name...'),
                          backgroundColor: kAccent,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        owe ? "Pay" : "Request",
                        style: const TextStyle(color: kAccent, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// AnimatedScaleOnTap remains unchanged
class AnimatedScaleOnTap extends StatefulWidget {
  final Widget child;
  const AnimatedScaleOnTap({required this.child, super.key});

  @override
  State<AnimatedScaleOnTap> createState() => _AnimatedScaleOnTapState();
}

class _AnimatedScaleOnTapState extends State<AnimatedScaleOnTap> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}