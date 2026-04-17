import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';

class AgentPortalScreen extends StatefulWidget {
  const AgentPortalScreen({super.key});

  @override
  State<AgentPortalScreen> createState() => _AgentPortalScreenState();
}

class _AgentPortalScreenState extends State<AgentPortalScreen> {
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final service = Provider.of<LandService>(context, listen: false);
      await service.loginWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec de la connexion: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() async {
    final service = Provider.of<LandService>(context, listen: false);
    await service.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<LandService>(context);
    final user = service.currentUser;

    if (user == null) {
      return _buildLoginView();
    }

    return _buildAgentDashboard(user);
  }

  Widget _buildLoginView() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.yellow, Colors.red],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 32),
              Text(
                "ESPACE CERTIFIÉ",
                style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5, color: Colors.black),
              ),
              const SizedBox(height: 8),
              const Text(
                "Réservé aux agents du cadastre et notaires certifiés de Brazzaville.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFF00963F))
              else
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: const Color(0xFF1A1A1A),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 18),
                      SizedBox(width: 12),
                      Text("Se connecter avec Google"),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                "Sécurisé par AfriChain solutions Blockchain Technology",
                style: TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgentDashboard(User user) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Tableau de Bord Agent", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout, color: Colors.redAccent)),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(user),
            const SizedBox(height: 32),
            _buildStatsSection(),
            const SizedBox(height: 40),
            _buildActionSection(),
            const SizedBox(height: 40),
            _buildRecentOpsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(User user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bienvenue,", style: TextStyle(color: Colors.black38, fontSize: 14)),
            Text(user.displayName ?? "Agent Certifié", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF00963F).withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.verified, color: Color(0xFF00963F), size: 16),
              const SizedBox(width: 8),
              const Text("ID AGENT: CG-BZV-042", style: TextStyle(color: Color(0xFF00963F), fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(child: _buildSmallStatCard("OPÉRATIONS", "142", Icons.auto_graph, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildSmallStatCard("MUTATIONS", "28", Icons.swap_horiz, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildSmallStatCard("SIGNALEMENTS", "03", Icons.warning_amber, Colors.red)),
      ],
    );
  }

  Widget _buildSmallStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x0D000000))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(label, style: const TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ACTIONS RAPIDES", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1, color: Colors.black)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildActionButton("Nouvelle Mutation", Icons.add_business_outlined, const Color(0xFF00963F))),
            const SizedBox(width: 16),
            Expanded(child: _buildActionButton("Générer Certificat", Icons.description_outlined, const Color(0xFF1A1A1A))),
            const SizedBox(width: 16),
            Expanded(child: _buildActionButton("Rapport Mensuel", Icons.assessment_outlined, Colors.black38)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentOpsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0x0D000000))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("DERNIÈRES OPÉRATIONS", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, color: Colors.black)),
              TextButton(onPressed: () {}, child: const Text("Voir tout", style: TextStyle(color: Color(0xFF00963F)))),
            ],
          ),
          const SizedBox(height: 16),
          _buildOpRow("Mutation Parcelle BZV-457", "Validé", "Il y a 10 min"),
          const Divider(height: 32),
          _buildOpRow("Enregistrement Nouveau Titre", "Validé", "Il y a 2h"),
          const Divider(height: 32),
          _buildOpRow("Enregistrement Nouveau Titre", "Validé", "Il y a 2h"),
          const Divider(height: 32),
          _buildOpRow("Modification Propriétaire", "En attente", "Hier"),
        ],
      ),
    );
  }

  Widget _buildOpRow(String title, String status, String time) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.history, size: 18, color: Colors.black45),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
              Text(time, style: const TextStyle(color: Colors.black26, fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: status == "Validé" ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: status == "Validé" ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
