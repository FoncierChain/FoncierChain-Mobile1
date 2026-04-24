import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              "CENTRE D'AIDE & FAQ",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00963F),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Comment pouvons-nous vous aider ?",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 32),
            _buildResourceGrid(),
            const SizedBox(height: 48),
            Text(
              "QUESTIONS FRÉQUENTES",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildFAQSection(),
            const SizedBox(height: 48),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildHelpCard("Guide de démarrage", "Apprenez les bases de la vérification foncière.", Icons.auto_stories_outlined, Colors.blue),
        _buildHelpCard("Concepts Blockchain", "Comprendre l'immuabilité des titres.", Icons.account_tree_outlined, Colors.purple),
        _buildHelpCard("Support Technique", "Problème avec l'identifiant de parcelle ?", Icons.build_circle_outlined, Colors.orange),
        _buildHelpCard("Sécurité & Vie privée", "Comment vos données sont protégées.", Icons.admin_panel_settings_outlined, Colors.green),
      ],
    );
  }

  Widget _buildHelpCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      children: [
        _buildFAQItem("Qu'est-ce qu'un hash blockchain ?", "Un hash est un identifiant unique généré par AfriChain solutions pour garantir qu'un titre n'a jamais été modifié."),
        _buildFAQItem("Comment vérifier ma parcelle ?", "Entrez simplement l'identifiant BZV-XXXX fourni par le cadastre national dans l'onglet vérification."),
        _buildFAQItem("L'application remplace-t-elle le papier ?", "L'application affiche le certificat numérique qui fait foi, mais le titre physique reste la base légale actuelle."),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.all(16),
        collapsedIconColor: Colors.white38,
        iconColor: const Color(0xFF00963F),
        children: [
          Text(answer, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF00963F).withOpacity(0.1), Colors.transparent]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00963F).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent, color: Color(0xFF00963F), size: 40),
          const SizedBox(height: 16),
          const Text("Vous ne trouvez pas la solution ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            "Nos agents certifiés sont disponibles pour vous accompagner dans vos démarches foncières.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00963F),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Contacter un agent"),
          ),
        ],
      ),
    );
  }
}
