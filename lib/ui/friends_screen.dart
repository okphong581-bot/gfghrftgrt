import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel.dart';
import '../theme.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchController = TextEditingController();

  void _addFriend() async {
    final username = _searchController.text.trim();
    if (username.isEmpty) return;
    
    final vm = Provider.of<XocketViewModel>(context, listen: false);
    if (username == vm.currentUser?.username) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ê, sao lại tự kết bạn với chính mình? 🤔')));
       return;
    }
    
    final success = await vm.addFriend(username);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Đã thêm \$username vào hội bạn thân! 🎉', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: XocketTheme.primaryDark,
      ));
      _searchController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy idol này 😥')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<XocketViewModel>(context);

    return Scaffold(
      backgroundColor: XocketTheme.background,
      appBar: AppBar(
        backgroundColor: XocketTheme.surface,
        elevation: 0,
        title: const Text("HỘI BẠN THÂN", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header search
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: XocketTheme.surface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Thêm Bạn Mới", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: "Nhập ID (Ví dụ: thuysg)",
                          prefixIcon: const Icon(Icons.person_add_alt_1_rounded, color: XocketTheme.primary),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: XocketTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: _addFriend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                        child: const Icon(Icons.add_rounded, size: 28, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          
          // List friends
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text("Cạ cứng của bạn (\${vm.friends.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: XocketTheme.textSecondary)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: vm.friends.isEmpty
                        ? const Center(child: Text("Hội bạn đang trống trơn...", style: TextStyle(color: XocketTheme.textSecondary, fontSize: 16)))
                        : ListView.separated(
                            itemCount: vm.friends.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (ctx, index) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: XocketTheme.surface.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: XocketTheme.primary.withOpacity(0.2),
                                      border: Border.all(color: XocketTheme.primary, width: 2),
                                    ),
                                    child: const Icon(Icons.person_rounded, color: XocketTheme.primary),
                                  ),
                                  title: Text(vm.friends[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.waving_hand_rounded, color: XocketTheme.primaryDark),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang vẫy tay chọc tức bạn bè 👋')));
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
