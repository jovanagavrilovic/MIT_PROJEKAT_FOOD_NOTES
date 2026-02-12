import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final docs = snap.data?.docs ?? [];

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data();
              final uid = d.id;

              final email = (data['email'] ?? data['name'] ?? uid).toString();
              final role = (data['role'] ?? 'user').toString();
              final blocked = (data['isBlocked'] ?? false) == true;

              final isMe = uid == meUid;
              final isAdmin = role == "admin";

              return ListTile(
                title: Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text("role: $role"),
                trailing: Switch(
                  value: blocked,
                  onChanged: (isMe || isAdmin)
                      ? null // ne blokiramo sebe niti admina
                      : (v) async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .set({'isBlocked': v}, SetOptions(merge: true));
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
