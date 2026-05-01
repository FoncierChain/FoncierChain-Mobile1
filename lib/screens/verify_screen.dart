import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';
import '../services/api_service.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Parcel> _foundParcels = [];
  Parcel? _selectedParcel;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = Provider.of<LandService>(context, listen: false);
      if (service.pendingSearchQuery != null) {
        _controller.text = service.pendingSearchQuery!;
        service.clearPendingSearch();
        _handleSearch();
      }
    });
  }

  void _handleSearch() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isSearching = true;
      _error = null;
      _foundParcels = [];
      _selectedParcel = null;
    });

    try {
      final mapData = await ApiService.getMapData();
      final query = _controller.text.trim().toLowerCase();
      
      final List<Parcel> results = mapData.where((p) => 
        p['parcelId'].toString().toLowerCase().contains(query) || 
        p['owner'].toString().toLowerCase().contains(query) ||
        p['neighborhood'].toString().toLowerCase().contains(query)
      ).map((item) => Parcel(
        id: item['parcelId'] ?? 'ID-MIS',
        ownerName: item['owner'] ?? 'Inconnu',
        ownerId: 'UID-SEARCH',
        city: item['city'] ?? 'Brazzaville',
        neighborhood: item['neighborhood'] ?? '',
        address: "${item['neighborhood']}, ${item['city']}",
        cadastralId: item['cadastralId'] ?? "CAD-${item['parcelId']}",
        area: (item['surface'] as num?)?.toDouble() ?? 0.0,
        price: (item['price'] as num?)?.toDouble() ?? 0.0,
        usage: item['usage'] ?? 'NA',
        status: item['status'] ?? 'DRAFT',
        txId: item['hash'],
        lastUpdate: item['timestamp'] != null ? DateTime.parse(item['timestamp']) : DateTime.now(),
      )).toList();

      setState(() {
        _isSearching = false;
        if (results.isEmpty) {
          _error = "Aucun titre foncier trouvé pour cette recherche.";
        } else {
          _foundParcels = results;
          if (results.length == 1) {
            _selectedParcel = results.first;
          }
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _error = "Erreur de connexion au registre blockchain.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildSecondaryHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                  else if (_selectedParcel != null)
                    _buildParcelDetail(_selectedParcel!)
                  else if (_foundParcels.isNotEmpty)
                    _buildParcelList()
                  else
                    _buildIdleState(),
                  const SizedBox(height: 48),
                  _buildTrustBadges(),
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
            "ENTREZ L'IDENTIFIANT OU L'ADRESSE",
            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "ex: BZV-45785 ou Rue Poto-Poto",
              prefixIcon: Icon(Icons.search, color: Color(0xFF00963F)),
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

  Widget _buildParcelList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_foundParcels.length} RÉSULTATS TROUVÉS",
          style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 16),
        ..._foundParcels.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            onTap: () => setState(() => _selectedParcel = p),
            title: Text(p.address, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text(p.id, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildParcelDetail(Parcel parcel) {
    return Column(
      children: [
        if (_foundParcels.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextButton.icon(
              onPressed: () => setState(() => _selectedParcel = null),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text("Retour aux résultats"),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF00963F)),
            ),
          ),
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
                  _buildDetailLabel("TITRE FONCIER", parcel.id, isBig: true),
                  _buildStatusBadge(parcel.status),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: Colors.white10),
              ),
              _buildDetailRow([
                _buildDetailLabel("PROPRIÉTAIRE", parcel.ownerName),
                _buildDetailLabel("QUARTIER", parcel.neighborhood),
              ]),
              const SizedBox(height: 24),
              _buildDetailRow([
                _buildDetailLabel("CADASTRE", parcel.cadastralId),
                _buildDetailLabel("SUPERFICIE", "${parcel.area} m²"),
              ]),
              const SizedBox(height: 24),
              _buildDetailLabel("ADRESSE", parcel.address),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: Colors.white10),
              ),
              const Text("VALIDATION BLOCKCHAIN", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildValidationStep("Signature V2 (Géomètre)", parcel.signatureV2 != null, parcel.signatureV2),
              _buildValidationStep("Signature V3 (Communauté)", parcel.signatureV3 != null, parcel.signatureV3),
              _buildValidationStep("Signature V1 (État)", parcel.signatureV1 != null, parcel.signatureV1),
              if (parcel.txId != null) ...[
                const SizedBox(height: 24),
                const Text("HASH DE TRANSACTION", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    parcel.txId!,
                    style: GoogleFonts.jetBrainsMono(color: const Color(0xFF00963F), fontSize: 10),
                  ),
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: Colors.white10),
              ),
              Text("HISTORIQUE DES MUTATIONS", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white38)),
              const SizedBox(height: 16),
              FutureBuilder<List<TransactionHistory>>(
                future: Provider.of<LandService>(context, listen: false).getHistory(parcel.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LinearProgressIndicator(color: Color(0xFF00963F)));
                  }
                  final history = snapshot.data ?? [];
                  if (history.isEmpty) {
                    return const Text("Aucun historique disponible.", style: TextStyle(color: Colors.white24, fontSize: 12));
                  }
                  return Column(
                    children: history.map((h) => _buildHistoryRow(h)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.red;
    String label = status;
    if (status == 'FINALIZED') {
      color = Colors.green;
      label = "FINALISÉ";
    } else if (status == 'COMMUNITY_VALIDATED') {
      color = Colors.blue;
      label = "VALIDÉ (COMM)";
    } else if (status == 'DRAFT') {
      color = Colors.orange;
      label = "DRAFT";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildValidationStep(String label, bool isSigned, String? signature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(isSigned ? Icons.check_circle : Icons.radio_button_unchecked, 
               color: isSigned ? Colors.green : Colors.white10, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: isSigned ? Colors.white : Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
                if (isSigned && signature != null)
                  Text(signature, style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 9), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(TransactionHistory h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(color: Color(0xFF00963F), shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                const SizedBox(height: 2),
                Text("${h.previousOwner} → ${h.newOwner}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                Text(h.date.toString().substring(0, 16), style: const TextStyle(color: Colors.white10, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
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
          Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
