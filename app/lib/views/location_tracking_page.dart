// lib/views/location_tracking_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../controllers/location_controller.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LOCATION TRACKING PAGE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Real-time tracking halaman dengan fitur:
/// - Google Maps integration
/// - Live courier location
/// - Distance & ETA display
/// - Auto-update every 5 seconds
/// - Center map controls
class LocationTrackingPage extends StatelessWidget {
  final String orderId;
  final LatLng deliveryAddress;

  LocationTrackingPage({
    super.key,
    required this.orderId,
    required this.deliveryAddress,
  });

  final LocationController locationController = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    // Start tracking when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationController.startTracking(orderId, deliveryAddress);
    });

    return WillPopScope(
      onWillPop: () async {
        locationController.stopTracking();
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Obx(() {
          if (locationController.isLoading.value) {
            return _buildLoadingState();
          }

          return Stack(
            children: [
              // Google Maps
              _buildMap(),

              // Info Cards at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildInfoCards(),
              ),

              // Map Controls (center, zoom)
              Positioned(right: 16, bottom: 200, child: _buildMapControls()),
            ],
          );
        }),
      ),
    );
  }

  /// ═════════════════════════════════════════════════════════════════════════
  /// UI COMPONENTS
  /// ═════════════════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Live Tracking',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFF1F70B2),
      foregroundColor: Colors.white,
      actions: [
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            locationController.startTracking(orderId, deliveryAddress);
          },
          tooltip: 'Refresh Location',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFF1F70B2)),
          SizedBox(height: 16),
          Text(
            'Getting location...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() {
      final userLoc = locationController.userLocation.value;

      if (userLoc == null) {
        return const Center(child: Text('Loading map...'));
      }

      return FlutterMap(
        mapController: locationController.mapController,
        options: MapOptions(
          initialCenter: userLoc,
          initialZoom: 14,
          minZoom: 5,
          maxZoom: 18,
        ),
        children: [
          // OpenStreetMap Tiles
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.fishllet.app',
            maxZoom: 19,
            // Add additional headers to comply with OSM tile usage policy
            additionalOptions: const {
              'attribution': '© OpenStreetMap contributors',
            },
          ),

          // Polyline Layer
          PolylineLayer(
            polylines: [
              if (locationController.polylinePoints.isNotEmpty)
                Polyline(
                  points: locationController.polylinePoints,
                  color: const Color(0xFF1F70B2),
                  strokeWidth: 4,
                  isDotted: true,
                ),
            ],
          ),

          // Markers Layer
          MarkerLayer(markers: locationController.markers),
        ],
      );
    });
  }

  Widget _buildInfoCards() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Order ID
              Text(
                'Order #$orderId',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Distance & ETA Cards
              Row(
                children: [
                  Expanded(child: _buildDistanceCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildETACard()),
                ],
              ),

              const SizedBox(height: 16),

              // Status Card
              _buildStatusCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1F70B2),
              const Color(0xFF1F70B2).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              '${locationController.distance.value.toStringAsFixed(2)} km',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Jarak',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildETACard() {
    return Obx(() {
      final etaMinutes = locationController.eta.value;
      final hours = etaMinutes ~/ 60;
      final minutes = etaMinutes % 60;

      String etaText;
      if (hours > 0) {
        etaText = '${hours}h ${minutes}m';
      } else {
        etaText = '${minutes}m';
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.orange.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.access_time, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              etaText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'ETA',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delivery_dining,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kurir sedang dalam perjalanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pesanan Anda sedang diantar',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, color: Colors.white, size: 8),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return Column(
      children: [
        // Fit bounds button
        FloatingActionButton.small(
          heroTag: 'fitBounds',
          onPressed: () => locationController.fitMapBounds(),
          backgroundColor: Colors.white,
          child: const Icon(Icons.fit_screen, color: Color(0xFF1F70B2)),
        ),
        const SizedBox(height: 8),

        // Center on courier button
        FloatingActionButton.small(
          heroTag: 'centerCourier',
          onPressed: () => locationController.centerOnCourier(),
          backgroundColor: Colors.white,
          child: const Icon(Icons.delivery_dining, color: Color(0xFF1F70B2)),
        ),
        const SizedBox(height: 8),

        // Center on user button
        FloatingActionButton.small(
          heroTag: 'centerUser',
          onPressed: () => locationController.centerOnUser(),
          backgroundColor: Colors.white,
          child: const Icon(Icons.home, color: Colors.green),
        ),
      ],
    );
  }
}
