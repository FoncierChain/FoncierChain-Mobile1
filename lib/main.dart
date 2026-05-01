import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/map_screen.dart';
import 'screens/agent_portal_screen.dart';
import 'screens/help_center_screen.dart';
import 'services/land_service.dart';
import 'widgets/neural_background.dart';

// FoncierChain Brazzaville - Main Entry Point
// Optimized for mobile-first land registry transparency

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      child: Consumer<LandService>(
        builder: (context, navService, child) {
          return MaterialApp(
            title: 'FoncierChain',
            debugShowCheckedModeBanner: false,
            themeMode: navService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.grey[50],
              primaryColor: const Color(0xFF00963F),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00963F),
                brightness: Brightness.light,
                primary: const Color(0xFF00963F),
                surface: Colors.white,
              ),
              textTheme: GoogleFonts.interTextTheme(
                ThemeData.light().textTheme,
              ).copyWith(
                displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black87),
                headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
                bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF00963F), width: 2),
                ),
                hintStyle: GoogleFonts.inter(color: Colors.black26, fontSize: 14),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  side: const BorderSide(color: Colors.black12),
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
            darkTheme: ThemeData(
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
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationShell()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hub_outlined, color: Color(0xFF00963F), size: 100),
            const SizedBox(height: 32),
            Text(
              "FONCIERCHAINE",
              style: GoogleFonts.inter(
                fontSize: 36, 
                fontWeight: FontWeight.w900, 
                color: Colors.white, 
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "DÉVELOPPÉ PAR AFRICHAIN SOLUTION | MIABE HACKATHON 2026",
                style: GoogleFonts.inter(
                  fontSize: 10, 
                  fontWeight: FontWeight.w500, 
                  color: Colors.white38, 
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white10,
                color: Color(0xFF00963F),
              ),
            ),
          ],
        ),
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
      body: Stack(
        children: [
          const IgnorePointer(child: NeuralBackground()),
          IndexedStack(
            index: navService.currentTabIndex,
            children: _screens,
          ),
          Positioned(
            top: 50,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => navService.toggleTheme(),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (navService.isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Icon(
                    navService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: navService.isDarkMode ? Colors.amber : Colors.indigo,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
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
