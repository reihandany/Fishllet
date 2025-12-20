// lib/views/map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// MAP PAGE (General Location View)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Halaman untuk lihat peta umum dengan fitur:
/// - View current location (GPS/Network)
/// - Single marker (user location)
/// - OpenStreetMap integration
/// - Location source indicator (GPS vs Network)
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LocationController locationController = Get.put(LocationController());
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Automatically get user location when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await locationController.getUserLocation();
      if (locationController.userLocation.value != null && mounted) {
        mapController.move(locationController.userLocation.value!, 15.0);
      }
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Location'),
        backgroundColor: const Color(0xFF1F70B2),
        foregroundColor: Colors.white,
        actions: [
          // Refresh location button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await locationController.getUserLocation();
              if (locationController.userLocation.value != null && mounted) {
                mapController.move(
                  locationController.userLocation.value!,
                  15.0,
                );
              }
            },
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════
          // OPENSTREETMAP
          // ═══════════════════════════════════════════════════════════════
          Obx(() {
            final userPos = locationController.userLocation.value;

            // Default center (Jakarta)
            final centerPos = userPos ?? const LatLng(-6.2088, 106.8456);

            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: centerPos,
                initialZoom: 15.0,
                minZoom: 5.0,
                maxZoom: 18.0,
              ),
              children: [
                // OpenStreetMap Tile Layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.fishllet.app',
                  maxZoom: 19,
                  // Add additional headers to comply with OSM tile usage policy
                  additionalOptions: const {
                    'attribution': '© OpenStreetMap contributors',
                  },
                ),

                // Marker Layer - Single Marker (User Location)
                if (userPos != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: userPos,
                        width: 100,
                        height: 100,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F70B2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'My Location',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF1F70B2),
                              size: 45,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black26),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            );
          }),
        ],
      ),

      // ═════════════════════════════════════════════════════════════════════
      // FLOATING ACTION BUTTONS
      // ═════════════════════════════════════════════════════════════════════
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton.extended(
          heroTag: 'get_location',
          onPressed: () async {
            await locationController.getUserLocation();
            if (locationController.userLocation.value != null && mounted) {
              mapController.move(
                locationController.userLocation.value!,
                15.0,
              );

              Get.snackbar(
                'Location Updated',
                'Your current location has been updated',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF1F70B2),
                colorText: Colors.white,
                icon: const Icon(Icons.check_circle, color: Colors.white),
                duration: const Duration(seconds: 2),
              );
            }
          },
          backgroundColor: const Color(0xFF1F70B2),
          icon: const Icon(Icons.my_location, color: Colors.white),
          label: const Text(
            'Get My Location',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
