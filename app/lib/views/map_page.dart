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
class MapPage extends StatelessWidget {
  MapPage({super.key});

  final LocationController locationController = Get.put(LocationController());
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Location'),
        backgroundColor: const Color(0xFF2380c4),
        foregroundColor: Colors.white,
        actions: [
          // Refresh location button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await locationController.getUserLocation();
              if (locationController.userLocation.value != null) {
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
                  userAgentPackageName: 'com.example.app',
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
                                color: const Color(0xFF2380c4),
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
                              color: Color(0xFF2380c4),
                              size: 45,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
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
          
          // ═══════════════════════════════════════════════════════════════
          // LOCATION INFO CARD (Bottom)
          // ═══════════════════════════════════════════════════════════════
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Obx(() {
              final userPos = locationController.userLocation.value;
              
              if (userPos == null) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Location not available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the button below to get your location',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: Color(0xFF2380c4),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2380c4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Latitude: ${userPos.latitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Longitude: ${userPos.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2380c4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2380c4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.gps_fixed,
                              size: 16,
                              color: Color(0xFF2380c4),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'GPS/Network Location',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2380c4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      
      // ═════════════════════════════════════════════════════════════════════
      // FLOATING ACTION BUTTONS
      // ═════════════════════════════════════════════════════════════════════
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Get Location Button
          FloatingActionButton.extended(
            heroTag: 'get_location',
            onPressed: () async {
              await locationController.getUserLocation();
              if (locationController.userLocation.value != null) {
                mapController.move(
                  locationController.userLocation.value!,
                  15.0,
                );
                
                Get.snackbar(
                  'Location Updated',
                  'Your current location has been updated',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF2380c4),
                  colorText: Colors.white,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  duration: const Duration(seconds: 2),
                );
              }
            },
            backgroundColor: const Color(0xFF2380c4),
            icon: const Icon(Icons.my_location, color: Colors.white),
            label: const Text(
              'Get My Location',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          
          // Center Map Button
          Obx(() {
            if (locationController.userLocation.value == null) {
              return const SizedBox.shrink();
            }
            
            return FloatingActionButton.small(
              heroTag: 'center',
              onPressed: () {
                mapController.move(
                  locationController.userLocation.value!,
                  15.0,
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.center_focus_strong,
                color: Color(0xFF2380c4),
              ),
            );
          }),
        ],
      ),
    );
  }
}
