import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/land_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Parcel? _selectedParcel;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildTopOverlay(),
          if (_selectedParcel != null) _buildDetailsPanel(),
          _buildMapControls(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(-4.2634, 15.2422),
        initialZoom: 15.0,
        onTap: (_, __) => setState(() => _selectedParcel = null),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: const LatLng(-4.2634, 15.2422),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedParcel = Parcel(
                      id: "BZV-45785-SECURE",
                      ownerName: "Jean-Paul Makosso",
                      surface: 450.0,
                      address: "Avenue des Armées, Ouenzé",
                      usage: "Résidentiel",
                      hash: "0x892bcf921a83018...3e12",
                      status: "Validé",
                    );
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00963F).withOpacity(0.2),
                    border: Border.all(color: const Color(0xFF00963F), width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.location_on, color: Color(0xFF00963F), size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 24,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher une parcelle ou une zone...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00963F)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    final bool isWide = MediaQuery.of(context).size.width > 900;

    return Positioned(
      top: isWide ? 100 : null,
      right: isWide ? 24 : 16,
      left: isWide ? null : 16,
      bottom: 24,
      width: isWide ? 380 : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0x0D000000))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "DÉTAILS PARCELLE",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black45),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _selectedParcel = null),
                    icon: const Icon(Icons.close, size: 18),
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFFF8FAFC)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedParcel!.id, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                        "STATUT: VALIDÉ BLOCKCHAIN",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoTile(Icons.person_outline, "PROPRIÉTAIRE", _selectedParcel!.ownerName),
                  const SizedBox(height: 16),
                  _buildInfoTile(Icons.square_foot, "SURFACE", "${_selectedParcel!.surface} m²"),
                  const SizedBox(height: 16),
                  _buildInfoTile(Icons.info_outline, "USAGE", _selectedParcel!.usage),
                  const SizedBox(height: 16),
                  _buildInfoTile(Icons.location_on_outlined, "ADRESSE", _selectedParcel!.address),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text("CERTIFICAT NUMÉRIQUE", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined, color: Colors.black54),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("CERT-45785.pdf", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text("Signé par AfriChain solutions", style: TextStyle(color: Colors.black38, fontSize: 10)),
                            ],
                          ),
                        ),
                        const Icon(Icons.open_in_new, size: 14, color: Colors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                    child: const Text("Générer un extrait officiel"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.black54, size: 18),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A1A))),
          ],
        ),
      ],
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      bottom: 24,
      left: 24,
      child: Column(
        children: [
          _buildMapButton(Icons.add, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
          const SizedBox(height: 8),
          _buildMapButton(Icons.remove, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
          const SizedBox(height: 16),
          _buildMapButton(Icons.my_location, () {}),
        ],
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}
