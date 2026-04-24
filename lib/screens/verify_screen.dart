import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _controller = TextEditingController();
  Parcel? _foundParcel;
  bool _isSearching = false;
  String? _error;

  void _handleSearch() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isSearching = true;
      _error = null;
      _foundParcel = null;
    });

    final service = Provider.of<LandService>(context, listen: false);
    final parcel = await service.verifyParcel(_controller.text.trim());

    setState(() {
      _isSearching = false;
      if (parcel == null) {
        _error = "Aucun titre foncier trouvé pour cet identifiant.";
      } else {
        _foundParcel = parcel;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: Column(
        children: [
          _buildSecondaryHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchSection(),
                  const SizedBox(height: 32),
                  if (_isSearching)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF00963F)))
                  else if (_error != null)
                    _buildErrorState()
                  else if (_foundParcel != null)
                    _buildParcelResult(_foundParcel!)
                  else
                    _buildIdleState(),
                  const SizedBox(height: 48),
                  _buildTrustBadges(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryHeader() {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.fromLTRB(screenWidth < 600 ? 16 : 32, 60, screenWidth < 600 ? 16 : 32, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "REGISTRE PUBLIC",
            style: GoogleFonts.inter(
              color: const Color(0xFF00963F),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Vérification Cryptographique",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
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
          const Text(
            "ENTREZ L'IDENTIFIANT DE PARCELLE",
            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "ex: BZV-45785",
              prefixIcon: Icon(Icons.qr_code_2_outlined, color: Color(0xFF00963F)),
            ),
            onSubmitted: (_) => _handleSearch(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSearch,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: const Color(0xFF00963F),
              ),
              child: const Text("Authentifier le Titre"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelResult(Parcel parcel) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailLabel("RÉSULTAT DE L'AUDIT", parcel.id, isBig: true),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 12),
                        SizedBox(width: 6),
                        Text("IMMUABLE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: Colors.white10),
              ),
              _buildDetailRow([
                _buildDetailLabel("PROPRIÉTAIRE", parcel.ownerName),
                _buildDetailLabel("CADASTRE", parcel.address),
              ]),
              const SizedBox(height: 24),
              _buildDetailRow([
                _buildDetailLabel("USAGE", parcel.usage),
                _buildDetailLabel("COORDONNÉES", "BZV-Zone 4"),
              ]),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: Colors.white10),
              ),
              const Text("EMPREINTE NUMÉRIQUE SHA-256", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Text(
                  parcel.hash,
                  style: GoogleFonts.jetBrainsMono(color: const Color(0xFF00963F).withOpacity(0.8), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(List<Widget> children) {
    return Row(
      children: children.map((child) => Expanded(child: child)).toList(),
    );
  }

  Widget _buildDetailLabel(String label, String value, {bool isBig = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: isBig ? 20 : 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildTrustBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTrustBadge(Icons.lock_outline, "100% Sécurisé"),
        _buildTrustBadge(Icons.public, "Accès Public"),
        _buildTrustBadge(Icons.auto_awesome, "Zéro Fraude"),
      ],
    );
  }

  Widget _buildTrustBadge(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white24, size: 24),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildIdleState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.white.withOpacity(0.03)),
          const SizedBox(height: 24),
          const Text(
            "Prêt pour l'audit instantané",
            style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Entrez un ID pour commencer la vérification",
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 16),
          Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
