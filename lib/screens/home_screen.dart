import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetricGrid(),
                  const SizedBox(height: 32),
                  _buildSectionHeader("OPÉRATIONS RÉCENTES"),
                  const SizedBox(height: 16),
                  _buildRecentActivityList(),
                  const SizedBox(height: 32),
                  _buildSectionHeader("PERFORMANCE BLOCKCHAIN"),
                  const SizedBox(height: 16),
                  _buildBlockchainStatusRow(),
                  const SizedBox(height: 32),
                  _buildFeaturePortals(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, screenWidth < 600 ? 60 : 80, 24, 40),
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          image: const NetworkImage("https://images.unsplash.com/photo-1639762681485-074b7f938ba0?q=80&w=2070&auto=format&fit=crop"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(const Color(0xFF0B0E14).withOpacity(0.8), BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bienvenue sur FoncierChain",
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Protégez votre patrimoine",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white38, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher un ID ou un hash...",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.white24),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                screenWidth < 400 
                  ? const Icon(Icons.check_circle, color: Color(0xFF00963F))
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00963F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("Vérifier", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white38,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildMetricGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth < 600 ? 1.4 : 1.6,
          children: [
            _buildMetricCard("Titres", "651", Icons.description_outlined, const Color(0xFF00963F), "+12%"),
            _buildMetricCard("Transferts", "32", Icons.swap_horiz, Colors.blue, "-3%"),
            _buildMetricCard("Litiges", "14", Icons.warning_amber_rounded, Colors.red, "+0%"),
            _buildMetricCard("Conformité", "98%", Icons.verified_user_outlined, Colors.purple, "+1.2%"),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, String trend) {
    final isNegativeTrend = trend.startsWith("-");
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              Text(
                trend,
                style: GoogleFonts.inter(
                  color: isNegativeTrend ? Colors.redAccent : Colors.greenAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildActivityItem("BZV-45785", "Transfert de propriété", "Il y a 12 min", true),
          _buildActivityItem("BZV-11209", "Vérification publique", "Il y a 45 min", false),
          _buildActivityItem("BZV-99032", "Enregistrement bloc", "Il y a 2h", true),
          _buildActivityItem("BZV-67100", "Authentification notifiée", "Il y a 4h", true),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String id, String type, String time, bool isSuccess) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSuccess ? Icons.check_circle_outline : Icons.history,
          color: isSuccess ? Colors.green : Colors.blue,
          size: 18,
        ),
      ),
      title: Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(type, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: Text(time, style: const TextStyle(color: Colors.white24, fontSize: 10)),
    );
  }

  Widget _buildBlockchainStatusRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            _buildStatusItem("3.2k", "TPS", Icons.speed),
            const SizedBox(width: 8),
            _buildStatusItem("12s", "LATENCE", Icons.timer_outlined),
            const SizedBox(width: 8),
            _buildStatusItem("100%", "UPTIME", Icons.cloud_done_outlined),
          ],
        );
      }
    );
  }

  Widget _buildStatusItem(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white30, size: 16),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePortals() {
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
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white38),
              ),
              Icon(icon, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
               final index = title.contains("VÉRIFICATION") ? 1 : 2;
               Provider.of<LandService>(context, listen: false).setTabIndex(index);
            },
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
