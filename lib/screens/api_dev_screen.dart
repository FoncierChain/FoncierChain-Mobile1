import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';

class APIDocScreen extends StatelessWidget {
  const APIDocScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navService = Provider.of<LandService>(context);
    final isDark = navService.isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF0D1117) : Colors.grey[50];
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("API & INTÉGRATION", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 32),
            _buildSectionTitle("CONFIGURATIONS DE BASE"),
            _buildCodeBlock("Base URL: http://localhost:3000/api/v1/\nAuth: Token Authorization (Header: 'Authorization: Token <token>')\nContent-Type: application/json\nArchitecture: Django REST Framework + Hyperledger Fabric Chaincode", isDark),
            const SizedBox(height: 32),
            _buildSectionTitle("1. AUTHENTIFICATION & UTILISATEURS"),
            _buildEndpointDoc(
              "POST /register/",
              "Crée un nouvel utilisateur avec un rôle spécifique.",
              "{\n  \"username\": \"nom_utilisateur\",\n  \"password\": \"mot_de_passe_robuste\",\n  \"email\": \"email@example.com\",\n  \"role\": \"AGENT\" // Options: AGENT, GEOMETRE, COMMUNITY, ADMIN\n}",
              "{\n  \"user_id\": 1,\n  \"username\": \"nom_utilisateur\",\n  \"role\": \"AGENT\",\n  \"token\": \"9944b0...6ee4b\"\n}",
              isDark
            ),
            _buildEndpointDoc(
              "POST /auth/",
              "Récupère le token d'un utilisateur existant.",
              "{\n  \"username\": \"votre_username\",\n  \"password\": \"votre_password\"\n}",
              "{\n  \"token\": \"votre_token_secret\"\n}",
              isDark
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("2. WORKFLOW FONCIER (BLOCKCHAIN)"),
            _buildEndpointDoc(
              "POST /land/draft/",
              "Étape 1: Création du Brouillon (Par le Géomètre).",
              "{\n  \"owner\": \"Nom du Propriétaire\",\n  \"city\": \"Brazzaville\",\n  \"neighborhood\": \"Moungali\",\n  \"area\": 500,\n  \"usage_type\": \"Résidentiel\",\n  \"signatureV2\": \"SIG_GEOMETRE_...\"\n}",
              "{\n  \"status\": \"SUCCESS\",\n  \"txId\": \"trans_hash_...\",\n  \"id\": \"generated_id\"\n}",
              isDark
            ),
            _buildEndpointDoc(
              "PATCH /land/validate/",
              "Étape 2: Validation Communautaire (Par le Chef de Quartier).",
              "{ \"land_id\": \"id_terrain\", \"signature_v3\": \"SIG_CHEF_QUARTIER_...\" }",
              "{ \"status\": \"SUCCESS\", \"message\": \"Validated successfully\" }",
              isDark
            ),
            _buildEndpointDoc(
              "PATCH /land/finalize/",
              "Étape 3: Finalisation Étatique (Par l'Agent Foncier).",
              "{ \"land_id\": \"id_terrain\", \"signature_v1\": \"SIG_AGENT_ETAT_...\" }",
              "{ \"status\": \"SUCCESS\", \"message\": \"Land permanently anchored\" }",
              isDark
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("3. ANALYTIQUES & DONNÉES (DASHBOARD)"),
            _buildEndpointDoc(
              "GET /stats/",
              "Retourne les métriques agrégées pour le tableau de bord.",
              "N/A",
              "{\n  \"total_parcels\": 14832,\n  \"finalized_parcels\": 9241,\n  \"validated_parcels\": 4500,\n  \"draft_parcels\": 1091,\n  \"total_area\": 12450000.5,\n  \"land_usage\": [{\"type\": \"Résidentiel\", \"count\": 1000}]\n}",
              isDark
            ),
            _buildEndpointDoc(
              "GET /land/<land_id>/history/",
              "Récupère l'historique complet (provenance) d'une parcelle.",
              "N/A",
              "{\n  \"land_id\": \"bz-101\",\n  \"history\": [\n    {\"txId\": \"hash\", \"value\": {...}, \"timestamp\": \"...\"}\n  ]\n}",
              isDark
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("4. IDENTITÉ SOUVERAINE & ENCHÈRES"),
            _buildEndpointDoc(
              "POST /identity/verify/",
              "Vérification d'Identité (SSI) via certificat X.509.",
              "{ \"identity_token\": \"base64_cert\" }",
              "{ \"status\": \"VERIFIED\", \"level\": \"Tier 3\" }",
              isDark
            ),
            _buildEndpointDoc(
              "POST /auctions/bid/",
              "Miser sur une enchère de terrain.",
              "{ \"auction_id\": \"auc_1\", \"bidder_id\": \"usr_1\", \"amount\": 1000000 }",
              "{ \"status\": \"SUCCESS\" }",
              isDark
            ),
            const SizedBox(height: 48),
            _buildFooter(isDark),
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
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00963F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text("v1.0.0 Stable", style: TextStyle(color: Color(0xFF00963F), fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Text(
          "FoncierChain - Guide Intégration API",
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: textColor),
        ),
        const SizedBox(height: 12),
        Text(
          "FoncierChain est une plateforme décentralisée pour la gouvernance foncière, combinant l'identité souveraine et l'enregistrement de propriété adossé à la blockchain.",
          style: TextStyle(color: subtitleColor, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF00963F),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCodeBlock(String code, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        code,
        style: GoogleFonts.jetBrainsMono(fontSize: 12, color: isDark ? Colors.cyan : Colors.blueGrey[800], height: 1.6),
      ),
    );
  }

  Widget _buildEndpointDoc(String method, String desc, String payload, String response, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white38 : Colors.black45;
    final labelColor = isDark ? Colors.white24 : Colors.black26;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: method.startsWith("POST") ? Colors.green.withOpacity(0.1) : method.startsWith("PATCH") ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  method.split(" ")[0],
                  style: TextStyle(
                    color: method.startsWith("POST") ? Colors.green : method.startsWith("PATCH") ? Colors.orange : Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(method.split(" ")[1], style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: hintColor, fontSize: 12)),
          const SizedBox(height: 16),
          Text("REQUEST BODY", style: GoogleFonts.inter(fontSize: 9, color: labelColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildCodeBlock(payload, isDark),
          const SizedBox(height: 16),
          Text("SUCCESS RESPONSE", style: GoogleFonts.inter(fontSize: 9, color: labelColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildCodeBlock(response, isDark),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF00963F).withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00963F).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Color(0xFF00963F), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Toutes les opérations d'écriture Land et Auction s'interfacent directement avec le backend FoncierChain via des appels REST sécurisés.",
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
