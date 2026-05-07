import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';
import 'api_dev_screen.dart';
import 'deployment_guide_screen.dart';
import 'registry_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navService = Provider.of<LandService>(context);
    final isDark = navService.isDarkMode;

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
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            _buildResourceGrid(context, isDark),
            const SizedBox(height: 48),
            Text(
              "QUESTIONS FRÉQUENTES",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white38 : Colors.black38,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildFAQSection(isDark),
            const SizedBox(height: 48),
            _buildContactSection(isDark),
            const SizedBox(height: 60),
            Center(
              child: Text(
                "DÉVELOPPÉ PAR AFRICHAIN SOLUTION",
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white12 : Colors.black12,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceGrid(BuildContext context, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildHelpCard("Protocole Brazzaville", "Guide en 3 étapes : Draft, Validation, Finalisation.", Icons.auto_stories_outlined, Colors.blue, isDark),
        _buildHelpCard("Identité Souveraine", "Comment valider votre certificat X.509.", Icons.fingerprint, Colors.cyan, isDark),
        _buildHelpCard("Rôles & Permissions", "Agent, Géomètre, Communauté : qui fait quoi ?", Icons.people_outline, Colors.orange, isDark),
        _buildHelpCard("Paiements On-Chain", "Processus de sécurisation des fonds d'enchères.", Icons.account_balance_wallet_outlined, Colors.green, isDark),
        _buildHelpCard(
          "API & Intégration", 
          "Documentation technique pour les développeurs tiers.", 
          Icons.code, 
          Colors.amber,
          isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const APIDocScreen())),
        ),
        _buildHelpCard(
          "Déploiement Local", 
          "Procédure d'installation Docker & Blockchain.", 
          Icons.settings_system_daydream_outlined, 
          Colors.blueAccent,
          isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeploymentGuideScreen())),
        ),
        _buildHelpCard(
          "Registre Public", 
          "Consulter le ledger blockchain en temps réel.", 
          Icons.account_balance_wallet_outlined, 
          Colors.greenAccent,
          isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PublicRegistryScreen())),
        ),
      ],
    );
  }

  Widget _buildHelpCard(String title, String subtitle, IconData icon, Color color, bool isDark, {VoidCallback? onTap}) {
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(bool isDark) {
    return Column(
      children: [
        _buildFAQItem("Quel est le rôle du 'Géomètre Agréé' ?", "Le géomètre est le seul autorisé à initier un 'Draft'. Il valide les mesures techniques et l'ID cadastral avant toute soumission sur la blockchain.", isDark),
        _buildFAQItem("Comment signaler une fraude ?", "Utilisez le bouton 'Signalement' sur l'accueil ou la carte. La parcelle passera en statut 'LITIGE' immédiatement sur la blockchain, bloquant toute transaction frauduleuse.", isDark),
        _buildFAQItem("Pourquoi une validation communautaire ?", "Pour résoudre le 'problème de l'oracle', un Représentant Communautaire doit confirmer physiquement l'occupation du terrain afin d'éviter les doubles titres.", isDark),
        _buildFAQItem("Qu'est-ce que le statut 'FINALIZED' ?", "Cela signifie que l'Agent Foncier de l'État a apposé sa signature finale (V1). Le titre est alors immuable et un NFT représentatif est minté.", isDark),
        _buildFAQItem("Comment fonctionnent les enchères ?", "Les enchères sont sécurisées par Hyperledger Fabric. Le transfert de propriété est atomique et ne se produit qu'une fois le paiement finalisé on-chain.", isDark),
        _buildFAQItem("Mes données personnelles sont-elles publiques ?", "Non. FoncierChain utilise le partitionnement des données. Seules les métadonnées de la parcelle sont publiques, votre identité reste souveraine et cryptée.", isDark),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isDark) {
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? null : Border.all(color: Colors.black12),
      ),
      child: ExpansionTile(
        title: Text(question, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        childrenPadding: const EdgeInsets.all(16),
        collapsedIconColor: isDark ? Colors.white38 : Colors.black45,
        iconColor: const Color(0xFF00963F),
        children: [
          Text(answer, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildContactSection(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF00963F).withOpacity(0.1), Colors.transparent]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00963F).withOpacity(0.2)),
        color: isDark ? Colors.transparent : Colors.white,
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent, color: Color(0xFF00963F), size: 40),
          const SizedBox(height: 16),
          Text("Vous ne trouvez pas la solution ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
          const SizedBox(height: 8),
          Text(
            "Nos agents certifiés sont disponibles pour vous accompagner dans vos démarches foncières.",
            textAlign: TextAlign.center,
            style: TextStyle(color: subtitleColor, fontSize: 12),
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
