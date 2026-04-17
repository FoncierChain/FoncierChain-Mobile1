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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildSecondaryHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0x0D000000))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Système National de Gestion Foncière",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "BRAZZAVILLE • PORTAIL DE VALIDATION",
                style: GoogleFonts.inter(color: Colors.black38, fontSize: 10, letterSpacing: 1),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text("Connecté", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(40),
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
                "VÉRIFICATION DE TITRE FONCIER",
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  const Text("ACCÈS PUBLIC OUVERT", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Entrez l'ID de la parcelle (ex: BZV-45785-SECURE) ou l'adresse...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _handleSearch(),
                  ),
                ),
                ElevatedButton(
                  onPressed: _handleSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00963F),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text("Vérifier le Titre"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "* La base de données est mise à jour en temps réel par les agents certifiés de AfriChain solutions.",
            style: TextStyle(color: Colors.black26, fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelResult(Parcel parcel) {
    return Container(
      padding: const EdgeInsets.all(32),
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
              _buildDetailLabel("ID PARCELLE", parcel.id, isBig: true),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text("AUTHENTIFIÉ", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 48),
          Row(
            children: [
              Expanded(child: _buildDetailLabel("PROPRIÉTAIRE", parcel.ownerName)),
              Expanded(child: _buildDetailLabel("USAGE", parcel.usage)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDetailLabel("SURFACE", "${parcel.surface} m²")),
              Expanded(child: _buildDetailLabel("ADRESSE", parcel.address)),
            ],
          ),
          const Divider(height: 48),
          const Text("HASH DE SÉCURITÉ", style: TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
            child: Text(
              parcel.hash,
              style: GoogleFonts.jetBrainsMono(color: Colors.green, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailLabel(String label, String value, {bool isBig = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: isBig ? 24 : 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildIdleState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 64),
        child: Column(
          children: [
            Icon(Icons.shield_outlined, size: 64, color: Colors.black12),
            const SizedBox(height: 16),
            const Text("En attente de vérification...", style: TextStyle(color: Colors.black26)),
          ],
        ),
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
