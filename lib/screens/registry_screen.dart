import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class PublicRegistryScreen extends StatefulWidget {
  const PublicRegistryScreen({super.key});

  @override
  State<PublicRegistryScreen> createState() => _PublicRegistryScreenState();
}

class _PublicRegistryScreenState extends State<PublicRegistryScreen> {
  List<dynamic> _ledger = [];
  Map<String, dynamic> _metrics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRegistry();
  }

  Future<void> _loadRegistry() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getPublicRegistry();
    if (mounted) {
      setState(() {
        _ledger = data['blockchain_ledger'] ?? [];
        _metrics = data['metrics'] ?? {};
        _isLoading = false;
      });
    }
  }

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
        title: Text("REGISTRE PUBLIC (LEDGER)", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRegistry,
        color: const Color(0xFF00963F),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(isDark),
              const SizedBox(height: 32),
              Text(
                "HISTORIQUE DES BLOCS",
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white38 : Colors.black38, letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Color(0xFF00963F)))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ledger.length,
                  itemBuilder: (context, index) {
                    final block = _ledger[index];
                    return _buildBlockItem(block, isDark);
                  },
                ),
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
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        _buildStatCard("Titres", _metrics['total_titles']?.toString() ?? "...", Colors.green, isDark),
        const SizedBox(width: 12),
        _buildStatCard("Transferts 24h", _metrics['transfers_24h']?.toString() ?? "...", Colors.blue, isDark),
        const SizedBox(width: 12),
        _buildStatCard("Blocs Actifs", _metrics['active_blocks']?.toString() ?? "...", Colors.purple, isDark),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isDark ? Colors.white30 : Colors.black30, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockItem(dynamic block, bool isDark) {
    final blockColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white24 : Colors.black26;
    final timeColor = isDark ? Colors.white12 : Colors.black12;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blockColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black12),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (isDark ? Colors.black : Colors.grey[200])!.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.layers_outlined, color: Color(0xFF00963F), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("BLOC #${block['block_number']}", style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(block['action'], style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(block['tx_id'], style: GoogleFonts.jetBrainsMono(color: subColor, fontSize: 10), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(block['timestamp'])),
                  style: TextStyle(color: timeColor, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
