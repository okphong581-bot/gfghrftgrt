import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../viewmodel.dart';
import '../theme.dart';
import 'friends_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  _HomeFeedScreenState createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _cameraBtnController;

  @override
  void initState() {
    super.initState();
    _cameraBtnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cameraBtnController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final vm = Provider.of<XocketViewModel>(context, listen: false);
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: XocketTheme.primary, strokeWidth: 6),
                  SizedBox(height: 24),
                  Text("Đang gửi cho hội bạn...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                ],
              ),
            ),
          ),
        );
        
        final success = await vm.uploadAndSendPhoto(bytes);
        Navigator.pop(context); 
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Tên lửa đã rời bệ phóng! 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi up ảnh!')));
        }
      }
    } catch (e) {
      print("Lỗi camera: \$e");
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: XocketTheme.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_add_rounded, size: 64, color: XocketTheme.primary),
          ),
          const SizedBox(height: 24),
          const Text("Xocket Đang Trống!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Mời bạn bè để bắt đầu chia sẻ\nnhững khoảnh khắc siêu bựa.", 
            textAlign: TextAlign.center, 
            style: TextStyle(color: XocketTheme.textSecondary, fontSize: 16)
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<XocketViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        title: const Text("XOCKET", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2, color: XocketTheme.primary)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.people_alt_rounded, size: 28),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, size: 28),
            onPressed: () => vm.logout(), // Tạm dùng nút cài đặt để logout
          )
        ],
      ),
      body: Stack(
        children: [
          // Feed
          vm.feeds.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 20,
                    bottom: 160,
                  ),
                  itemCount: vm.feeds.length,
                  itemBuilder: (context, index) {
                    final feed = vm.feeds[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(feed.timestamp);
                    final timeStr = DateFormat('HH:mm').format(date);
                    final isMe = feed.senderUsername == vm.currentUser?.username;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isMe ? "Bạn" : feed.senderUsername,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: XocketTheme.primary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "• \$timeStr",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: XocketTheme.textSecondary),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          AspectRatio(
                            aspectRatio: 1, // Hình vuông Locket chuẩn
                            child: Container(
                              width: double.infinity,
                            decoration: BoxDecoration(
                              color: XocketTheme.surface,
                              borderRadius: BorderRadius.circular(48), // Góc siêu to khổng lồ
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                )
                              ],
                              image: DecorationImage(
                                image: NetworkImage(feed.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          
          // Camera Button (Floating & Glowing)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _cameraBtnController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: XocketTheme.primary.withOpacity(0.3 + 0.3 * _cameraBtnController.value),
                          blurRadius: 20 + 20 * _cameraBtnController.value,
                          spreadRadius: 5 + 10 * _cameraBtnController.value,
                        )
                      ],
                    ),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: XocketTheme.primary,
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_alt_rounded, size: 40, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
