import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/map_screen.dart';
import 'screens/agent_portal_screen.dart';
import 'services/land_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Note: Firebase initialization needs to be configured locally with your google-services.json
  runApp(const FoncierChainApp());
}

class FoncierChainApp extends StatelessWidget {
  const FoncierChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LandService()),
      ],
      child: MaterialApp(
        title: 'FoncierChain',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F1115),
          primaryColor: const Color(0xFFC5A059),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFC5A059),
            secondary: Color(0xFFC5A059),
            surface: Color(0xFF1A1C20),
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF1A1C20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
        ),
        home: const MainNavigationShell(),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const VerifyScreen(),
    const MapScreen(),
    const AgentPortalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0F1115),
          selectedItemColor: const Color(0xFFC5A059),
          unselectedItemColor: const Color(0xFF94A3B8),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'ACCUEIL'),
            BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'VÉRIFIER'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'CARTE'),
            BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'AGENT'),
          ],
        ),
      ),
    );
  }
}
