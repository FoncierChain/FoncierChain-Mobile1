import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';

class SignalementScreen extends StatefulWidget {
  final String? prefilledParcelId;
  const SignalementScreen({super.key, this.prefilledParcelId});

  @override
  State<SignalementScreen> createState() => _SignalementScreenState();
}

class _SignalementScreenState extends State<SignalementScreen> {
  final _idController = TextEditingController();
  final _cadastralController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledParcelId != null) {
      _idController.text = widget.prefilledParcelId!;
    }
  }

  void _handleSignal() async {
    if ((_idController.text.isEmpty && _cadastralController.text.isEmpty) || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir l'ID de parcelle et la raison.")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final service = Provider.of<LandService>(context, listen: false);
      await service.signalFraud(
        _idController.text.isNotEmpty ? _idController.text : null,
        _cadastralController.text.isNotEmpty ? _cadastralController.text : null,
        _reasonController.text,
      );
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Signalement Transmis"),
            content: const Text("La parcelle a été mise sous séquestre blockchain. Nos agents vont enquêter sur ce litige."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
            ],
          ),
        ).then((_) {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<LandService>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Signalement de Fraude"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Attention: Tout signalement abusif est passible de poursuites judiciaires conformément à la loi foncière.",
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: "ID de la Parcelle",
                prefixIcon: Icon(Icons.pin_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text("OU", style: TextStyle(color: Colors.grey, fontSize: 10))),
            const SizedBox(height: 16),
            TextField(
              controller: _cadastralController,
              decoration: const InputDecoration(
                labelText: "Numéro Cadastral",
                prefixIcon: Icon(Icons.grid_3x3),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Motif du litige / Description de la fraude",
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.message_outlined),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignal,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("PROVOQUER LE SÉQUESTRE BLOCKCHAIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
