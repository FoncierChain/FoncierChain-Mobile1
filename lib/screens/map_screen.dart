import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/land_service.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Parcel? _selectedParcel;
  final MapController _mapController = MapController();
  List<dynamic> _mapData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getMapData();
    if (mounted) {
      setState(() {
        _mapData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final navService = Provider.of<LandService>(context);
    final bool isDark = navService.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildMap(isDark),
          _buildTopOverlay(isDark),
          _buildSideStats(isDark),
          if (_selectedParcel != null) _buildDetailsPanel(isDark),
          _buildMapControls(isDark),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF00963F)),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(bool isDark) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(-4.2634, 15.2422),
        initialZoom: 15.0,
        onTap: (_, __) => setState(() => _selectedParcel = null),
      ),
      children: [
        TileLayer(
          urlTemplate: isDark 
            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
            : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
        ),
        MarkerLayer(
          markers: _mapData.map((data) {
            final lat = (data['lat'] as num).toDouble();
            final lng = (data['lng'] as num).toDouble();
            return Marker(
              point: LatLng(lat, lng),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedParcel = Parcel(
                      id: data['parcelId']?.toString() ?? data['id']?.toString() ?? 'ID-MIS',
                      ownerName: data['owner'] ?? 'Inconnu',
                      ownerId: 'UID-MAP',
                      city: data['city'] ?? 'Brazzaville',
                      neighborhood: data['neighborhood'] ?? '',
                      address: "${data['neighborhood']}, ${data['city']}",
                      cadastralId: data['cadastralId'] ?? "CAD-${data['parcelId'] ?? data['id']}",
                      area: (data['area'] ?? data['surface'] as num?)?.toDouble() ?? 0.0,
                      price: (data['price'] as num?)?.toDouble() ?? 0.0,
                      usage: data['usage'] ?? 'NA',
                      status: data['status'] ?? 'DRAFT',
                      txId: data['hash'],
                      lastUpdate: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : (data['timestamp'] != null ? DateTime.parse(data['timestamp']) : DateTime.now()),
                    );
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _getStatusColor(data['status']).withOpacity(0.35),
                    border: Border.all(color: _getStatusColor(data['status']), width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      data['status'] == "FINALIZED" ? Icons.verified : Icons.location_on,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'FINALIZED':
        return Colors.green;
      case 'COMMUNITY_VALIDATED':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  Widget _buildTopOverlay(bool isDark) {
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white24 : Colors.black26;

    return Positioned(
      top: 64,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 15)],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher une zone, un ID...",
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF00963F)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: hintColor),
                ),
                style: TextStyle(color: textColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Icon(Icons.filter_list, color: isDark ? Colors.white70 : Colors.black54, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSideStats(bool isDark) {
    final bool isWide = MediaQuery.of(context).size.width > 900;
    if (!isWide) return const SizedBox.shrink();

    final containerColor = isDark ? const Color(0xFF161B22).withOpacity(0.9) : Colors.white.withOpacity(0.9);

    return Positioned(
      left: 24,
      top: 130,
      width: 260,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 40)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("STATISTIQUES CADAS.", style: TextStyle(color: Color(0xFF00963F), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 20),
            _buildMiniStat("12,450", "Parcelles", Icons.home_work, isDark),
            const SizedBox(height: 16),
            _buildMiniStat("98%", "Validées", Icons.verified, isDark),
            const SizedBox(height: 16),
            _buildMiniStat("14", "En litige", Icons.report_problem, isDark),
            const SizedBox(height: 16),
            _buildMiniStat("156", "En attente", Icons.pending_actions, isDark),
            const SizedBox(height: 24),
            Divider(color: isDark ? Colors.white10 : Colors.black12),
            const SizedBox(height: 20),
            Text("FILTRES RAPIDES", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
            const SizedBox(height: 12),
            _buildCheckItem("Zone Résidentielle", true, isDark),
            _buildCheckItem("Zone Commerciale", false, isDark),
            _buildCheckItem("Espaces Verts", true, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: isDark ? Colors.white30 : Colors.black26, size: 16),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
            Text(label, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckItem(String label, bool value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF00963F) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: value ? const Color(0xFF00963F) : (isDark ? Colors.white10 : Colors.black12)),
            ),
            child: value ? const Icon(Icons.check, color: Colors.white, size: 10) : null,
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: value ? (isDark ? Colors.white70 : Colors.black87) : (isDark ? Colors.white24 : Colors.black26), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(bool isDark) {
    final bool isWide = MediaQuery.of(context).size.width > 900;
    final containerColor = isDark ? const Color(0xFF161B22) : Colors.white;

    return Positioned(
      top: isWide ? 130 : null,
      right: isWide ? 24 : 16,
      left: isWide ? null : 16,
      bottom: isWide ? null : 24,
      width: isWide ? 380 : null,
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.4 : 0.1), blurRadius: 40)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "DÉTAILS PARCELLE",
                    style: GoogleFonts.inter(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _selectedParcel = null),
                    icon: Icon(Icons.close, size: 18, color: isDark ? Colors.white38 : Colors.black38),
                    style: IconButton.styleFrom(backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedParcel!.id, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text(
                        "STATUT: VALIDÉ PAR FONCIERCHAIN",
                        style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoTile(Icons.person_outline, "PROPRIÉTAIRE", _selectedParcel!.ownerName, isDark),
                  const SizedBox(height: 16),
                  _buildInfoTile(Icons.square_foot, "SURFACE", "${_selectedParcel!.area} m²", isDark),
                  const SizedBox(height: 16),
                  _buildInfoTile(Icons.info_outline, "USAGE", _selectedParcel!.usage, isDark),
                  const SizedBox(height: 16),
                  _buildInfoTile(Icons.location_on_outlined, "ADRESSE", _selectedParcel!.address, isDark),
                  const SizedBox(height: 24),
                  Divider(color: isDark ? Colors.white10 : Colors.black12),
                  const SizedBox(height: 16),
                  Text("CERTIFICAT NUMÉRIQUE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.grey[100], 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black12)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.description_outlined, color: isDark ? Colors.white38 : Colors.black38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("CERT-45785.pdf", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black87)),
                              Text("Signé par FoncierChain solutions", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 10)),
                            ],
                          ),
                        ),
                        const Icon(Icons.open_in_new, size: 14, color: Color(0xFF00963F)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: const Color(0xFF00963F),
                    ),
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

  Widget _buildInfoTile(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05), 
            borderRadius: BorderRadius.circular(8)
          ),
          child: Icon(icon, color: isDark ? Colors.white38 : Colors.black38, size: 18),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 9, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ],
    );
  }

  Widget _buildMapControls(bool isDark) {
    return Positioned(
      bottom: 24,
      left: 24,
      child: Column(
        children: [
          _buildMapButton(Icons.add, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1), isDark),
          const SizedBox(height: 8),
          _buildMapButton(Icons.remove, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1), isDark),
        ],
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 10)],
        ),
        child: Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black54),
      ),
    );
  }
}
