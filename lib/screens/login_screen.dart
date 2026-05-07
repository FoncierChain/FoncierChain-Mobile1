import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    final landService = Provider.of<LandService>(context, listen: false);
    try {
      await landService.login(_usernameController.text, _passwordController.text);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<LandService>(context).isDarkMode;
    
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hub_outlined, color: Color(0xFF00963F), size: 80),
                const SizedBox(height: 24),
                Text(
                  "FONCIERCHAIN",
                  style: GoogleFonts.inter(
                    fontSize: 24, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  "Brazzaville Land Ledger 2026",
                  style: GoogleFonts.inter(
                    fontSize: 12, 
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Nom d'utilisateur ou Email",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Mot de passe oublié ?", style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text("SE CONNECTER"),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Nouveau sur FoncierChain ? ",
                      style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      },
                      child: const Text(
                        "Créer un compte",
                        style: TextStyle(color: Color(0xFF00963F), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    _showPasswordSetupPrompt(context);
                  },
                  child: const Text(
                    "Activer mon compte avec mon UID FC",
                    style: TextStyle(fontSize: 12, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPasswordSetupPrompt(BuildContext context) {
    final uidController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Activation de compte"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Si vous avez reçu votre UID par email après validation de votre KYC, entrez-le ici."),
            const SizedBox(height: 16),
            TextField(
              controller: uidController,
              decoration: const InputDecoration(hintText: "FC-XXXXXX"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
          ElevatedButton(
            onPressed: () {
              if (uidController.text.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordSetupScreen(uid: uidController.text)));
              }
            }, 
            child: const Text("CONTINUER")),
        ],
      ),
    );
  }
}
