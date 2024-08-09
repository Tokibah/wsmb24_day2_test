import 'package:d2_wsf24_rider/Home/homepage.dart';
import 'package:d2_wsf24_rider/Welcome/launchscreen.dart';
import 'package:d2_wsf24_rider/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(ChangeNotifierProvider(
        create: (context) => ThemeProvider(), child: const MyApp()));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? user;
  bool notLoading = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs.getString('token');
      notLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: child,
      ),
      child: notLoading
          ? (user == null ? LaunchScreen() : HomePage(userId: user))
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  static ThemeData _themeData = _lightMode;
  ThemeData get themeData => _themeData;

  static const Color highlightColor = Color(0xFF4CC486);
  static const Color trustColor = Color(0xFF87CEEB);
  static const Color popColor = Color(0xFFFFD700);
  static const Color lightColor = Color(0xFFF5F5F5);
  static const Color honeydew = Color(0xFFE0F5EB);

  static final _lightMode = ThemeData(
      useMaterial3: true,
      iconTheme: IconThemeData(color: highlightColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black, backgroundColor: highlightColor)),
      scaffoldBackgroundColor: lightColor,
      colorScheme: const ColorScheme.light(
          outline: Colors.black,
          primary: highlightColor,
          secondary: highlightColor,
          surface: lightColor));
}
