import 'dart:async';
import 'package:flutter/material.dart';
import 'package:instagram/services/user_services.dart';
import 'package:instagram/features/Profile/Presentation/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final String currentUserId;
  const SearchScreen({super.key, required this.currentUserId});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isEmpty) {
        setState(() {
          _results = [];
        });
        return;
      }

      setState(() {
        _loading = true;
      });

      final users = await _userService.searchUsers(value);
      if (users == null) return;
      setState(() {
        _results = users;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search users",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
              ? const Center(child: Text("No users found"))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final user = _results[index];

                    final profileImage =
                        (user['profileImage'] != null &&
                            user['profileImage'].isNotEmpty)
                        ? user['profileImage']
                        : null;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profileImage != null
                            ? NetworkImage(profileImage)
                            : null,
                        child: profileImage == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(user['username'] ?? "No name"),
                      subtitle: Text(user['email'] ?? ""),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                              uid: user['uid'],
                              currentUserId: widget.currentUserId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
