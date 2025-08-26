import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/Authentication/Presentation/login_screen.dart';
import 'package:instagram/features/Authentication/logics/auth_cubit.dart';
import 'package:instagram/features/Authentication/logics/auth_state.dart';
import 'package:instagram/features/Profile/Presentation/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  final String currentUserId;
  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _screens() => [
    _feedScreen(),
    _searchScreen(),
    _postScreen(),
    ProfileScreen(
      uid: widget.currentUserId,
      currentUserId: widget.currentUserId,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _feedScreen() {
    return const Center(
      child: Text(
        "No posts yet",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _searchScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search users or posts",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const Expanded(
          child: Center(child: Text("Search results will appear here")),
        ),
      ],
    );
  }

  Widget _postScreen() {
    return const Center(
      child: Text(
        "Post screen",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, dynamic>(
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
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),
        body: _screens()[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: "Add Post",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
