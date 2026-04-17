import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';

class AgentPortalScreen extends StatefulWidget {
  const AgentPortalScreen({super.key});

  @override
  State<AgentPortalScreen> createState() => _AgentPortalScreenState();
}

class _AgentPortalScreenState extends State<AgentPortalScreen> {
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<LandService>(context);
    final user = service.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user != null),
              const SizedBox(height: 32),
              if (user == null)
                _buildLoginCard()
              else
                _buildAgentDashboard(user.displayName ?? "Agent"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool loggedIn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.between,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ESPACE AGENT CERTIFIÉ",
              style: TextStyle(
                color: Color(0xFFC5A059),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              "Gestion du Registre",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (loggedIn)
          IconButton(
            onPressed: () {}, // Implement Logout
            icon: const Icon(Icons.logout, color: Color(0xFF94A3B8)),
          ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFC5A059).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.shield, color: Color(0xFFC5A059), size: 40),
          ),
          const SizedBox(height: 32),
          const Text(
            "Accès Sécurisé",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Seuls les agents certifiés par le Ministère des Affaires Foncières peuvent modifier le registre.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {}, // Implement Login
            icon: const Icon(Icons.login),
            label: const Text("Se connecter avec Google"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5A059),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentDashboard(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIdentityCard(name),
        const SizedBox(height: 32),
        const Text(
          "ACCIONS DISPONIBLES",
          style: TextStyle(color: Color(0xFFC5A059), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: Icons.add_business_outlined,
          title: "Nouvel Enregistrement",
          subtitle: "Créer un titre foncier immuable",
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.swap_horiz,
          title: "Mutation de Titre",
          subtitle: "Transférer la propriété légale",
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.history_edu_outlined,
          title: "Audit du Registre",
          subtitle: "Consulter l'intégrité de la chaîne",
        ),
      ],
    );
  }

  Widget _buildIdentityCard(String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFC5A059),
            radius: 24,
            child: Text(name[0], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("AGENT CERTIFIÉ", style: TextStyle(color: Color(0xFFC5A059), fontSize: 9, fontWeight: FontWeight.bold)),
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC5A059), size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.white24, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white10),
        ],
      ),
    );
  }
}
