import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/map_screen.dart';
import 'screens/agent_portal_screen.dart';
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
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          primaryColor: const Color(0xFF00963F),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00963F),
            primary: const Color(0xFF00963F),
            secondary: const Color(0xFF00963F),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.light().textTheme,
          ).copyWith(
            displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF1A1A1A)),
            displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A1A)),
            displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
            headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
            bodyLarge: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1A1A1A)),
            bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
            labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x1A000000)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x1A000000)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF00963F), width: 2),
            ),
            hintStyle: GoogleFonts.inter(color: Colors.black26, fontSize: 14),
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              side: BorderSide(color: Color(0x0D000000)),
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
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF00963F),
        unselectedItemColor: Colors.black38,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Vérifier'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Agent'),
        ],
      ),
    );
  }
}
