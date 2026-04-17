import 'package:flutter/material.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildSearchInput(),
              const SizedBox(height: 24),
              if (_isSearching)
                const Center(child: CircularProgressIndicator(color: Color(0xFFC5A059)))
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
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "VÉRIFICATION CITOYENNE",
          style: TextStyle(color: Color(0xFFC5A059), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        Text(
          "Authentifier un Titre",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Ex (ID): BZV-45785-A",
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFC5A059)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFC5A059)),
            onPressed: _handleSearch,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onSubmitted: (_) => _handleSearch(),
      ),
    );
  }

  Widget _buildParcelResult(Parcel parcel) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFC5A059).withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFC5A059).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Text("STATUT DU TITRE", style: TextStyle(color: Color(0xFFC5A059), fontSize: 9, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("AUTHENTIFIÉ", style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow("Propriétaire", parcel.ownerName),
              _buildDetailRow("Superficie", "${parcel.surface} m²"),
              _buildDetailRow("Usage", parcel.usage),
              _buildDetailRow("Localisation", parcel.address),
              const Divider(color: Colors.white10, height: 40),
              const Text("HASH D'IMMUTABILITÉ (SHA-256)", style: TextStyle(color: Color(0xFFC5A059), fontSize: 9, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  parcel.hash,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "HISTORIQUE DES MUTATIONS",
          style: TextStyle(color: Color(0xFFC5A059), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        _buildHistoryList(parcel.id),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHistoryList(String id) {
    final service = Provider.of<LandService>(context);
    return StreamBuilder<List<TransactionHistory>>(
      stream: service.getHistory(id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("Aucun historique disponible.", style: TextStyle(color: Colors.white24, fontSize: 12));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final tx = snapshot.data![index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.swap_horiz, color: Color(0xFFC5A059), size: 16),
              title: Text("${tx.previousOwner} ➔ ${tx.newOwner}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: Text(tx.date.toString().split(' ')[0], style: const TextStyle(fontSize: 10, color: Colors.white24)),
              trailing: const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
            );
          },
        );
      },
    );
  }

  Widget _buildIdleState() {
    return Column(
      children: [
        const SizedBox(height: 48),
        Opacity(
          opacity: 0.3,
          child: Column(
            children: [
              const Icon(Icons.qr_code_scanner, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                "Entrez un numéro de titre pour vérifier son authenticité dans le registre blockchain de Brazzaville.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
  

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
