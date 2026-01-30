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

    const Color background = Color(0xFF0D1117);
    const Color surface = Color(0xFF161B22);
    const Color headerStart = Color(0xFF1E3A8A);
    const Color headerEnd = Color(0xFF0F172A);
    const Color accent = Color(0xFF14B8A6);

    if (isLargeScreen) {
      return Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                backgroundColor: surface,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                labelType: NavigationRailLabelType.all,
                selectedIconTheme: IconThemeData(color: accent),
                selectedLabelTextStyle: TextStyle(color: accent, fontWeight: FontWeight.bold),
                unselectedLabelTextStyle: TextStyle(color: Colors.white70),
                leading: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: accent,
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
              Expanded(child: _buildContent(background, accent, headerStart, headerEnd, isLargeScreen)),
            ],
          ),
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(child: _buildContent(background, accent, headerStart, headerEnd, isLargeScreen)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: Colors.white70,
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

  Widget _buildContent(
    Color background,
    Color accent,
    Color headerStart,
    Color headerEnd,
    bool isLargeScreen,
  ) {
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
              colors: [headerStart, headerEnd],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Balance",
                  style: TextStyle(color: Colors.white70, fontSize: isLargeScreen ? 18 : 15),
                ),
                const SizedBox(height: 12),
                Text(
                  "\$750.00",
                  style: TextStyle(
                    color: Colors.white,
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
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text("Add Money", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 16),
                    FloatingActionButton.extended(
                      heroTag: "send",
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
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
            color: background,
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
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text("Groups coming soon", style: TextStyle(color: Colors.white54, fontSize: 20)),
            ],
          ),
        );

      case 2:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text("Activity log coming soon", style: TextStyle(color: Colors.white54, fontSize: 20)),
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

    final cardRadius = 20.0;
    const Color surface = Color(0xFF161B22);
    const Color accent = Color(0xFF14B8A6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(cardRadius),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tapped on $name")),
          );
        },
        child: AnimatedScaleOnTap(
          child: Container(
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: _avatarColor(initial),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: avatarRadius * 0.9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: isLargeScreen ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLargeScreen ? 19 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        owe ? "You owe" : "Owes you",
                        style: TextStyle(
                          color: owe ? Colors.redAccent : Colors.greenAccent,
                          fontSize: isLargeScreen ? 15 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${owe ? '-' : '+'}\$$amount",
                      style: TextStyle(
                        color: owe ? Colors.redAccent : Colors.greenAccent,
                        fontSize: isLargeScreen ? 20 : 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: Icon(owe ? Icons.payment : Icons.request_page, size: 18),
                      label: Text(owe ? "Pay" : "Request"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 24 : 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(owe ? 'Paying $name...' : 'Requesting from $name...'),
                            backgroundColor: accent,
                          ),
                        );
                      },
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