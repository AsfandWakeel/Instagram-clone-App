import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/Authentication/Presentation/login_screen.dart';
import 'package:instagram/features/Authentication/logics/auth_cubit.dart';
import 'package:instagram/features/Authentication/logics/auth_state.dart';
import 'package:instagram/features/Feed/presentation/feed_screen.dart';
import 'package:instagram/features/Post/Presentation/create_post_screen.dart';
import 'package:instagram/features/Profile/Presentation/profile_screen.dart';
import 'package:instagram/features/notifications/presentation/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  final String currentUserId;
  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = "";

  List<Widget> get _screens {
    return [
      FeedScreen(currentUserId: widget.currentUserId),
      _searchScreen(),
      CreatePostScreen(currentUserId: widget.currentUserId),
      ProfileScreen(
        uid: widget.currentUserId,
        currentUserId: widget.currentUserId,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _searchScreen() {
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
            onChanged: (query) {
              setState(() => _searchQuery = query.trim());
            },
          ),
        ),
        Expanded(
          child: _searchQuery.isEmpty
              ? const Center(child: Text("Search results will appear here"))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('username', isGreaterThanOrEqualTo: _searchQuery)
                      .where(
                        'username',
                        isLessThanOrEqualTo: '$_searchQuery\uf8ff',
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final users = snapshot.data!.docs;
                    if (users.isEmpty) {
                      return const Center(child: Text("No users found"));
                    }
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['photoUrl'] != ""
                                ? NetworkImage(user['photoUrl'])
                                : null,
                            child: user['photoUrl'] == ""
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(user['username']),
                          subtitle: Text(user['email']),
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Instagram"),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(
                      currentUserId: widget.currentUserId,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Add"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
