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
    {"name": "Subodh Kohle", "initial": "S", "owe": true, "amount": 500},
    {"name": "Shobhit Bakival", "initial": "S", "owe": false, "amount": 500},
    {"name": "Firasat Durani", "initial": "F", "owe": false, "amount": 500},
    {"name": "Sushil Kumar", "initial": "S", "owe": true, "amount": 500},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Groups"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Activity"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFFFC107),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: const [
                  Text("750.00 \$", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Available balance", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text("Friends", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 16),
                    Column(
                      children: friends.map((f) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: Text(f["initial"], style: const TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(f["name"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      Text(f["owe"] ? "You owe" : "Owes you", style: const TextStyle(color: Colors.red, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${f["owe"] ? "-" : "+"}${f["amount"]} \$",
                                    style: TextStyle(
                                        color: f["owe"] ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(12)),
                                    child: Text(f["owe"] ? "Pay" : "Request"),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
