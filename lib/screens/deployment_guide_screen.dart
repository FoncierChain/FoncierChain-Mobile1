import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeploymentGuideScreen extends StatelessWidget {
  const DeploymentGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("GUIDE DE DÉPLOIEMENT", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSection(
              "1. PRÉREQUIS",
              "Avant de commencer, assurez-vous d'avoir installé :\n• Docker et Docker Compose\n• Go (version 1.20+)\n• Node.js (version 20+)\n• Python (version 3.10+)",
            ),
            const SizedBox(height: 32),
            _buildSection(
              "2. CONFIGURATION BLOCKCHAIN",
              "Nous utilisons 'fabric-samples' pour simuler le réseau localement.\n\n1. Téléchargez fabric-samples :\n   curl -sSL https://bit.ly/2ysbOFE | bash -s\n\n2. Accédez au répertoire test-network :\n   cd fabric-samples/test-network\n\n3. Démarrez le réseau :\n   ./network.sh up createChannel -c fancierchannel\n\n4. Déployez le chaincode (Go) :\n   ./network.sh deployCC -ccn land -ccp ../../../chaincode/land -ccl go",
              isCode: true,
            ),
            const SizedBox(height: 32),
            _buildSection(
              "3. BASE DE DONNÉES MYSQL",
              "Le projet utilise Docker Compose pour orchestrer le Backend et la Database.\n\n1. Démarrez les services :\n   docker-compose up --build -d\n\n2. Appliquez les migrations Django :\n   docker-compose exec web python backend/manage.py migrate",
              isCode: true,
            ),
            const SizedBox(height: 32),
            _buildSection(
              "4. VARIABLES D'ENVIRONNEMENT",
              "Configurez votre fichier .env :\n• MYSQL_DATABASE=fancierchain\n• MYSQL_USER=root\n• MYSQL_PASSWORD=password\n• FABRIC_CHANNEL_NAME=fancierchannel\n• FABRIC_CHAINCODE_NAME=land",
              isCode: true,
            ),
            const SizedBox(height: 32),
            _buildSection(
              "5. ACCÈS AUX SERVICES",
              "• Django REST API : http://localhost:8000/api/v1/\n• Frontend Web : http://localhost:3000/\n• Documentation API : Intégrée au Help Center",
            ),
            const SizedBox(height: 48),
            _buildFooter(),
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
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Procédure de Déploiement Local",
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          "Ce guide explique comment déployer l'intégralité de la plateforme FoncierChain incluant le Backend Django, MySQL et le Smart Contract Hyperledger Fabric.",
          style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, {bool isCode = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00963F),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Text(
            content,
            style: isCode 
              ? GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.cyan, height: 1.6)
              : const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "REMARQUE : Le déploiement blockchain nécessite la configuration des profils de connexion (connection-org1.json) dans 'backend/core/'.",
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
