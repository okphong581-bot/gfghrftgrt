import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'viewmodel.dart';
import 'ui/auth_screen.dart';
import 'ui/home_feed_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => XocketViewModel()),
      ],
      child: const XocketApp(),
    ),
  );
}

class XocketApp extends StatelessWidget {
  const XocketApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xocket',
      debugShowCheckedModeBanner: false,
      theme: XocketTheme.themeData,
      home: Consumer<XocketViewModel>(
        builder: (context, vm, child) {
          if (vm.currentUser == null) {
            return const AuthScreen();
          }
          return const HomeFeedScreen();
        },
      ),
    );
  }
}
