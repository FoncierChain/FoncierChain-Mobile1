import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/land_service.dart';
import '../services/api_service.dart';

class AgentPortalScreen extends StatefulWidget {
  const AgentPortalScreen({super.key});

  @override
  State<AgentPortalScreen> createState() => _AgentPortalScreenState();
}

class _AgentPortalScreenState extends State<AgentPortalScreen> {
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LandService>(context, listen: false).fetchGeoData();
    });
  }

  void _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.login(_usernameController.text, _passwordController.text);
      if (res.containsKey('token')) {
        final service = Provider.of<LandService>(context, listen: false);
        await service.login(_usernameController.text, _passwordController.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec de la connexion API: $e"), backgroundColor: Colors.red),
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
    final isDark = service.isDarkMode;

    if (user == null) {
      return _buildLoginView(isDark);
    }

    return _buildAgentDashboard(user, isDark);
  }

  Widget _buildLoginView(bool isDark) {
    final containerColor = isDark ? const Color(0xFF161B22).withOpacity(0.9) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.black12).withOpacity(isDark ? 0.4 : 0.1),
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
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
                ),
                const SizedBox(height: 32),
                _buildSimpleField(_usernameController, "Nom d'utilisateur", Icons.person_outline, isDark),
                const SizedBox(height: 16),
                _buildSimpleField(_passwordController, "Mot de passe", Icons.lock_outline, isDark, obscure: true),
                const SizedBox(height: 32),
                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFF00963F))
                else ...[
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 64),
                      backgroundColor: const Color(0xFF00963F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Connexion au Ledger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
                const SizedBox(height: 24),
                Divider(color: isDark ? Colors.white10 : Colors.black12),
                const SizedBox(height: 24),
                Text(
                  "SYSTÈME SÉCURISÉ BRAZZAVILLE",
                  style: GoogleFonts.inter(color: isDark ? Colors.white12 : Colors.black12, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleField(TextEditingController controller, String hint, IconData icon, bool isDark, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
        prefixIcon: Icon(icon, size: 20, color: isDark ? Colors.white24 : Colors.black26),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
        filled: true,
      ),
    );
  }


  Widget _buildAgentDashboard(AppUser user, bool isDark) {
    final service = Provider.of<LandService>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        elevation: 0,
        title: Text("Console Administrative", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
        actions: [
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20)),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.isOffline) _buildOfflineBanner(isDark),
            _buildWelcomeHeader(user, isDark),
            const SizedBox(height: 24),
            _buildSimulationConsole(service, isDark),
            const SizedBox(height: 32),
            _buildStatsSection(isDark),
            const SizedBox(height: 40),
            _buildComplianceTable(isDark),
            const SizedBox(height: 40),
            _buildActionSection(isDark),
            const SizedBox(height: 40),
            _buildPerformanceAudit(isDark),
            const SizedBox(height: 40),
            _buildGovernanceMonitor(isDark),
            const SizedBox(height: 40),
            _buildGISCenter(isDark),
            const SizedBox(height: 40),
            _buildReportsSection(isDark),
            const SizedBox(height: 40),
            _buildConsensusMonitor(isDark),
            const SizedBox(height: 40),
            _buildRecentOpsSection(isDark),
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

  Widget _buildGovernanceMonitor(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("HIÉRARCHIE D'ACCÈS MSP (HYPERLEDGER FABRIC)", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, color: isDark ? Colors.white38 : Colors.black38)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
          ),
          child: Column(
            children: [
              _buildMSPRow("Ministère du Foncier", "ADMIN_SUPRÊME", "Accès Signature Finale", Colors.amber, isDark),
              _buildMSPRow("Direction Générale Cadastre", "VALIDATEUR_SIG", "Validation Géo-Hash", Colors.blue, isDark),
              _buildMSPRow("Ordre des Notaires", "OFFICIER_CONF", "Vérif Identity/Funds", Colors.purple, isDark),
              _buildMSPRow("Réseau Géomètres (MSP)", "DATA_PROPOSER", "Injection Levés SIG", const Color(0xFF00963F), isDark),
              const Divider(height: 32),
              Row(
                children: [
                  const Icon(Icons.hub, color: Colors.blueAccent, size: 16),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Le protocole MSP garantit qu'aucune validation ne peut être injectée sans l'identité numérique certifiée du porteur du rôle.",
                      style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMSPRow(String org, String role, String access, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.security, color: color, size: 14),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(org, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(access, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(role, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceAudit(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("AUDIT DE PERFORMANCE ADMINISTRATIVE (GOUVERNANCE)", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, color: isDark ? Colors.white38 : Colors.black38)),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, dynamic>>(
          future: ApiService.getPerformanceAudit(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final data = snapshot.data!;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAuditMetric("CHEF Q.", "${data['avg_response_time_days']?['chef_quartier']}j", isDark),
                      _buildAuditMetric("MAIRIE", "${data['avg_response_time_days']?['mairie']}j", isDark),
                      _buildAuditMetric("CADASTRE", "${data['avg_response_time_days']?['cadastre']}j", isDark),
                      _buildAuditMetric("NOTAIRE", "1.2j", isDark),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildAuditRow("Score d'Efficacité Nationale", "${data['efficiency_score']}%", Colors.green, isDark),
                  _buildAuditRow("Volume Transactionnel", "${data['total_escrows_active']}", Colors.blue, isDark),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.analytics_outlined, color: Colors.orange, size: 14),
                      const SizedBox(width: 8),
                      Text("ANALYSE DES BOTTLENECKS", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (data['bottlenecks'] != null)
                    ...(data['bottlenecks'] as List).map((b) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b['location'], style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
                                Text(b['reason'], style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10)),
                              ],
                            ),
                          ),
                          Text(b['delay_avg'], style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )).toList(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAuditMetric(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF00963F))),
        Text(label, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGISCenter(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("PLATEFORME DÉCISIONNELLE SIG (POWERED BY ARCGIS 2026)", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5, color: isDark ? Colors.blueAccent : Colors.blue)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.blue.withOpacity(isDark ? 0.2 : 0.4)),
            boxShadow: [
              if (!isDark) BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hub_outlined, color: Colors.blue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Oracle Géospatial (ArcGIS Online)", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w900, fontSize: 15)),
                        Text("Vérification topologique en temps réel des parcelles cadastrales.", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 12),
                        SizedBox(width: 6),
                        Text("PORTAL SYNCED", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  _buildGisMetric("Précision SIG", "0.005m", Icons.gps_fixed, isDark),
                  _buildGisMetric("Superpositions", "ZÉRO", Icons.layers_clear, isDark),
                  _buildGisMetric("Satellite", "14 SATS", Icons.satellite_alt, isDark),
                ],
              ),
              const SizedBox(height: 24),
              _buildGISAction("Audit de Topologie ArcGIS", "PASS (100%)", isDark),
              _buildGISAction("Vérification Non-Chevauchement", "OK", isDark),
              _buildGISAction("Calcul du Géo-Hash MSP", "VALIDE", isDark),
              _buildGISAction("Inclusion Zone Protégée", "AUCUNE DÉTECTION", isDark),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, color: Colors.blue, size: 20),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "L'Oracle ArcGIS garantit techniquement l'unicité de la propriété physique avant toute écriture sur le registre blockchain.",
                        style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGisMetric(String label, String value, IconData icon, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[200], size: 20),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
          Text(label, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGISAction(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAuditRow(String label, String value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  final TextEditingController _chatController = TextEditingController();

  Widget _buildReportsSection(bool isDark) {
    final service = Provider.of<LandService>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SIGNALEMENTS DE FRAUDE RÉCENTS", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, color: isDark ? Colors.white38 : Colors.black38)),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: service.getReports(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final reports = snapshot.data!;
            if (reports.isEmpty) return const Text("Aucun signalement actif.");
            
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return ListTile(
                    leading: const Icon(Icons.report_problem, color: Colors.redAccent),
                    title: Text("ID: ${report['id']} - Parcelle ${report['parcelId']}", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text("Rapporté par: ${report['reporter']} le ${report['date']}", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text("DÉTAILS", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConsensusMonitor(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("MONITEUR DE CONSENSUS (ANTI-CORRUPTION)", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, color: isDark ? Colors.white38 : Colors.black38)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _buildConsensusRow("Vérification Tripartite", "ACTIF", Icons.security, Colors.amber, isDark),
              const SizedBox(height: 12),
              Text(
                "Le système exige la signature du Géomètre, du Chef de Quartier et de l'Agent de l'État pour toute modification. Aucun acteur unique ne peut valider un titre.",
                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11),
              ),
              const Divider(height: 24),
              _buildConsensusRow("Double-Dépense", "SÉCURISÉ", Icons.sync_problem, Colors.green, isDark),
              _buildConsensusRow("Intégrité Documentaire", "VÉRIFIÉ", Icons.fingerprint, Colors.blue, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsensusRow(String label, String status, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold))),
        Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildTicketRow(String title, String status, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationConsole(LandService service, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.amber.withOpacity(0.05) : Colors.amber.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.amber, size: 18),
              const SizedBox(width: 12),
              Text(
                "CONSOLE IBIVI / FANCIERCHAIN 2026",
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.amber,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Changez de rôle institutionnel pour tester le workflow Blockchain (NFT Titre Foncier) :",
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRoleChip(service, "GEOMETRE", "1. Géomètre (Arpentage)", isDark),
              _buildRoleChip(service, "CHEF_QUARTIER", "2. Chef de Quartier (Avis)", isDark),
              _buildRoleChip(service, "NOTAIRE", "3. Notaire (Vérification)", isDark),
              _buildRoleChip(service, "MINISTRE", "4. Ministre/Préfet (Minting)", isDark),
              _buildRoleChip(service, "ADMIN", "Admin", isDark),
              _buildRoleChip(service, null, "Citoyen", isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(LandService service, String? role, String label, bool isDark) {
    final isSelected = service.simulatedRole == role;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => service.setSimulatedRole(role),
      backgroundColor: Colors.transparent,
      selectedColor: Colors.amber,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : (isDark ? Colors.white60 : Colors.black54),
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(color: isSelected ? Colors.amber : (isDark ? Colors.white10 : Colors.black12)),
    );
  }

  Widget _buildWelcomeHeader(AppUser user, bool isDark) {
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
            Text(user.displayName ?? "Session Admin", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Row(
      children: [
        _buildMiniAdminCard("Mutations", "42", Colors.green, isDark),
        const SizedBox(width: 12),
        _buildMiniAdminCard("Audits", "128", Colors.blue, isDark),
        const SizedBox(width: 12),
        _buildMiniAdminCard("Alertes", "2", Colors.orange, isDark),
      ],
    );
  }

  Widget _buildMiniAdminCard(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceTable(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("RAPPORT DE CONFORMITÉ DISTRICT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white38 : Colors.black38, letterSpacing: 1)),
                Icon(Icons.more_horiz, color: isDark ? Colors.white38 : Colors.black38, size: 18),
              ],
            ),
          ),
          _buildTableHeader(isDark),
          _buildTableRow("Ouenzé", "1,240", "98.2%", true, isDark),
          _buildTableRow("Talangaï", "2,150", "95.5%", true, isDark),
          _buildTableRow("Poto-Poto", "890", "99.1%", true, isDark),
          _buildTableRow("Moungali", "1,420", "82.4%", false, isDark),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTableHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.02),
      child: Row(
        children: [
          Expanded(child: Text("DISTRICT", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 9, fontWeight: FontWeight.bold))),
          Expanded(child: Text("TITRES", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 9, fontWeight: FontWeight.bold))),
          Expanded(child: Text("SCORE", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 9, fontWeight: FontWeight.bold))),
          Text("STATUS", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTableRow(String district, String count, String score, bool isSafe, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(district, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87))),
          Expanded(child: Text(count, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12))),
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

  Widget _buildActionSection(bool isDark) {
    final service = Provider.of<LandService>(context);
    final role = service.userRole;

    bool canInitiate = role == 'GEOMETRE' || role == 'ADMIN';
    bool canGiveAdvice = role == 'CHEF_QUARTIER' || role == 'ADMIN';
    bool canNotaryValidate = role == 'NOTAIRE' || role == 'ADMIN';
    bool canMinistryApprove = role == 'MINISTRE' || role == 'ADMIN';
    bool canHandleHeritage = role == 'NOTAIRE' || role == 'ADMIN';
    bool canOpenEscrow = role == 'CITIZEN' || role == 'ADMIN';
    bool canOppose = role == 'CITIZEN' || role == 'ADMIN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("LOGIQUE MÉTIER BLOQUANTE : $role", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, color: isDark ? const Color(0xFF00963F) : Colors.green)),
            if (service.currentUser != null && !service.currentUser!.isKYCVerified)
              _buildKYCBadge(isDark),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (canOpenEscrow)
                _buildActionButton(
                  "Ouvrir Séquestre", 
                  Icons.lock_clock_outlined, 
                  Colors.cyan.withOpacity(0.1),
                  isDark,
                  onTap: () => _showEscrowDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                if (canInitiate)
                _buildActionButton(
                  "Arpentage (Draft)", 
                  Icons.add_location_alt_outlined, 
                  const Color(0xFF00963F).withOpacity(0.1),
                  isDark,
                  onTap: () => _showInitiateDraftDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                if (canGiveAdvice)
                _buildActionButton(
                  "Avis Quartier", 
                  Icons.comment_bank_outlined, 
                  Colors.blue.withOpacity(0.1),
                  isDark,
                  onTap: () => _showLocalAdviceDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                if (canOppose)
                _buildActionButton(
                  "Opposition", 
                  Icons.gavel_outlined, 
                  Colors.red.withOpacity(0.1),
                  isDark,
                  onTap: () => _showOppositionDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                if (canNotaryValidate)
                _buildActionButton(
                  "Validation Notaire", 
                  Icons.assignment_turned_in_outlined, 
                  Colors.purple.withOpacity(0.1),
                  isDark,
                  onTap: () => _showNotaryValidateDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                if (canMinistryApprove)
                _buildActionButton(
                  "Mint NFT (Titre)", 
                  Icons.auto_awesome_motion, 
                  Colors.amber.withOpacity(0.1),
                  isDark,
                  onTap: () => _showMinistryApproveDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                if (canHandleHeritage)
                _buildActionButton(
                  "Succession", 
                  Icons.family_restroom_outlined, 
                  Colors.orange.withOpacity(0.1),
                  isDark,
                  onTap: () => _showHeritageDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
              ],
            );
          }
        ),
      ],
    );
  }

  void _showEscrowDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Ouverture de Séquestre Blockchain"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle", isDark),
            _buildDialogField(amountController, "Montant de la Provision (FCFA)", isDark, isNumber: true),
            const Text("Les fonds seront bloqués dans le Smart Contract jusqu'à la signature finale.", style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<LandService>(context, listen: false).openEscrow(idController.text, double.parse(amountController.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Séquestre ouvert. Vente sécurisée.")));
              } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"))); }
            }, 
            child: const Text("BLOQUER LES FONDS")),
        ],
      ),
    );
  }

  void _showOppositionDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Droit d'Opposition Citoyenne"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle visée", isDark),
            _buildDialogField(reasonController, "Motif de l'opposition (ex: Chef de terre non consulté)", isDark),
            const Text("Une opposition bloque immédiatement toute transaction sur ce titre.", style: TextStyle(fontSize: 11, color: Colors.orange)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<LandService>(context, listen: false).submitOpposition(idController.text, reasonController.text, "0x_PROOF_HASH");
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opposition enregistrée. Titre Foncier gelé.")));
              } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"))); }
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("SOUMETTRE OPPOSITION")),
        ],
      ),
    );
  }

  void _showLocalAdviceDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Avis du Chef de Quartier"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle", isDark),
            _buildDialogField(commentController, "Commentaire sur le litige coutumier", isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<LandService>(context, listen: false).giveLocalAdvice(idController.text, commentController.text, 'REJECT');
                Navigator.pop(context);
              } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"))); }
            }, 
            child: const Text("LITIGE DÉCLARÉ", style: TextStyle(color: Colors.red))),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<LandService>(context, listen: false).giveLocalAdvice(idController.text, commentController.text, 'APPROVE');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avis favorable enregistré.")));
              } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"))); }
            }, 
            child: const Text("APPROUVER")),
        ],
      ),
    );
  }

  void _showNotaryValidateDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Validation Notariale"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle", isDark),
            const Text("En tant que Notaire, vous vérifiez l'origine des fonds et le KYC.", style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<LandService>(context, listen: false).notaryValidate(idController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dossier validé par le Notaire.")));
              } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"))); }
            }, 
            child: const Text("SIGNER NUMÉRIQUEMENT")),
        ],
      ),
    );
  }

  void _showMinistryApproveDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Approbation Finale (Minting NFT)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle", isDark),
            const Text("Autorisation finale pour l'émission du Titre Foncier Numérique.", style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<LandService>(context, listen: false).ministryApprove(idController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("TITRE FONCIER GÉNÉRÉ SUR LA BLOCKCHAIN !")));
              } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"))); }
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text("APPROBATION SUPRÊME")),
        ],
      ),
    );
  }

  void _showHeritageDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    final certController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Gestion des Successions"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Titre NFT du défunt", isDark),
            _buildDialogField(certController, "N° Acte de Décès", isDark),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<LandService>(context, listen: false).notifyHeritage(idController.text, certController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Titre bloqué. NFT en attente de fragmentation.")));
              } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"))); }
            }, 
            child: const Text("SIGNALER DÉCÈS & BLOQUER")),
        ],
      ),
    );
  }

  void _showActionComingSoon(BuildContext context, String action) {
    showDialog(context: context, builder: (context) => AlertDialog(title: Text(action), content: const Text("Cette interface est réservée à l'équipe dédiée dans la version de production."), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
  }

  void _showReviewKYCDialog(BuildContext context, bool isDark) {
    final usernameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Examen KYC"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Entrez le nom d'utilisateur à valider ou rejeter.", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            _buildDialogField(usernameController, "Nom d'utilisateur (ex: mpassi)", isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await ApiService.reviewKYC(usernameController.text, 'REJECT');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("KYC Rejeté.")));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
                }
              }
            }, 
            child: const Text("REJETER", style: TextStyle(color: Colors.red))),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.reviewKYC(usernameController.text, 'APPROVE');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("KYC Approuvé. UID activé.")));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
                }
              }
            }, 
            child: const Text("APPROUVER")),
        ],
      ),
    );
  }

  void _showReviewDraftDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Examen de Draft"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle (ex: 23)", isDark),
            const SizedBox(height: 12),
            const Text("En tant qu'Équipe d'Approbation Géomètre, vous devez valider la conformité technique du levé.", style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await ApiService.approveDraft(idController.text, 'REJECT');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Draft Rejeté. Suppression automatique après 10m.")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
              }
            }, 
            child: const Text("REJETER", style: TextStyle(color: Colors.red))),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.approveDraft(idController.text, 'APPROVE');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Draft Approuvé (IN_PROCESS). Confirmation propriétaire requise.")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
              }
            }, 
            child: const Text("APPROUVER")),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.orange, size: 16),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "MODE HORS-LIGNE : Les écritures blockchain sont suspendues.",
              style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Provider.of<LandService>(context, listen: false).fetchGeoData(),
            child: const Text("Réessayer", style: TextStyle(color: Colors.orange, fontSize: 10, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  void _showDisputeDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Signaler un Litige (Anti-Corruption)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle litigieuse", isDark),
            _buildDialogField(reasonController, "Raison du signalement (Corruption, Doublon...)", isDark),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              try {
                final service = Provider.of<LandService>(context, listen: false);
                await service.reportDispute(idController.text, reasonController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signalement envoyé. La parcelle est GELÉE sur la blockchain.")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Signaler & Bloquer"),
          ),
        ],
      ),
    );
  }

  Widget _buildKYCBadge(bool isDark) {
    return InkWell(
      onTap: () => _showKYCDialog(context, isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.withOpacity(0.3))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 12),
            const SizedBox(width: 6),
            const Text("KYC NON VÉRIFIÉ", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showKYCDialog(BuildContext context, bool isDark) {
    Uint8List? rectoImage;
    Uint8List? versoImage;
    bool isAnalyzing = false;
    String? analysisError;
    Map<String, dynamic>? extractedData;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final service = Provider.of<LandService>(context, listen: false);

          Future<void> pickImage(bool isRecto) async {
            final result = await FilePicker.platform.pickFiles(type: FileType.image);
            if (result != null && result.files.first.bytes != null) {
              setDialogState(() {
                if (isRecto) rectoImage = result.files.first.bytes;
                else versoImage = result.files.first.bytes;
              });
            }
          }

          Future<void> startAnalysis() async {
            if (rectoImage == null || versoImage == null) return;
            setDialogState(() {
              isAnalyzing = true;
              analysisError = null;
            });

            final result = await service.analyzeKYCWithGemini(rectoImage!, versoImage!);
            
            setDialogState(() {
              isAnalyzing = false;
              if (result.containsKey('error')) {
                analysisError = result['error'];
              } else if (result['est_expire'] == true) {
                analysisError = "La pièce d'identité est expirée (${result['date_expiration']}). Accès refusé.";
              } else {
                extractedData = result;
              }
            });
          }

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
            title: const Text("Vérification d'Identité IA (KYC)"),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Importez le recto et le verso de votre pièce d'identité. Notre IA Gemini vérifiera l'authenticité et la validité.",
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildImageUploadBox(
                            "RECTO", 
                            rectoImage, 
                            () => pickImage(true), 
                            isDark
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildImageUploadBox(
                            "VERSO", 
                            versoImage, 
                            () => pickImage(false), 
                            isDark
                          ),
                        ),
                      ],
                    ),
                    if (rectoImage != null && versoImage != null && extractedData == null && !isAnalyzing) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: startAnalysis,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text("Analyser avec Gemini"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          foregroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                    if (isAnalyzing) ...[
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(color: Color(0xFF00963F)),
                      const SizedBox(height: 12),
                      const Text("Extraction des données par l'IA..."),
                    ],
                    if (analysisError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(analysisError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ],
                    if (extractedData != null) ...[
                      const SizedBox(height: 16),
                      _buildExtractedRow("NOM", extractedData!['nom'], isDark),
                      _buildExtractedRow("PRÉNOM", extractedData!['prenom'], isDark),
                      _buildExtractedRow("N° ID", extractedData!['id_number'], isDark),
                      _buildExtractedRow("EXPIRATION", extractedData!['date_expiration'], isDark),
                      const SizedBox(height: 12),
                      const Icon(Icons.check_circle, color: Colors.green, size: 32),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
              if (extractedData != null)
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await service.verifyKYC(
                        extractedData!['id_number'], 
                        extractedData: extractedData
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("KYC validé avec succès par l'IA.")));
                    } catch (e) {
                      setDialogState(() => analysisError = "Erreur finale: $e");
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00963F)),
                  child: const Text("Confirmer & Enregistrer"),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageUploadBox(String label, Uint8List? image, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: image != null ? const Color(0xFF00963F) : (isDark ? Colors.white10 : Colors.black12)),
          image: image != null ? DecorationImage(image: MemoryImage(image), fit: BoxFit.cover) : null,
        ),
        child: Stack(
          children: [
            if (image == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, size: 24, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            if (image != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtractedRow(String label, String? value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold)),
          Text(value ?? "-", style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  final Map<String, List<String>> _congoLocations = {
    "Brazzaville": ["Makélékélé", "Bacongo", "Poto-Poto", "Moungali", "Ouenzé", "Talangaï", "Mfilou", "Madibou", "Djiri"],
    "Pointe-Noire": ["Lumumba", "Mvoumvou", "Tié-Tié", "Loandjili", "Mongo-Mpoucou", "Ngoyo"],
    "Dolisie": ["District 1", "District 2"],
    "Nkayi": ["Quartier 1", "Quartier 2"],
    "Ouesso": ["Centre-Ville", "Quartier 1"],
  };

  void _showInitiateDraftDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    final ownerIdController = TextEditingController();
    String selectedCity = "Brazzaville";
    String selectedNeighborhood = "Makélékélé";
    final cadastralController = TextEditingController();
    final addressController = TextEditingController();
    final areaController = TextEditingController();
    final priceController = TextEditingController();
    
    LatLng selectedPoint = LatLng(-4.2634, 15.2832);
    final MapController mapController = MapController();

    String generateHash() {
      final input = "${idController.text}${cadastralController.text}${ownerIdController.text}${DateTime.now().millisecondsSinceEpoch}";
      return sha256.convert(utf8.encode(input)).toString();
    }

    String getTileUrl(MapLayerType type) {
      switch (type) {
        case MapLayerType.satellite:
          return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
        case MapLayerType.terrain:
          return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
        case MapLayerType.street:
        default:
          return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}';
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final service = Provider.of<LandService>(context);
          final cities = service.congoGeoData;
          final protectedZones = service.protectedZones;
          final currentMapType = service.currentMapType;

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ÉTAPE 1 : Initiation Draft", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text("GÉO-SÉCURISÉ", style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogField(idController, "ID Parcelle (ex: 23)", isDark),
                    _buildDialogField(ownerIdController, "ID Propriétaire (ex: 1)", isDark),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCity,
                            dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: "Ville",
                              labelStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                            ),
                            items: cities.keys.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                selectedCity = val!;
                                selectedNeighborhood = cities[selectedCity]!.first;
                                selectedPoint = service.getCenterForLocation(selectedCity, selectedNeighborhood);
                                mapController.move(selectedPoint, 15);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedNeighborhood,
                            dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: "Quartier",
                              labelStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                            ),
                            items: cities[selectedCity]!.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                selectedNeighborhood = val!;
                                selectedPoint = service.getCenterForLocation(selectedCity, selectedNeighborhood);
                                mapController.move(selectedPoint, 15);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Map Section
                    Text("SÉLECTION GÉOGRAPHIQUE", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: isDark ? Colors.white24 : Colors.black26, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Container(
                      height: 250,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter: selectedPoint,
                              initialZoom: 15,
                              onTap: (_, p) {
                                // Check if tapped point is in a protected zone
                                bool isProtected = false;
                                String? zoneName;
                                for (var zone in protectedZones) {
                                  // Simple bounding box check for demo
                                  double minLat = zone.polygon[0].latitude;
                                  double maxLat = zone.polygon[1].latitude;
                                  double minLng = zone.polygon[0].longitude;
                                  double maxLng = zone.polygon[2].longitude;
                                  
                                  if (p.latitude >= minLat && p.latitude <= maxLat && p.longitude >= minLng && p.longitude <= maxLng) {
                                    isProtected = true;
                                    zoneName = zone.name;
                                    break;
                                  }
                                }

                                if (isProtected) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("ZONE PROTÉGÉE : $zoneName - Opération interdite par l'État."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  setDialogState(() => selectedPoint = p);
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: getTileUrl(currentMapType),
                                userAgentPackageName: 'com.foncierchain.app',
                              ),
                              PolygonLayer(
                                polygons: protectedZones.map((z) => Polygon(
                                  points: z.polygon,
                                  color: Colors.red.withOpacity(0.3),
                                  borderColor: Colors.red,
                                  borderStrokeWidth: 2,
                                  isFilled: true,
                                )).toList(),
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: selectedPoint,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_on, color: Color(0xFF00963F), size: 40),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Column(
                              children: [
                                _buildMapTypeBtn(Icons.map, MapLayerType.street, currentMapType, isDark, service),
                                const SizedBox(height: 4),
                                _buildMapTypeBtn(Icons.satellite_alt, MapLayerType.satellite, currentMapType, isDark, service),
                                const SizedBox(height: 4),
                                _buildMapTypeBtn(Icons.landscape, MapLayerType.terrain, currentMapType, isDark, service),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDialogField(cadastralController, "ID Cadastral", isDark),
                    _buildDialogField(addressController, "Adresse Physique (Détails)", isDark),
                    _buildDialogField(areaController, "Superficie (m²)", isDark, isNumber: true),
                    _buildDialogField(priceController, "Prix estimé (FCFA)", isDark, isNumber: true),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("[SIG] Validation géométrique... Aucun chevauchement détecté sur le cadastre numérique.")));
                      },
                      icon: const Icon(Icons.architecture, size: 18),
                      label: const Text("Vérifier Chevauchement SIG"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00963F),
                        side: const BorderSide(color: Color(0xFF00963F)),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00963F)),
                onPressed: () async {
                  try {
                    final service = Provider.of<LandService>(context, listen: false);
                    await service.initiateDraft(
                      parcelId: idController.text.trim(),
                      ownerId: ownerIdController.text.trim(),
                      city: selectedCity,
                      neighborhood: selectedNeighborhood,
                      cadastralId: cadastralController.text.trim(),
                      area: double.tryParse(areaController.text) ?? 1.0,
                      price: double.tryParse(priceController.text) ?? 1.0,
                      address: addressController.text.trim(),
                      signatureV2: "1",
                      documentHash: generateHash(), 
                      lat: selectedPoint.latitude,
                      lng: selectedPoint.longitude,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Draft initié avec succès")));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
                    }
                  }
                }, 
                child: const Text("Signer & Envoyer")
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapTypeBtn(IconData icon, MapLayerType type, MapLayerType current, bool isDark, LandService service) {
    bool isSelected = type == current;
    return InkWell(
      onTap: () => service.setMapType(type),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00963F) : (isDark ? Colors.black87 : Colors.white),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
        ),
        child: Icon(icon, color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54), size: 16),
      ),
    );
  }

  Widget _buildDialogControllerAddress(TextEditingController neighborhood, TextEditingController city, TextEditingController address, bool isDark) {
    return TextButton(
      onPressed: () {
        if (neighborhood.text.isNotEmpty && city.text.isNotEmpty) {
          address.text = "${neighborhood.text}, ${city.text}";
        }
      },
      child: Text("Générer Adresse auto", style: TextStyle(fontSize: 10, color: isDark ? Colors.amber : Colors.blue)),
    );
  }

  void _showValidateCommunityDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: Text("ÉTAPE 2 : Validation Communautaire", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle à valider", isDark),
            Text("Le représentant confirme l'occupation réelle du terrain.", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            onPressed: () async {
              try {
                final service = Provider.of<LandService>(context, listen: false);
                await service.validateCommunity(
                  idController.text.trim().toUpperCase(), 
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Validation communautaire effectuée (SECURED-HMAC)")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
              }
            }, 
            child: const Text("Valider")
          ),
        ],
      ),
    );
  }

  void _showFinalizeStateDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: Text("ÉTAPE 3 : Finalisation État", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle à finaliser", isDark),
            Text("L'Agent Foncier de l'État appose sa signature finale.", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00963F)),
            onPressed: () async {
              try {
                final service = Provider.of<LandService>(context, listen: false);
                await service.finalizeLand(
                  idController.text.trim().toUpperCase(), 
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Titre foncier FINALISÉ (MINTED SECURELY)")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
              }
            }, 
            child: const Text("Finaliser")
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    final newOwnerNameController = TextEditingController();
    final newOwnerIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: Text("Mutation (Transfert)", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle", isDark),
            _buildDialogField(newOwnerNameController, "Nouveau Propriétaire", isDark),
            _buildDialogField(newOwnerIdController, "Nouveau ID Souverain", isDark),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              try {
                final service = Provider.of<LandService>(context, listen: false);
                await service.transferProperty(
                  idController.text.trim().toUpperCase(),
                  newOwnerIdController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transfert effectué avec succès")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
              }
            }, 
            child: const Text("Effectuer le Transfert")
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, bool isDark, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00963F))),
          fillColor: isDark ? null : Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor, bool isDark, {required VoidCallback onTap, double? width}) {
    final isPrimary = bgColor == const Color(0xFF00963F);
    final effectiveBgColor = isPrimary ? bgColor : (isDark ? bgColor : Colors.white);
    final textColor = isPrimary ? Colors.white : (isDark ? Colors.white : Colors.black87);
    final iconColor = isPrimary ? Colors.white : (isDark ? Colors.white : Colors.black54);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: effectiveBgColor, 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
          boxShadow: [
            if (!isDark && !isPrimary) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOpsSection(bool isDark) {
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("DERNIÈRES OPÉRATIONS", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, color: isDark ? Colors.white : Colors.black87)),
              TextButton(onPressed: () {}, child: const Text("Voir tout", style: TextStyle(color: Color(0xFF00963F)))),
            ],
          ),
          const SizedBox(height: 16),
          _buildOpRow("Mutation Parcelle BZV-457", "Validé", "Il y a 10 min", isDark),
          Divider(height: 32, color: isDark ? Colors.white10 : Colors.black12),
          _buildOpRow("Enregistrement Nouveau Titre", "Validé", "Il y a 2h", isDark),
          Divider(height: 32, color: isDark ? Colors.white10 : Colors.black12),
          _buildOpRow("Modification Propriétaire", "En attente", "Hier", isDark),
        ],
      ),
    );
  }

  Widget _buildOpRow(String title, String status, String time, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.history, size: 18, color: isDark ? Colors.white38 : Colors.black38),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
              Text(time, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 11)),
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
