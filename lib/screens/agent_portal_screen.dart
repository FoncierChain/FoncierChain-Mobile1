import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22).withOpacity(0.9),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00963F).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00963F).withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.vpn_key_outlined, color: Color(0xFF00963F), size: 32),
                ),
                const SizedBox(height: 32),
                Text(
                  "ACCÈS RESTREINT",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Authentification requise pour les agents assermentés du Cadastre National.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFF00963F))
                else ...[
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 64),
                      backgroundColor: const Color(0xFF00963F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fingerprint, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          "Continuer avec Google",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Besoin d'assistance technique ?",
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                const Divider(color: Colors.white10),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user, color: Colors.white12, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      "PROTOCOLE AFRICHAIN v2.0",
                      style: GoogleFonts.inter(
                        color: Colors.white12,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgentDashboard(User user) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: Text("Console Administrative", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20)),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(user),
            const SizedBox(height: 32),
            _buildStatsSection(),
            const SizedBox(height: 40),
            _buildComplianceTable(),
            const SizedBox(height: 40),
            _buildActionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(User user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF00963F),
          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null ? const Icon(Icons.person, color: Colors.white) : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("AGENT CERTIFIÉ", style: TextStyle(color: Color(0xFF00963F), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text(user.displayName ?? "Session Admin", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        _buildMiniAdminCard("Mutations", "42", Colors.green),
        const SizedBox(width: 12),
        _buildMiniAdminCard("Audits", "128", Colors.blue),
        const SizedBox(width: 12),
        _buildMiniAdminCard("Alertes", "2", Colors.orange),
      ],
    );
  }

  Widget _buildMiniAdminCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("RAPPORT DE CONFORMITÉ DISTRICT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white38, letterSpacing: 1)),
                Icon(Icons.more_horiz, color: Colors.white38, size: 18),
              ],
            ),
          ),
          _buildTableHeader(),
          _buildTableRow("Ouenzé", "1,240", "98.2%", true),
          _buildTableRow("Talangaï", "2,150", "95.5%", true),
          _buildTableRow("Poto-Poto", "890", "99.1%", true),
          _buildTableRow("Moungali", "1,420", "82.4%", false),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white.withOpacity(0.02),
      child: const Row(
        children: [
          Expanded(child: Text("DISTRICT", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold))),
          Expanded(child: Text("TITRES", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold))),
          Expanded(child: Text("SCORE", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold))),
          Text("STATUS", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTableRow(String district, String count, String score, bool isSafe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(district, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(count, style: const TextStyle(color: Colors.white60, fontSize: 12))),
          Expanded(child: Text(score, style: TextStyle(color: isSafe ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold))),
          Icon(
            isSafe ? Icons.check_circle_outline : Icons.error_outline,
            color: isSafe ? Colors.green : Colors.orange,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ACTIONS RAPIDES", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, color: Colors.white38)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  _buildActionButton("Nouvelle Mutation", Icons.add_business_outlined, const Color(0xFF00963F)),
                  const SizedBox(height: 12),
                  _buildActionButton("Générer Certificat", Icons.description_outlined, const Color(0xFF161B22)),
                  const SizedBox(height: 12),
                  _buildActionButton("Rapport Mensuel", Icons.assessment_outlined, const Color(0xFF161B22)),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _buildActionButton("Nouvelle Mutation", Icons.add_business_outlined, const Color(0xFF00963F))),
                const SizedBox(width: 16),
                Expanded(child: _buildActionButton("Générer Certificat", Icons.description_outlined, const Color(0xFF161B22))),
                const SizedBox(width: 16),
                Expanded(child: _buildActionButton("Rapport Mensuel", Icons.assessment_outlined, const Color(0xFF161B22))),
              ],
            );
          }
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
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
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("DERNIÈRES OPÉRATIONS", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, color: Colors.white)),
              TextButton(onPressed: () {}, child: const Text("Voir tout", style: TextStyle(color: Color(0xFF00963F)))),
            ],
          ),
          const SizedBox(height: 16),
          _buildOpRow("Mutation Parcelle BZV-457", "Validé", "Il y a 10 min"),
          const Divider(height: 32, color: Colors.white10),
          _buildOpRow("Enregistrement Nouveau Titre", "Validé", "Il y a 2h"),
          const Divider(height: 32, color: Colors.white10),
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
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.history, size: 18, color: Colors.white38),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              Text(time, style: const TextStyle(color: Colors.white24, fontSize: 11)),
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
