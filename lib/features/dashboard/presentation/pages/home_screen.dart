import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/groups_view_model.dart';
import '../view_models/add_expense_view_model.dart';
import 'group_detail_screen.dart';
import '../../domain/model/group.dart';
import '../../data/datasource/remote/group_remote_datasource.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const Color kBackground = Color(0xFF0F1217);
  static const Color kSurface = Color(0xFF171C24);
  static const Color kSurfaceElevated = Color(0xFF1F2630);
  static const Color kTextPrimary = Color(0xFFF8FAFC);
  static const Color kTextSecondary = Color(0xFF94A3B8);
  static const Color kAccent = Color(0xFF22D3EE);
  static const Color kAccentDark = Color(0xFF0891B2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupsViewModelProvider.notifier).loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildGroupsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kAccentDark, kBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Groups", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Manage your expenses with friends",
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _showCreateGroupDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("+ New Group"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    final groupsAsync = ref.watch(groupsViewModelProvider);
    return groupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      data: (groups) {
        if (groups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 80, color: kTextSecondary.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text("No groups yet", style: TextStyle(color: kTextSecondary, fontSize: 18)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          itemBuilder: (ctx, i) => _buildGroupCard(groups[i]),
        );
      },
    );
  }

  Widget _buildGroupCard(Group group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: kSurfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: kAccent,
          child: Text(
            group.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(group.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text('${group.members.length} members', style: TextStyle(color: kTextSecondary)),
        trailing: Text(
          'Rs ${group.totalBalance.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: group.id)),
          );
        },
      ),
    );
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final memberController = TextEditingController();
    final members = <String>[];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: kSurface,
            title: const Text('Create Group', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: memberController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Member name',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        if (memberController.text.isNotEmpty) {
                          setState(() {
                            members.add(memberController.text);
                            memberController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: members.map((m) => Chip(
                    label: Text(m),
                    backgroundColor: kAccent,
                    onDeleted: () {
                      setState(() {
                        members.remove(m);
                      });
                    },
                  )).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || members.isEmpty) return;
                  Navigator.pop(ctx);
                  try {
                    await ref.read(groupsViewModelProvider.notifier).createGroup(
                      nameController.text,
                      members,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: kAccent),
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}