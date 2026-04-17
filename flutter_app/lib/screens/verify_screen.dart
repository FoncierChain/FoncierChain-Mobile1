import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';
import 'package:intl/intl.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _controller = TextEditingController();
  Parcel? _result;
  bool _isLoading = false;
  bool _searched = false;

  void _handleSearch() async {
    if (_controller.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _searched = true;
    });

    final service = Provider.of<LandService>(context, listen: false);
    final parcel = await service.verifyParcel(_controller.text);

    setState(() {
      _result = parcel;
      _isLoading = false;
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
              const Text(
                "Vérification de Titre",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                "Entrez l'ID cadastral national pour vérifier le propriétaire légal.",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildSearchBox(),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Color(0xFFC5A059)))
              else if (_result != null)
                _buildParcelDetails(_result!)
              else if (_searched)
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Color(0xFFC5A059)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "ex: BZV-45785-SECURE",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white24),
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
          ),
          ElevatedButton(
            onPressed: _handleSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5A059),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text("VÉRIFIER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelDetails(Parcel p) {
    return Column(
      children: [
        _buildMainCard(p),
        const SizedBox(height: 24),
        _buildHistorySection(p.id),
      ],
    );
  }

  Widget _buildMainCard(Parcel p) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFC5A059).withOpacity(0.15), Colors.transparent],
              ),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ID PARCELLE", style: TextStyle(color: Color(0xFFC5A059), fontSize: 10, fontWeight: FontWeight.bold)),
                    Text(p.id, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: const Text("SÉCURISÉ", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailRow(Icons.person, "Propriétaire Actuel", p.ownerName, isMain: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem("Surface", "${p.surface} m²")),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoItem("Usage", p.usage)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoItem("Adresse Complète", p.address, fullWidth: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isMain = false}) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: const Color(0xFFC5A059).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFFC5A059)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: isMain ? 16 : 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHistorySection(String parcelId) {
    final service = Provider.of<LandService>(context, listen: false);
    return StreamBuilder<List<TransactionHistory>>(
      stream: service.getHistory(parcelId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final history = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 16),
              child: Text("HORS DU REGISTRE / ÉVOLUTION", style: TextStyle(color: Color(0xFFC5A059), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            ...history.map((h) => _buildHistoryTile(h)),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTile(TransactionHistory h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: const Color(0xFFC5A059).withOpacity(0.3), width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text(DateFormat('dd MMM yyyy').format(h.date).toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFC5A059).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(h.type.toUpperCase(), style: const TextStyle(color: Color(0xFFC5A059), fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.white),
              children: [
                const TextSpan(text: "De "),
                TextSpan(text: h.previousOwner, style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: " vers "),
                TextSpan(text: h.newOwner, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC5A059))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.white10, size: 64),
            SizedBox(height: 16),
            Text("Aucune parcelle trouvée", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.bold)),
            Text("Vérifiez l'ID cadastral et réessayez.", style: TextStyle(color: Colors.white24, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
