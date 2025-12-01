// lib/views/delivery_tracking_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/delivery_controller.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// DELIVERY TRACKING PAGE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Halaman untuk tracking delivery real-time dengan 2 marker:
/// 1. Kurir (live update - bergerak)
/// 2. Customer Destination (fixed - tujuan)
///
/// Features:
/// - Live GPS/Network tracking
/// - Distance calculation
/// - ETA estimation
/// - Delivery status updates
class DeliveryTrackingPage extends StatelessWidget {
  final String orderId;
  final LatLng customerLocation;
  final String customerAddress;

  DeliveryTrackingPage({
    super.key,
    required this.orderId,
    required this.customerLocation,
    this.customerAddress = 'Alamat Customer',
  });

  final DeliveryController deliveryController = Get.put(DeliveryController());
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    // Setup destination saat page dibuka
    deliveryController.setDestination(customerLocation, orderId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Delivery Tracking',
              style: TextStyle(fontSize: 18),
            ),
            Obx(
              () => Text(
                'Order #${deliveryController.orderId.value}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2380c4),
        foregroundColor: Colors.white,
        actions: [
          // Toggle tracking button
          Obx(() {
            return IconButton(
              icon: Icon(
                deliveryController.isTracking.value
                    ? Icons.gps_fixed
                    : Icons.gps_not_fixed,
                color: deliveryController.isTracking.value
                    ? Colors.greenAccent
                    : Colors.white,
              ),
              onPressed: () {
                if (deliveryController.isTracking.value) {
                  deliveryController.stopTracking();
                } else {
                  deliveryController.startTracking();
                }
              },
              tooltip: deliveryController.isTracking.value
                  ? 'Stop Tracking'
                  : 'Start Tracking',
            );
          }),
        ],
      ),

      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════
          // OPENSTREETMAP
          // ═══════════════════════════════════════════════════════════════
          Obx(() {
            final courierPos = deliveryController.courierLocation.value;
            final customerPos = deliveryController.destinationLocation.value;

            // Kalau courier position belum ada, tampilkan customer location
            final centerPos =
                courierPos ?? customerPos ?? const LatLng(-6.2088, 106.8456);

            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: centerPos,
                initialZoom: 14.0,
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

                // Marker Layer - 2 Markers
                MarkerLayer(
                  markers: [
                    // MARKER 1: Customer Destination (Fixed - Red)
                    if (customerPos != null)
                      Marker(
                        point: customerPos,
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
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Tujuan',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.home,
                              color: Colors.red,
                              size: 45,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black26),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // MARKER 2: Courier (Live Update - Blue)
                    if (courierPos != null)
                      Marker(
                        point: courierPos,
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
                              child: Obx(
                                () => Text(
                                  deliveryController.locationSource.value,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.delivery_dining,
                              color: Color(0xFF2380c4),
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

                // Polyline Layer - Route line (optional)
                if (courierPos != null && customerPos != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [courierPos, customerPos],
                        color: const Color(0xFF2380c4),
                        strokeWidth: 3,
                        isDotted: true,
                      ),
                    ],
                  ),
              ],
            );
          }),

          // ═══════════════════════════════════════════════════════════════
          // DELIVERY INFO CARD (Bottom)
          // ═══════════════════════════════════════════════════════════════
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Obx(() {
                final courierPos = deliveryController.courierLocation.value;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Delivery Status
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          deliveryController.deliveryStatus.value,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getStatusIcon(
                              deliveryController.deliveryStatus.value,
                            ),
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            deliveryController.deliveryStatus.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Distance & ETA
                    if (courierPos != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Distance
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.straighten,
                              label: 'Jarak',
                              value: deliveryController.distanceText.value,
                              color: const Color(0xFF2380c4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ETA
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.access_time,
                              label: 'Estimasi',
                              value: deliveryController.etaText.value,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Location Details
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Color(0xFF2380c4),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Lokasi Kurir:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lat: ${courierPos.latitude.toStringAsFixed(6)}, '
                              'Lng: ${courierPos.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Source: ${deliveryController.locationSource.value}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                Text(
                                  'Akurasi: ${deliveryController.accuracy.value.toStringAsFixed(1)}m',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Waiting for courier location
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: const [
                            CircularProgressIndicator(color: Color(0xFF2380c4)),
                            SizedBox(height: 12),
                            Text(
                              'Menunggu lokasi kurir...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),

          // ═══════════════════════════════════════════════════════════════
          // TRACKING STATUS BADGE (Top Left)
          // ═══════════════════════════════════════════════════════════════
          Positioned(
            top: 16,
            left: 16,
            child: Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: deliveryController.isTracking.value
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      deliveryController.isTracking.value
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      deliveryController.isTracking.value
                          ? 'Live Tracking'
                          : 'Tracking Off',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ═════════════════════════════════════════════════════════════════════
      // FLOATING ACTION BUTTONS
      // ═════════════════════════════════════════════════════════════════════
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Center map on courier
          FloatingActionButton.small(
            heroTag: 'center_courier',
            onPressed: () {
              if (deliveryController.courierLocation.value != null) {
                mapController.move(
                  deliveryController.courierLocation.value!,
                  15.0,
                );
              }
            },
            backgroundColor: const Color(0xFF2380c4),
            child: const Icon(Icons.delivery_dining, color: Colors.white),
          ),
          const SizedBox(height: 10),

          // Show both markers
          FloatingActionButton.small(
            heroTag: 'fit_bounds',
            onPressed: () {
              final courierPos = deliveryController.courierLocation.value;
              final customerPos = deliveryController.destinationLocation.value;

              if (courierPos != null && customerPos != null) {
                // Calculate bounds
                final bounds = LatLngBounds(
                  LatLng(
                    courierPos.latitude < customerPos.latitude
                        ? courierPos.latitude
                        : customerPos.latitude,
                    courierPos.longitude < customerPos.longitude
                        ? courierPos.longitude
                        : customerPos.longitude,
                  ),
                  LatLng(
                    courierPos.latitude > customerPos.latitude
                        ? courierPos.latitude
                        : customerPos.latitude,
                    courierPos.longitude > customerPos.longitude
                        ? courierPos.longitude
                        : customerPos.longitude,
                  ),
                );

                mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(50),
                  ),
                );
              }
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.zoom_out_map, color: Color(0xFF2380c4)),
          ),

          const SizedBox(height: 10),

          // Simulate courier movement (for testing)
          if (!deliveryController.isTracking.value)
            FloatingActionButton.small(
              heroTag: 'simulate',
              onPressed: () {
                // Simulate courier 500m dari customer
                final destLat = customerLocation.latitude;
                final destLng = customerLocation.longitude;
                final simulatedPos = LatLng(
                  destLat + 0.005, // ~500m utara
                  destLng + 0.005, // ~500m timur
                );

                deliveryController.simulateCourierMovement(simulatedPos);

                Get.snackbar(
                  'Simulation Mode',
                  'Kurir disimulasikan ~700m dari tujuan',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.play_arrow, color: Colors.white),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('Hampir Sampai')) return Colors.green;
    if (status.contains('Dekat')) return Colors.orange;
    if (status.contains('Terkirim')) return Colors.blue;
    return const Color(0xFF2380c4);
  }

  IconData _getStatusIcon(String status) {
    if (status.contains('Hampir Sampai')) return Icons.near_me;
    if (status.contains('Dekat')) return Icons.location_on;
    if (status.contains('Terkirim')) return Icons.check_circle;
    return Icons.local_shipping;
  }
}
