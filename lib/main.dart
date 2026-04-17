import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/map_screen.dart';
import 'screens/agent_portal_screen.dart';
import 'services/land_service.dart';

// FoncierChain Brazzaville - Main Entry Point
// Optimized for mobile-first land registry transparency

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // IMPORTANT: Firebase must be configured manually by exporting the code
  // and adding the google-services.json file in the android/app/ directory.
  runApp(const FoncierChainApp());
}

class FoncierChainApp extends StatelessWidget {
  const FoncierChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => LandService()),
      ],
      child: MaterialApp(
        title: 'FoncierChain',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F1115),
          primaryColor: const Color(0xFFC5A059),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFC5A059),
            brightness: Brightness.dark,
            primary: const Color(0xFFC5A059),
            secondary: const Color(0xFFC5A059),
            surface: const Color(0xFF1A1C20),
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF1A1C20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: const Color(0xFF0F1115),
          selectedItemColor: const Color(0xFFC5A059),
          unselectedItemColor: const Color(0xFF94A3B8),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'ACCUEIL',
              tooltip: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user),
              label: 'VÉRIFIER',
              tooltip: 'Vérifier un titre',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'CARTE',
              tooltip: 'Plan cadastral',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'AGENT',
              tooltip: 'Espace Agent',
            ),
          ],
        ),
      ),
    );
  }
}
