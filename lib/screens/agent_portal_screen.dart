import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("OPÉRATIONS BLOCKCHAIN", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, color: isDark ? Colors.white38 : Colors.black38)),
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
                  isDark,
                  onTap: () => _showInitiateDraftDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                _buildActionButton(
                  "2. Validation Comm.", 
                  Icons.how_to_reg_outlined, 
                  isDark ? const Color(0xFF161B22) : Colors.white,
                  isDark,
                  onTap: () => _showValidateCommunityDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                _buildActionButton(
                  "3. Finalisation État", 
                  Icons.verified_user_outlined, 
                  isDark ? const Color(0xFF161B22) : Colors.white,
                  isDark,
                  onTap: () => _showFinalizeStateDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
                _buildActionButton(
                  "Mutation (Transfert)", 
                  Icons.swap_horiz_outlined, 
                  isDark ? const Color(0xFF161B22) : Colors.white,
                  isDark,
                  onTap: () => _showTransferDialog(context, isDark),
                  width: isMobile ? double.infinity : 150,
                ),
              ],
            );
          }
        ),
      ],
    );
  }

  void _showInitiateDraftDialog(BuildContext context, bool isDark) {
    final idController = TextEditingController();
    final ownerIdController = TextEditingController(); // This will be the "owner" in the model
    final cityController = TextEditingController(text: "Brazzaville");
    final neighborhoodController = TextEditingController();
    final cadastralController = TextEditingController();
    final addressController = TextEditingController();
    final areaController = TextEditingController();
    final priceController = TextEditingController();

    String generateHash() {
      final input = "${idController.text}${cadastralController.text}${ownerIdController.text}${DateTime.now().millisecondsSinceEpoch}";
      return sha256.convert(utf8.encode(input)).toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        title: Text("ÉTAPE 1 : Initiation Draft", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(idController, "ID Parcelle (ex: 23)", isDark),
              _buildDialogField(ownerIdController, "ID Propriétaire (ex: 1)", isDark),
              _buildDialogField(cityController, "Ville", isDark),
              _buildDialogField(neighborhoodController, "Quartier", isDark),
              _buildDialogField(cadastralController, "ID Cadastral", isDark),
              _buildDialogControllerAddress(neighborhoodController, cityController, addressController, isDark),
              _buildDialogField(addressController, "Adresse Physique", isDark),
              _buildDialogField(areaController, "Superficie (m²)", isDark, isNumber: true),
              _buildDialogField(priceController, "Prix estimé (FCFA)", isDark, isNumber: true),
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
                  parcelId: idController.text.trim(),
                  ownerId: ownerIdController.text.trim(),
                  city: cityController.text.trim(),
                  neighborhood: neighborhoodController.text.trim(),
                  cadastralId: cadastralController.text.trim(),
                  area: double.tryParse(areaController.text) ?? 1.0,
                  price: double.tryParse(priceController.text) ?? 1.0,
                  address: addressController.text.trim(),
                  signatureV2: "1", // According to user model example signatureV2: "1"
                  documentHash: generateHash(), 
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
