import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 32),
                  _buildFeaturePortals(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          colors: [const Color(0xFF00963F).withOpacity(0.05), Colors.white],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00963F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Color(0xFF00963F), size: 14),
                const SizedBox(width: 8),
                Text(
                  "PROJET FONCIERCHAIN (CG-01) • ÉQUIPE AFRICHAIN SOLUTIONS",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00963F),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Sécurisez votre\npatrimoine foncier à\nBrazzaville.",
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              "FoncierChain utilise la technologie blockchain de AfriChain solutions pour garantir l'immutabilité des titres de propriété et éliminer la double attribution des parcelles à Brazzaville.",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text("Vérifier une parcelle"),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.black12),
                ),
                child: const Text("Explorer la carte", style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("12,450+", "PARCELLES ENREGISTRÉES", Icons.home_work_outlined)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("100%", "HISTORIQUE IMMUABLE", Icons.history)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("Zéro", "LITIGES DE DOUBLE VENTE", Icons.verified_user_outlined)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00963F).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF00963F), size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePortals(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Row(
            children: [
              Expanded(child: _buildPortalCard("PORTAIL DE VÉRIFICATION", "Accédez instantanément au propriétaire légal actuel et à l'historique complet des transactions d'une parcelle en entrant son identifiant unique.", "Accéder au portail", Icons.search)),
              const SizedBox(width: 24),
              Expanded(child: _buildPortalCard("CARTE INTERACTIVE", "Visualisez le cadastre de Brazzaville en temps réel via AfriChain solutions. Cliquez sur n'importe quelle parcelle pour voir son statut de validation et son certificat numérique.", "Voir la carte", Icons.explore_outlined)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildPortalCard("PORTAIL DE VÉRIFICATION", "Accédez instantanément au propriétaire légal actuel et à l'historique complet des transactions d'une parcelle en entrant son identifiant unique.", "Accéder au portail", Icons.search),
              const SizedBox(height: 24),
              _buildPortalCard("CARTE INTERACTIVE", "Visualisez le cadastre de Brazzaville en temps réel via AfriChain solutions. Cliquez sur n'importe quelle parcelle pour voir son statut de validation et son certificat numérique.", "Voir la carte", Icons.explore_outlined),
            ],
          );
        }
      },
    );
  }

  Widget _buildPortalCard(String title, String desc, String btnText, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              Icon(icon, color: Colors.black87, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            desc,
            style: GoogleFonts.inter(height: 1.6, color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00963F),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(btnText),
          ),
        ],
      ),
    );
  }
}
