import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  Uint8List? _idRecto;
  Uint8List? _idVerso;
  bool _isLoading = false;

  Future<void> _pickImage(bool isRecto) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.first.bytes != null) {
      setState(() {
        if (isRecto) _idRecto = result.files.first.bytes;
        else _idVerso = result.files.first.bytes;
      });
    }
  }

  void _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs")));
      return;
    }

    if (_idRecto == null || _idVerso == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez importer les photos de votre pièce d'identité")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final service = Provider.of<LandService>(context, listen: false);
      await service.registerOwner(
        username: _nameController.text, 
        phone: _phoneController.text, 
        email: _emailController.text,
        password: _passwordController.text,
        idRecto: base64Encode(_idRecto!),
        idVerso: base64Encode(_idVerso!),
      );
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Inscription Réussie"),
            content: const Text("Votre demande d'inscription a été reçue. Veuillez patienter pour la validation de vos pièces d'identité."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to Login
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<LandService>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text("Inscription Propriétaire", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rejoignez le registre transparent",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "En tant que propriétaire, sécurisez vos titres sur la blockchain FoncierChain.",
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black54),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nom Complet",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Numéro de Téléphone (+242)",
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mot de passe",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "PIÈCE D'IDENTITÉ (CNI / PASSEPORT)",
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white38 : Colors.black38),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildIdPicker("RECTO", _idRecto, () => _pickImage(true), isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildIdPicker("VERSO", _idVerso, () => _pickImage(false), isDark)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("S'ENREGISTRER"),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                "Le KYC (Vérification d'identité) sera requis\naprès cette étape.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white24 : Colors.black26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdPicker(String label, Uint8List? image, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: image != null ? const Color(0xFF009543) : (isDark ? Colors.white10 : Colors.black12)),
          image: image != null ? DecorationImage(image: MemoryImage(image), fit: BoxFit.cover) : null,
        ),
        child: image == null ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo_outlined, size: 24, color: Colors.grey),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ) : null,
      ),
    );
  }
}
