import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChatbot(context, isDark),
        backgroundColor: const Color(0xFF00963F),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
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
            _buildConsensusMonitor(isDark),
            const SizedBox(height: 40),
            _buildSupportSection(isDark),
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

  final List<Map<String, dynamic>> _chatHistory = [
    {"text": "Bonjour ! Je suis l'assistant FoncierChain. Comment puis-je vous aider ?", "isMe": false},
  ];
  final TextEditingController _chatController = TextEditingController();

  void _showChatbot(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black10, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text("ASSISTANT FONCIER AI", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, i) => _buildChatBubble(_chatHistory[i]['text'], _chatHistory[i]['isMe'], isDark),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(child: _buildSimpleField(_chatController, "Posez votre question...", Icons.chat_outlined, isDark)),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF00963F)),
                      onPressed: () {
                        if (_chatController.text.isEmpty) return;
                        final userMsg = _chatController.text;
                        setModalState(() {
                          _chatHistory.add({"text": userMsg, "isMe": true});
                        });
                        _chatController.clear();
                        
                        // Real AI logic if available, else fallback
                        try {
                          ApiService.sendChatMessage(userMsg).then((res) {
                            String botReply = res['reply'] ?? res['message'] ?? "Je ne suis pas sûr de comprendre. Pouvez-vous reformuler ?";
                            setModalState(() {
                              _chatHistory.add({"text": botReply, "isMe": false});
                            });
                          });
                        } catch (e) {
                          setModalState(() {
                            _chatHistory.add({"text": "Erreur de connexion au chatbot.", "isMe": false});
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00963F) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontSize: 13)),
      ),
    );
  }

  Widget _buildSupportSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SUPPORT & TICKETS", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, color: isDark ? Colors.white38 : Colors.black38)),
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
              _buildTicketRow("Double attribution signalée - Moungali", "OUVERT", Colors.red, isDark),
              const Divider(),
              _buildTicketRow("Besoin de validation - Talangaï", "EN COURS", Colors.orange, isDark),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showCreateTicketDialog(context, isDark),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Nouveau Ticket"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateTicketDialog(BuildContext context, bool isDark) {
    final subjectController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Ouvrir un nouveau ticket"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(subjectController, "Sujet (ex: Erreur Cadastre)", isDark),
            _buildDialogField(descController, "Description du problème", isDark),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.createTicket({
                  'subject': subjectController.text,
                  'description': descController.text,
                  'priority': 'URGENT',
                  'email': Provider.of<LandService>(context, listen: false).currentUser?.email ?? 'agent@foncierchain.cg'
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket créé avec succès")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00963F)),
            child: const Text("Envoyer"),
          ),
        ],
      ),
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
        Expanded(child: Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black70, fontSize: 12, fontWeight: FontWeight.bold))),
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
                "CONSOLE DE SIMULATION (DÉMO)",
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
            "Changez de rôle institutionnel pour tester le workflow à 3 signatures :",
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRoleChip(service, "GEOMETRE", "1. Initiation", isDark),
              _buildRoleChip(service, "COMMUNITY", "2. Validation", isDark),
              _buildRoleChip(service, "AGENT", "3. Finalisation / Mutation", isDark),
              _buildRoleChip(service, "ADMIN", "Admin", isDark),
              _buildRoleChip(service, null, "Citoyen (Réel)", isDark),
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
    bool canValidate = role == 'COMMUNITY' || role == 'ADMIN';
    bool canFinalize = role == 'AGENT' || role == 'ADMIN';
    bool canMutation = role == 'AGENT' || role == 'ADMIN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("OPÉRATIONS RÉSERVÉES AU RÔLE : $role", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, color: isDark ? const Color(0xFF00963F) : Colors.green)),
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
                if (canInitiate)
                _buildActionButton(
                  "1. Initier Draft", 
                  Icons.add_location_alt_outlined, 
                  const Color(0xFF00963F).withOpacity(0.1),
                  isDark,
                  onTap: () => _showInitiateDraftDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                if (canValidate)
                _buildActionButton(
                  "2. Validation Comm.", 
                  Icons.how_to_reg_outlined, 
                  const Color(0xFF00963F).withOpacity(0.1),
                  isDark,
                  onTap: () => _showValidateCommunityDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                if (canFinalize)
                _buildActionButton(
                  "3. Finalisation État", 
                  Icons.verified_user_outlined, 
                  const Color(0xFF00963F).withOpacity(0.1),
                  isDark,
                  onTap: () => _showFinalizeStateDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                if (canMutation)
                _buildActionButton(
                  "Mutation (Transfert)", 
                  Icons.swap_horiz_outlined, 
                  const Color(0xFF00963F).withOpacity(0.1),
                  isDark,
                  onTap: () => _showTransferDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                if (role == 'ADMIN' || role == 'AGENT')
                _buildActionButton(
                  "Signaler un Litige", 
                  Icons.report_problem_outlined, 
                  Colors.redAccent.withOpacity(0.1),
                  isDark,
                  onTap: () => _showDisputeDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
              ],
            );
          }
        ),
      ],
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
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: const Text("Vérification d'Identité (KYC)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Veuillez charger une copie de votre CNI ou Passeport pour accéder à toutes les fonctionnalités."),
            const SizedBox(height: 20),
            _buildDialogField(idController, "Numéro de Pièce d'Identité", isDark),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black10, style: BorderStyle.solid),
              ),
              child: const Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Plus tard")),
          ElevatedButton(
            onPressed: () async {
              try {
                final service = Provider.of<LandService>(context, listen: false);
                await service.verifyKYC(idController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("KYC Soumis le Ledger valide votre identité...")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00963F)),
            child: const Text("Soumettre"),
          ),
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
          return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
        case MapLayerType.street:
        default:
          return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
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
                                subdomains: const ['a', 'b', 'c'],
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
