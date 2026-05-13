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

    final service = Provider.of<LandService>(context, listen: false);
    final results = await service.searchParcels(_controller.text.trim());

    setState(() {
      _isSearching = false;
      if (service.lastSearchError != null) {
        _error = service.lastSearchError;
      } else if (results.isEmpty) {
        _error = "Aucun titre foncier trouvé pour cette recherche.";
      } else {
        _foundParcels = results;
        if (results.length == 1) {
          _selectedParcel = results.first;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navService = Provider.of<LandService>(context);
    final isDark = navService.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildSecondaryHeader(isDark),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchSection(isDark),
                  const SizedBox(height: 32),
                  if (_isSearching)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF00963F)))
                  else if (_error != null)
                    _buildErrorState()
                  else if (_selectedParcel != null)
                    _buildParcelDetail(_selectedParcel!, isDark)
                  else if (_foundParcels.isNotEmpty)
                    _buildParcelList(isDark)
                  else
                    _buildIdleState(isDark),
                  const SizedBox(height: 48),
                  _buildTrustBadges(isDark),
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
          ),
        ],
      ),
    );
  }


  Widget _buildSecondaryHeader(bool isDark) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final backgroundColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.black12;

    return Container(
      padding: EdgeInsets.fromLTRB(screenWidth < 600 ? 16 : 32, 60, screenWidth < 600 ? 16 : 32, 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: borderColor)),
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
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(bool isDark) {
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;

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
          Text(
            "ENTREZ L'IDENTIFIANT OU L'ADRESSE",
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "ex: BZV-45785 ou Rue Poto-Poto",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00963F)),
              fillColor: isDark ? const Color(0xFF0B0E14) : Colors.grey[50],
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
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

  Widget _buildParcelList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_foundParcels.length} RÉSULTATS TROUVÉS",
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 16),
        ..._foundParcels.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
          ),
          child: ListTile(
            onTap: () => setState(() => _selectedParcel = p),
            title: Text(p.address, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            subtitle: Text(p.id, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.black12),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildParcelDetail(Parcel parcel, bool isDark) {
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
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.green.withOpacity(isDark ? 0.2 : 0.4)),
            boxShadow: [
              if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailLabel("TITRE FONCIER", parcel.id, isDark, isBig: true),
                  _buildStatusBadge(parcel.status),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: isDark ? Colors.white10 : Colors.black12),
              ),
              _buildDetailRow([
                _buildDetailLabel("PROPRIÉTAIRE", parcel.ownerName, isDark),
                _buildDetailLabel("QUARTIER", parcel.neighborhood, isDark),
              ]),
              const SizedBox(height: 24),
              _buildDetailRow([
                _buildDetailLabel("CADASTRE", parcel.cadastralId, isDark),
                _buildDetailLabel("SUPERFICIE", "${parcel.area} m²", isDark),
              ]),
              const SizedBox(height: 24),
              _buildDetailLabel("ADRESSE", parcel.address, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: isDark ? Colors.white10 : Colors.black12),
              ),
              Text("LOGIQUE DE CONFIANCE (DÉPÔT SÉQUESTRE + 5 PHASES)", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 9, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildValidationStep("1. Provision / Séquestre (Escrow)", parcel.escrowAmount != null && parcel.escrowAmount! > 0, parcel.escrowOpenedAt != null ? "Fonds bloqués le ${parcel.escrowOpenedAt!.substring(0, 10)}" : null, isDark),
              _buildValidationStep("2. Avis Local (Chef de Quartier)", parcel.localAdvice != null, parcel.localAdvice, isDark),
              _buildValidationStep("3. Vacance Numérique (30 Jours)", parcel.status == 'FINALIZED' || parcel.status == 'NOTARY_VALIDATED', "Période légale de contestation", isDark),
              _buildValidationStep("4. Validation Authentique (Notaire)", parcel.notarySignature != null, parcel.notarySignature, isDark),
              _buildValidationStep("5. Titre NFT (Ministère / Conservation)", parcel.ministrySignature != null, parcel.ministrySignature, isDark),
              if (parcel.status == 'FROZEN_OPPOSITION') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.gavel, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text("OPPOSITION EN COURS", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("Motif: ${parcel.oppositionReason ?? 'Non spécifié'}", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
              ],
              if (parcel.txId != null) ...[
                const SizedBox(height: 24),
                Text("HASH DE TRANSACTION", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.grey[100])?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: isDark ? null : Border.all(color: Colors.black12),
                  ),
                  child: Text(
                    parcel.txId!,
                    style: GoogleFonts.jetBrainsMono(color: const Color(0xFF00963F), fontSize: 10),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: isDark ? Colors.white10 : Colors.black12),
              ),
              Text("HISTORIQUE DES MUTATIONS", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
              const SizedBox(height: 16),
              FutureBuilder<List<TransactionHistory>>(
                future: Provider.of<LandService>(context, listen: false).getHistory(parcel.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LinearProgressIndicator(color: Color(0xFF00963F)));
                  }
                  final history = snapshot.data ?? [];
                  if (history.isEmpty) {
                    return Text("Aucun historique disponible.", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 12));
                  }
                  return Column(
                    children: history.map((h) => _buildHistoryRow(h, isDark)).toList(),
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
    Color color = Colors.grey;
    String label = status.replaceAll('_', ' ');

    switch (status) {
      case 'FINALIZED':
        color = Colors.green;
        label = "TITRE NFT ÉMIS";
        break;
      case 'ESCROW_OPENED':
        color = Colors.cyan;
        label = "SÉQUESTRE OUVERT";
        break;
      case 'PENDING_OPPOSITION':
        color = Colors.amber;
        label = "VACANCE NUMÉRIQUE (30j)";
        break;
      case 'FROZEN_OPPOSITION':
        color = Colors.red;
        label = "GELÉ (OPPOSITION)";
        break;
      case 'NOTARY_VALIDATED':
        color = Colors.blue[800]!;
        label = "VALIDÉ PAR NOTAIRE";
        break;
      case 'COMMUNITY_VALIDATED':
        color = Colors.purple;
        label = "VALIDÉ (COMMU)";
        break;
      case 'LOCAL_ADVICE_GIVEN':
        color = Colors.blue[300]!;
        label = "AVIS LOCAL DONNÉ";
        break;
      case 'EN_LITIGE':
        color = Colors.orange[900]!;
        label = "EN LITIGE";
        break;
      case 'BLOCKED_FOR_HERITAGE':
        color = Colors.red[900]!;
        label = "SUCCESSION - BLOQUÉ";
        break;
      case 'DRAFT':
        color = Colors.orange;
        label = "DRAFT (ARPENTAGE)";
        break;
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

  Widget _buildValidationStep(String label, bool isSigned, String? signature, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(isSigned ? Icons.check_circle : Icons.radio_button_unchecked, 
               color: isSigned ? Colors.green : (isDark ? Colors.white10 : Colors.black12), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: isSigned ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white24 : Colors.black26), fontSize: 12, fontWeight: FontWeight.bold)),
                if (isSigned && signature != null)
                  Text(signature, style: GoogleFonts.jetBrainsMono(color: isDark ? Colors.white24 : Colors.black26, fontSize: 9), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(TransactionHistory h, bool isDark) {
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
                Text(h.type, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 2),
                Text("${h.previousOwner} → ${h.newOwner}", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11)),
                Text(h.date.toString().substring(0, 16), style: TextStyle(color: isDark ? Colors.white10 : Colors.black12, fontSize: 9)),
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

  Widget _buildDetailLabel(String label, String value, bool isDark, {bool isBig = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: isBig ? 20 : 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }

  Widget _buildTrustBadges(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTrustBadge(Icons.lock_outline, "100% Sécurisé", isDark),
        _buildTrustBadge(Icons.public, "Accès Public", isDark),
        _buildTrustBadge(Icons.auto_awesome, "Zéro Fraude", isDark),
      ],
    );
  }

  Widget _buildTrustBadge(IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: isDark ? Colors.white24 : Colors.black26, size: 24),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildIdleState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, size: 80, color: (isDark ? Colors.white : Colors.black).withOpacity(0.03)),
          const SizedBox(height: 24),
          Text(
            "Prêt pour l'audit instantané",
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Entrez un ID pour commencer la vérification",
            style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 12),
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
