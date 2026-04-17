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
            "Application mobile citoyenne.",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36),
          ),
          const SizedBox(height: 12),
          Text(
            "Vérifiez instantanément la propriété d'un terrain à Brazzaville.",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: const Color(0xFF00963F), height: 1.2),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              "Sécurisez votre patrimoine foncier grâce à la technologie blockchain de AfriChain solutions. Éliminez la double attribution des parcelles en un clic.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54, height: 1.6),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: const Text("Vérifier une parcelle"),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  child: const Text("Explorer la carte", style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
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
            child: Icon(icon, color: const Color(0xFF00963F), size: 18),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black38, fontSize: 8),
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
      padding: const EdgeInsets.all(24),
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
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black45),
              ),
              Icon(icon, color: Colors.black87, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(btnText),
          ),
        ],
      ),
    );
  }
}
