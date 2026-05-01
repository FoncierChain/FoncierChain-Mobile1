import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
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
        // Note: For demo purposes, we still use LandService state but login via API
        await service.loginWithGoogle(); 
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
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                ),
                const SizedBox(height: 32),
                _buildSimpleField(_usernameController, "Nom d'utilisateur", Icons.person_outline),
                const SizedBox(height: 16),
                _buildSimpleField(_passwordController, "Mot de passe", Icons.lock_outline, obscure: true),
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
                const Divider(color: Colors.white10),
                const SizedBox(height: 24),
                Text(
                  "SYSTÈME SÉCURISÉ BRAZZAVILLE",
                  style: GoogleFonts.inter(color: Colors.white12, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleField(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.white24),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        fillColor: Colors.white.withOpacity(0.05),
        filled: true,
      ),
    );
  }


  Widget _buildAgentDashboard(User user) {
    final service = Provider.of<LandService>(context);
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
            const SizedBox(height: 24),
            _buildSimulationConsole(service),
            const SizedBox(height: 32),
            _buildStatsSection(),
            const SizedBox(height: 40),
            _buildComplianceTable(),
            const SizedBox(height: 40),
            _buildActionSection(),
            const SizedBox(height: 40),
            _buildRecentOpsSection(),
            const SizedBox(height: 60),
            Center(
              child: Text(
                "DÉVELOPPÉ PAR AFRICHAIN SOLUTION",
                style: GoogleFonts.inter(
                  color: Colors.white12,
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

  Widget _buildSimulationConsole(LandService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
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
          const Text(
            "Changez de rôle institutionnel pour tester le workflow à 3 signatures :",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRoleChip(service, "GEOMETRE", "1. Initiation"),
              _buildRoleChip(service, "COMMUNITY", "2. Validation"),
              _buildRoleChip(service, "AGENT", "3. Finalisation / Mutation"),
              _buildRoleChip(service, "ADMIN", "Admin"),
              _buildRoleChip(service, null, "Citoyen (Réel)"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(LandService service, String? role, String label) {
    final isSelected = service.simulatedRole == role;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => service.setSimulatedRole(role),
      backgroundColor: Colors.transparent,
      selectedColor: Colors.amber,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white60,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(color: isSelected ? Colors.amber : Colors.white10),
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
        Text("OPÉRATIONS BLOCKCHAIN", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, color: Colors.white38)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  "1. Initier Draft", 
                  Icons.add_location_alt_outlined, 
                  const Color(0xFF00963F),
                  onTap: () => _showInitiateDraftDialog(context),
                  width: isMobile ? double.infinity : 150,
                ),
                _buildActionButton(
                  "2. Validation Comm.", 
                  Icons.how_to_reg_outlined, 
                  const Color(0xFF161B22),
                  onTap: () => _showValidateCommunityDialog(context),
                  width: isMobile ? double.infinity : 150,
                ),
                _buildActionButton(
                  "3. Finalisation État", 
                  Icons.verified_user_outlined, 
                  const Color(0xFF161B22),
                  onTap: () => _showFinalizeStateDialog(context),
                  width: isMobile ? double.infinity : 150,
                ),
                _buildActionButton(
                  "Mutation (Transfert)", 
                  Icons.swap_horiz_outlined, 
                  const Color(0xFF161B22),
                  onTap: () => _showTransferDialog(context),
                  width: isMobile ? double.infinity : 150,
                ),
              ],
            );
          }
        ),
      ],
    );
  }

  void _showInitiateDraftDialog(BuildContext context) {
    final idController = TextEditingController();
    final ownerController = TextEditingController();
    final ownerIdController = TextEditingController();
    final neighborhoodController = TextEditingController();
    final cadastralController = TextEditingController();
    final addressController = TextEditingController();
    final areaController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("ÉTAPE 1 : Initiation Draft", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(idController, "ID Parcelle (ex: BZV-123)"),
              _buildDialogField(ownerController, "Nom du Propriétaire"),
              _buildDialogField(ownerIdController, "ID Souverain (SSI)"),
              _buildDialogField(neighborhoodController, "Quartier (Brazzaville)"),
              _buildDialogField(cadastralController, "ID Cadastral"),
              _buildDialogField(addressController, "Adresse Physique"),
              _buildDialogField(areaController, "Superficie (m²)", isNumber: true),
              _buildDialogField(priceController, "Prix estimé (FCFA)", isNumber: true),
            ],
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
                  parcelId: idController.text.trim().toUpperCase(),
                  ownerName: ownerController.text.trim(),
                  ownerId: ownerIdController.text.trim(),
                  neighborhood: neighborhoodController.text.trim(),
                  cadastralId: cadastralController.text.trim(),
                  area: double.parse(areaController.text),
                  price: double.parse(priceController.text),
                  usage: "Résidentiel",
                  address: addressController.text.trim(),
                  signatureV2: "SIG_GEOMETRE_${idController.text.toUpperCase()}_CERT",
                  documentHash: "HASH_DOC_INIT_${DateTime.now().millisecondsSinceEpoch}",
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Draft initié avec succès")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
              }
            }, 
            child: const Text("Signer & Envoyer")
          ),
        ],
      ),
    );
  }

  void _showValidateCommunityDialog(BuildContext context) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("ÉTAPE 2 : Validation Communautaire", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle à valider"),
            const Text("Le représentant confirme l'occupation réelle du terrain.", style: TextStyle(color: Colors.white38, fontSize: 12)),
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
                  "SIG_COMMUNITY_CHEF_BZV_${idController.text.toUpperCase()}"
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Validation communautaire effectuée")));
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

  void _showFinalizeStateDialog(BuildContext context) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("ÉTAPE 3 : Finalisation État", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle à finaliser"),
            const Text("L'Agent Foncier de l'État appose sa signature finale.", style: TextStyle(color: Colors.white38, fontSize: 12)),
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
                  "SIG_STATE_AGENT_OFFICIAL_${idController.text.toUpperCase()}"
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Titre foncier FINALISÉ et ancré on-chain")));
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

  void _showTransferDialog(BuildContext context) {
    final idController = TextEditingController();
    final newOwnerNameController = TextEditingController();
    final newOwnerIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Mutation (Transfert)", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(idController, "ID Parcelle"),
            _buildDialogField(newOwnerNameController, "Nouveau Propriétaire"),
            _buildDialogField(newOwnerIdController, "Nouveau ID Souverain"),
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
                  newOwnerNameController.text.trim(),
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

  Widget _buildDialogField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00963F))),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor, {required VoidCallback onTap, double? width}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor, 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
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
