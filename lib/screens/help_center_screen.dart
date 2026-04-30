import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_dev_screen.dart';
import 'deployment_guide_screen.dart';

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
        _buildHelpCard("Protocole Brazzaville", "Guide en 3 étapes : Draft, Validation, Finalisation.", Icons.auto_stories_outlined, Colors.blue),
        _buildHelpCard("Identité Souveraine", "Comment valider votre certificat X.509.", Icons.fingerprint, Colors.cyan),
        _buildHelpCard("Rôles & Permissions", "Agent, Géomètre, Communauté : qui fait quoi ?", Icons.people_outline, Colors.orange),
        _buildHelpCard("Paiements On-Chain", "Processus de sécurisation des fonds d'enchères.", Icons.account_balance_wallet_outlined, Colors.green),
        _buildHelpCard(
          "API & Intégration", 
          "Documentation technique pour les développeurs tiers.", 
          Icons.code, 
          Colors.amber,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const APIDocScreen())),
        ),
        _buildHelpCard(
          "Déploiement Local", 
          "Procédure d'installation Docker & Blockchain.", 
          Icons.settings_system_daydream_outlined, 
          Colors.blueAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeploymentGuideScreen())),
        ),
      ],
    );
  }

  Widget _buildHelpCard(String title, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      children: [
        _buildFAQItem("Quel est le rôle du 'Géomètre Agréé' ?", "Le géomètre est le seul autorisé à initier un 'Draft'. Il valide les mesures techniques et l'ID cadastral avant toute soumission sur la blockchain."),
        _buildFAQItem("Pourquoi une validation communautaire ?", "Pour résoudre le 'problème de l'oracle', un Représentant Communautaire doit confirmer physiquement l'occupation du terrain afin d'éviter les doubles titres."),
        _buildFAQItem("Qu'est-ce que le statut 'FINALIZED' ?", "Cela signifie que l'Agent Foncier de l'État a apposé sa signature finale (V1). Le titre est alors immuable et un NFT représentatif est minté."),
        _buildFAQItem("Comment fonctionnent les enchères ?", "Les enchères sont sécurisées par Hyperledger Fabric. Le transfert de propriété est atomique et ne se produit qu'une fois le paiement finalisé on-chain."),
        _buildFAQItem("Mes données personnelles sont-elles publiques ?", "Non. FancierChain utilise le partitionnement des données. Seules les métadonnées de la parcelle sont publiques, votre identité reste souveraine et cryptée."),
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
