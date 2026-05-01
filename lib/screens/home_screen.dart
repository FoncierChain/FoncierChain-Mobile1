import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final stats = await ApiService.getStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final navService = Provider.of<LandService>(context);
    final isDark = navService.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF00963F),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHero(isDark),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricGrid(isDark),
                    const SizedBox(height: 32),
                    _buildSectionHeader("OPÉRATIONS RÉCENTES", isDark),
                    const SizedBox(height: 16),
                    _buildRecentActivityList(isDark),
                    const SizedBox(height: 32),
                    _buildSectionHeader("PERFORMANCE BLOCKCHAIN", isDark),
                    const SizedBox(height: 16),
                    _buildBlockchainStatusRow(isDark),
                    const SizedBox(height: 32),
                    _buildFeaturePortals(isDark),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(bool isDark) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final overlayColor = isDark ? const Color(0xFF0B0E14) : Colors.white;
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, screenWidth < 600 ? 60 : 80, 24, 40),
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          image: const NetworkImage("https://images.unsplash.com/photo-1639762681485-074b7f938ba0?q=80&w=2070&auto=format&fit=crop"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(overlayColor.withOpacity(0.8), isDark ? BlendMode.darken : BlendMode.lighten),
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
                    style: GoogleFonts.inter(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Protégez votre patrimoine",
                      style: GoogleFonts.inter(color: textColor, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1)),
                ),
                child: Icon(Icons.qr_code_scanner, color: textColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 56,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black12),
              boxShadow: [
                if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: isDark ? Colors.white38 : Colors.black38, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        Provider.of<LandService>(context, listen: false).setTabIndex(1, searchQuery: val.trim());
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Rechercher un ID ou une adresse...",
                      hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white24 : Colors.black26),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      fillColor: Colors.transparent,
                    ),
                    style: TextStyle(color: textColor, fontSize: 13),
                  ),
                ),
                screenWidth < 400 
                  ? IconButton(
                      icon: const Icon(Icons.check_circle, color: Color(0xFF00963F)),
                      onPressed: () {
                        if (_searchController.text.trim().isNotEmpty) {
                          Provider.of<LandService>(context, listen: false).setTabIndex(1, searchQuery: _searchController.text.trim());
                        }
                      },
                    )
                  : InkWell(
                      onTap: () {
                        if (_searchController.text.trim().isNotEmpty) {
                          Provider.of<LandService>(context, listen: false).setTabIndex(1, searchQuery: _searchController.text.trim());
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00963F),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("Vérifier", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white38 : Colors.black38,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildMetricGrid(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth < 600 ? 1.4 : 1.6,
          children: [
            _buildMetricCard("Titres", _stats?['total_parcels']?.toString() ?? "...", Icons.description_outlined, const Color(0xFF00963F), "+12%", isDark),
            _buildMetricCard("Finalisés", _stats?['finalized_parcels']?.toString() ?? "...", Icons.verified, Colors.blue, "+5%", isDark),
            _buildMetricCard("Surfaces", "${_stats?['total_area']?.toStringAsFixed(0) ?? "..."}", Icons.square_foot, Colors.orange, "+2%", isDark),
            _buildMetricCard("Fiabilité", "${_stats?['reliability'] ?? "..."}%", Icons.security, Colors.purple, "+0.5%", isDark),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, String trend, bool isDark) {
    final isNegativeTrend = trend.startsWith("-");
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
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
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
          ),
          Text(
            label,
            style: GoogleFonts.inter(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(bool isDark) {
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
      ),
      child: Column(
        children: [
          _buildActivityItem("BZV-45785", "Transfert de propriété", "Il y a 12 min", true, isDark),
          _buildActivityItem("BZV-11209", "Vérification publique", "Il y a 45 min", false, isDark),
          _buildActivityItem("BZV-99032", "Enregistrement bloc", "Il y a 2h", true, isDark),
          _buildActivityItem("BZV-67100", "Authentification notifiée", "Il y a 4h", true, isDark),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String id, String type, String time, bool isSuccess, bool isDark) {
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
      title: Text(id, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(type, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11)),
      trailing: Text(time, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
    );
  }

  Widget _buildBlockchainStatusRow(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            _buildStatusItem("3.2k", "TPS", Icons.speed, isDark),
            const SizedBox(width: 8),
            _buildStatusItem("12s", "LATENCE", Icons.timer_outlined, isDark),
            const SizedBox(width: 8),
            _buildStatusItem("100%", "UPTIME", Icons.cloud_done_outlined, isDark),
          ],
        );
      }
    );
  }

  Widget _buildStatusItem(String value, String label, IconData icon, bool isDark) {
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isDark ? Colors.white30 : Colors.black26, size: 16),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
            Text(label, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePortals(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 700;
        final content = [
          _buildPortalCard(
            "PORTAIL DE VÉRIFICATION", 
            "Accédez instantanément au propriétaire légal actuel et à l'historique complet des transactions d'une parcelle en entrant son identifiant unique.", 
            "Accéder au portail", 
            Icons.search,
            isDark
          ),
          if (isWide) const SizedBox(width: 24) else const SizedBox(height: 24),
          _buildPortalCard(
            "CARTE INTERACTIVE", 
            "Visualisez le cadastre de Brazzaville en temps réel via FoncierChain. Cliquez sur n'importe quelle parcelle pour voir son statut de validation et son certificat numérique.", 
            "Voir la carte", 
            Icons.explore_outlined,
            isDark
          ),
        ];

        return Column(
          children: [
            if (isWide) Row(children: content.map((e) => e is SizedBox ? e : Expanded(child: e)).toList())
            else ...content,
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
            const SizedBox(height: 48),
          ],
        );
      },
    );
  }

  Widget _buildPortalCard(String title, String desc, String btnText, IconData icon, bool isDark) {
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isDark ? Colors.white38 : Colors.black38),
              ),
              Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, color: isDark ? Colors.white70 : Colors.black54),
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
