import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<String> tabs = ["FRIENDS", "GROUPS", "ACTIVITY"];

  final List<Map<String, dynamic>> friends = [
    {"name": "Sujal Gauchan", "initial": "S", "owe": true, "amount": 500},
    {"name": "Sushant Shrestha", "initial": "S", "owe": false, "amount": 1200},
    {"name": "Rojan Shrestha", "initial": "R", "owe": false, "amount": 300},
    {"name": "Miraj Gansi", "initial": "M", "owe": true, "amount": 750},
    {"name": "Anil B.", "initial": "A", "owe": false, "amount": 40},
    {"name": "Kiran L.", "initial": "K", "owe": true, "amount": 220},
  ];

  void _onNavItem(int index) => setState(() => _selectedIndex = index);

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
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final isTablet = width >= 700;

    final double padding = isTablet ? 32 : 20;
    final double avatarRadius = isTablet ? 32 : 26;
    final double cardRadius = 20.0;

    const Color background = Color(0xFF0D1117);
    const Color surface = Color(0xFF161B22);
    const Color headerStart = Color(0xFF1E3A8A);
    const Color headerEnd = Color(0xFF0F172A);
    const Color accent = Color(0xFF14B8A6);

    Widget buildFriendCard(Map<String, dynamic> f) {
      final bool owe = f['owe'] as bool;
      final int amount = f['amount'] as int;
      final String name = f['name'] as String;
      final String initial = f['initial'] as String;

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
              padding: EdgeInsets.all(isTablet ? 20 : 16),
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
                  SizedBox(width: isTablet ? 20 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 19 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          owe ? "You owe" : "Owes you",
                          style: TextStyle(
                            color: owe ? Colors.redAccent : Colors.greenAccent,
                            fontSize: isTablet ? 15 : 13,
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
                          fontSize: isTablet ? 20 : 17,
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
                            horizontal: isTablet ? 24 : 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

    Widget buildTabs() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: tabs.asMap().entries.map((entry) {
          int idx = entry.key;
          String text = entry.value;
          bool selected = _selectedIndex == idx;
          return GestureDetector(
            onTap: () => _onNavItem(idx),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? accent : surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: selected
                    ? [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))]
                    : [],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    Widget contentArea() {
      return Column(
        children: [
          // Header
          Container(
            height: isTablet ? 260 : 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [headerStart, headerEnd],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Balance",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isTablet ? 18 : 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "\$750.00",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 48 : 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
          ),

          // Body
          Expanded(
            child: Container(
              color: background,
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Tabs
                  buildTabs(),
                  const SizedBox(height: 24),

                  Expanded(
                    child: () {
                      switch (_selectedIndex) {
                        case 0: // Friends
                          return isTablet
                              ? GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 4,
                                  ),
                                  itemCount: friends.length,
                                  itemBuilder: (_, i) => buildFriendCard(friends[i]),
                                )
                              : ListView.separated(
                                  itemCount: friends.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                                  itemBuilder: (_, i) => buildFriendCard(friends[i]),
                                );
                        case 1: // Groups
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.group, size: 60, color: Colors.white24),
                                SizedBox(height: 16),
                                Text("Groups coming soon",
                                    style: TextStyle(color: Colors.white54, fontSize: 18)),
                              ],
                            ),
                          );
                        case 2: // Activity
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.receipt_long, size: 60, color: Colors.white24),
                                SizedBox(height: 16),
                                Text("Activity log coming soon",
                                    style: TextStyle(color: Colors.white54, fontSize: 18)),
                              ],
                            ),
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    }(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: isTablet
            ? Row(
                children: [
                  NavigationRail(
                    backgroundColor: surface,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onNavItem,
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: IconThemeData(color: accent),
                    selectedLabelTextStyle: TextStyle(color: accent, fontWeight: FontWeight.bold),
                    unselectedLabelTextStyle: TextStyle(color: Colors.white70),
                    leading: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: accent,
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                    ),
                    destinations: const [
                      NavigationRailDestination(icon: Icon(Icons.home_outlined), label: Text('Home')),
                      NavigationRailDestination(icon: Icon(Icons.group_outlined), label: Text('Groups')),
                      NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined), label: Text('Activity')),
                      NavigationRailDestination(icon: Icon(Icons.account_circle_outlined), label: Text('Account')),
                    ],
                  ),
                  Expanded(child: contentArea()),
                ],
              )
            : contentArea(),
      ),
    );
  }
}

// Tap animation
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