import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/home_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/map_screen.dart';
import 'screens/agent_portal_screen.dart';
import 'screens/help_center_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/password_setup_screen.dart';
import 'screens/signalement_screen.dart';
import 'services/land_service.dart';
import 'services/api_service.dart';
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
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/signalement': (context) => const SignalementScreen(),
              '/home': (context) => const MainNavigationShell(),
            },
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
    final navService = Provider.of<LandService>(context);
    final isDark = navService.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0E14) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hub_outlined, color: Color(0xFF00963F), size: 100),
            const SizedBox(height: 32),
            Text(
              "FONCIERCHAIN",
              style: GoogleFonts.inter(
                fontSize: 36, 
                fontWeight: FontWeight.w900, 
                color: isDark ? Colors.white : Colors.black87, 
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "DÉVELOPPÉ PAR AFRICHAIN SOLUTION | MIABE HACKATHON 2026",
                style: GoogleFonts.inter(
                  fontSize: 10, 
                  fontWeight: FontWeight.w500, 
                  color: isDark ? Colors.white38 : Colors.black38, 
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                color: const Color(0xFF00963F),
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

  final TextEditingController _chatController = TextEditingController();

  void _onTabTapped(int index) {
    Provider.of<LandService>(context, listen: false).setTabIndex(index);
  }

  void _launchGemini() async {
    final url = Uri.parse('https://gemini.google.com/gem/1sjFSlXDE6T9JaoACpwNsS_z8QS05NONy?usp=sharing');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible d'ouvrir le lien Gemini.")));
      }
    }
  }

  void _showChatbot(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final service = Provider.of<LandService>(context);
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF00963F), size: 16),
                    const SizedBox(width: 8),
                    Text("ASSISTANT FONCIER AI", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    onPressed: _launchGemini,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text("Expertise Gemini Avancée", style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      foregroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: service.chatHistory.length,
                    itemBuilder: (context, i) => _buildChatBubble(service.chatHistory[i]['text'], service.chatHistory[i]['isMe'], isDark),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Posez votre question...",
                            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                            prefixIcon: Icon(Icons.chat_outlined, size: 20, color: isDark ? Colors.white24 : Colors.black26),
                            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF00963F)),
                        onPressed: () async {
                          if (_chatController.text.isEmpty) return;
                          final msg = _chatController.text;
                          _chatController.clear();
                          await service.sendChatMessage(msg);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00963F) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontSize: 13)),
      ),
    );
  }

  void _showCreateTicketDialog(BuildContext context, bool isDark) {
    final subjectController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Ouvrir un ticket de support"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(hintText: "Sujet (ex: Erreur Cadastre)"),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: "Description du problème"),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.createTicket({
                  'subject': subjectController.text,
                  'description': descController.text,
                  'priority': 'URGENT',
                  'email': Provider.of<LandService>(context, listen: false).currentUser?.email ?? 'citoyen@foncierchain.cg'
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket créé avec succès")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00963F)),
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navService = Provider.of<LandService>(context);
    final isDark = navService.isDarkMode;
    
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
            child: Row(
              children: [
                if (navService.currentUser != null && !navService.currentUser!.isKYCVerified)
                  _buildKYCWarning(isDark),
                const SizedBox(width: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => navService.toggleTheme(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: isDark ? Colors.amber : Colors.indigo,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildNetworkBanner(isDark),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'ticket_fab',
            onPressed: () => _showCreateTicketDialog(context, isDark),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.confirmation_number_outlined, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'chat_fab',
            onPressed: () => _showChatbot(context, isDark),
            backgroundColor: const Color(0xFF00963F),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(navService.currentTabIndex, isDark),
    );
  }

  Widget _buildKYCWarning(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
          const SizedBox(width: 8),
          const Text("KYC NECESSAIRE", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNetworkBanner(bool isDark) {
    // This is a simple placeholder. In a real app, you'd use a connectivity plugin.
    // For this demo, we assume internet is active unless an API call fails.
    return const SizedBox.shrink();
  }

  Widget _buildBottomNav(int currentIndex, bool isDark) {
    final backgroundColor = isDark ? const Color(0xFF0B0E14) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black12;
    final unselectedColor = isDark ? Colors.white38 : Colors.black38;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF00963F),
        unselectedItemColor: unselectedColor,
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundColor,
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
