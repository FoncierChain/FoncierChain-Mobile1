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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idNumberController = TextEditingController();
  
  String _gender = 'M';
  String _idType = 'CNI';
  DateTime? _birthDate;
  DateTime? _idIssueDate;
  DateTime? _idExpiryDate;
  
  Uint8List? _idRecto;
  Uint8List? _idVerso;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context, DateTime? initial, Function(DateTime) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => onSelected(picked));
    }
  }

  Future<void> _pickImage(bool isRecto) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        if (isRecto) {
          _idRecto = result.files.single.bytes;
        } else {
          _idVerso = result.files.single.bytes;
        }
      });
    }
  }

  void _handleRegister() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _emailController.text.isEmpty || 
        _phoneController.text.isEmpty || _passwordController.text.isEmpty || _idNumberController.text.isEmpty ||
        _birthDate == null || _idIssueDate == null || _idExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires")));
      return;
    }

    if (_idRecto == null || _idVerso == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez importer les photos Recto/Verso")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final service = Provider.of<LandService>(context, listen: false);
      
      await service.registerOwner(
        username: "${_firstNameController.text.toLowerCase()}_${_lastNameController.text.toLowerCase()}",
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
            content: const Text("Votre compte a été créé. En attente de validation KYC officielle par nos agents."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to Login
                },
                child: const Text("COMPRIS"),
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
              "Identité Numérique FoncierChain",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Vos informations sont protégées et ne servent qu'à la validation de vos titres fonciers.",
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: "Prénom"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: "Nom"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, _birthDate, (d) => _birthDate = d),
                    icon: const Icon(Icons.cake_outlined, size: 18),
                    label: Text(_birthDate == null ? "Date de naissance" : _birthDate!.toIso8601String().substring(0, 10)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                      foregroundColor: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButton<String>(
                    value: _gender,
                    underline: const SizedBox(),
                    onChanged: (v) => setState(() => _gender = v!),
                    items: ['M', 'F'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Téléphone (+242)", prefixIcon: Icon(Icons.phone_outlined)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe", prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              "PIÈCE D'IDENTITÉ ÉTAT CIVIL",
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white38 : Colors.black38),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButton<String>(
                      value: _idType,
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (v) => setState(() => _idType = v!),
                      items: ['CNI', 'PASSEPORT', 'CARTE SEJOUR'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _idNumberController,
                    decoration: const InputDecoration(labelText: "Numéro de pièce"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context, _idIssueDate, (d) => _idIssueDate = d),
                    child: Text(_idIssueDate == null ? "Date d'émission" : "Émis le: ${_idIssueDate!.toIso8601String().substring(0, 10)}", style: const TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context, _idExpiryDate, (d) => _idExpiryDate = d),
                    child: Text(_idExpiryDate == null ? "Date d'expiration" : "Expire le: ${_idExpiryDate!.toIso8601String().substring(0, 10)}", style: const TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildIdPicker("RECTO PIÉCE", _idRecto, () => _pickImage(true), isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildIdPicker("VERSO PIÉCE", _idVerso, () => _pickImage(false), isDark)),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("SOUMETTRE MON DOSSIER", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
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
