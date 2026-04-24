import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/map_screen.dart';
import 'screens/agent_portal_screen.dart';
import 'screens/help_center_screen.dart';
import 'services/land_service.dart';

// FoncierChain Brazzaville - Main Entry Point
// Optimized for mobile-first land registry transparency

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase avec les options générées
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
          scaffoldBackgroundColor: const Color(0xFF0B0E14),
          primaryColor: const Color(0xFF00963F),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00963F),
            brightness: Brightness.dark,
            primary: const Color(0xFF00963F),
            secondary: const Color(0xFF00963F),
            onPrimary: Colors.white,
            surface: const Color(0xFF161B22),
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ).copyWith(
            displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
            displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
            displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
            headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.white),
            bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF161B22),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF00963F), width: 2),
            ),
            hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF161B22),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              side: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00963F),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
  final List<Widget> _screens = [
    const HomeScreen(),
    const VerifyScreen(),
    const MapScreen(),
    const HelpCenterScreen(),
    const AgentPortalScreen(),
  ];

  void _onTabTapped(int index) {
    Provider.of<LandService>(context, listen: false).setTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final navService = Provider.of<LandService>(context);
    
    return Scaffold(
      body: IndexedStack(
        index: navService.currentTabIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(navService.currentTabIndex),
    );
  }

  Widget _buildBottomNav(int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E14),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF00963F),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_outlined), label: 'Vérifier'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'Aide'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Agent'),
        ],
      ),
    );
  }
}
