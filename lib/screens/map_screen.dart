import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-4.2634, 15.2422), // Brazzaville
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.foncierchain.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(-4.2634, 15.2422),
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5A059).withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFC5A059), width: 2),
                      ),
                      child: const Icon(Icons.location_on, color: Color(0xFFC5A059), size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Overlay Search Bar
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C20),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color(0xFFC5A059)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Rechercher un quartier ou une parcelle...",
                      style: TextStyle(color: Colors.white24, fontSize: 13),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Color(0xFFC5A059),
                    radius: 16,
                    child: Icon(Icons.my_location, color: Colors.black, size: 16),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Info Sheet Preview
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C20),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.home_work_outlined, color: Color(0xFFC5A059), size: 32),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Vue parcelles active", style: TextStyle(color: Color(0xFFC5A059), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(height: 4),
                        Text("Cadastre de Brazzaville", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Exploration immersive du registre foncier", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
