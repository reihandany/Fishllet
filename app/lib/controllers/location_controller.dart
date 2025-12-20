// lib/controllers/location_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:math' show sqrt, asin;

/// ═══════════════════════════════════════════════════════════════════════════
/// LOCATION CONTROLLER
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Controller untuk handle:
/// - Real-time GPS tracking
/// - Distance calculation
/// - ETA calculation
/// - Google Maps integration
class LocationController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var userLocation = Rx<LatLng?>(null);
  var courierLocation = Rx<LatLng?>(null);
  var distance = 0.0.obs; // in kilometers
  var eta = 0.obs; // in minutes
  var isTrackingEnabled = false.obs;
  
  // Map markers
  var markers = <Marker>[].obs;
  var polylinePoints = <LatLng>[].obs;
  
  // Map Controller
  MapController mapController = MapController();
  
  // Timer for periodic location updates
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionSub;
  
  // Average courier speed (km/h)
  final double averageCourierSpeed = 30.0;

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
  }

  @override
  void onClose() {
    _locationTimer?.cancel();
    _positionSub?.cancel();
    super.onClose();
  }

  /// ═════════════════════════════════════════════════════════════════════════
  /// PERMISSIONS
  /// ═════════════════════════════════════════════════════════════════════════

  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Service Disabled',
        'Please enable location services',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.location_off, color: Colors.white),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Denied Forever',
        'Please enable location permission in settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
  }

  /// ═════════════════════════════════════════════════════════════════════════
  /// LOCATION TRACKING
  /// ═════════════════════════════════════════════════════════════════════════

  /// Start tracking for an order
  Future<void> startTracking(String orderId, LatLng deliveryAddress) async {
    isLoading.value = true;

    try {
      // Get user's current location
      await _getUserLocation();

      // Simulate courier location (in real app, get from backend)
      _simulateCourierLocation(deliveryAddress);

      // Update markers
      _updateMarkers();

      // Calculate initial distance & ETA
      _calculateDistanceAndETA();

      // Start periodic updates every 5 seconds
      _startPeriodicUpdates();

      isTrackingEnabled.value = true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start tracking: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Stop tracking
  void stopTracking() {
    _locationTimer?.cancel();
    isTrackingEnabled.value = false;
  }

  /// Get user's current location
  Future<void> _getUserLocation() async {
    try {
      // Check if running on web
      if (GetPlatform.isWeb) {
        // Use mock location for web (Jakarta)
        userLocation.value = const LatLng(-6.2088, 106.8456);
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLocation.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      // Default location (Jakarta) if failed
      userLocation.value = const LatLng(-6.2088, 106.8456);
    }
  }
  
  /// Public method to get user location
  Future<void> getUserLocation() async {
    await _getUserLocation();
  }

  /// Start live tracking of the user's own location (for checkout map)
  Future<void> startUserLiveTracking() async {
    try {
      isTrackingEnabled.value = true;
      // Cancel previous subscription if any
      await _positionSub?.cancel();

      // Ensure permissions
      await _checkPermissions();

      // Initial fetch
      await _getUserLocation();
      _updateMarkers();
      if (userLocation.value != null) {
        mapController.move(userLocation.value!, 16);
      }

      // Subscribe to high-accuracy position stream
      final settings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      );
      _positionSub = Geolocator.getPositionStream(locationSettings: settings)
          .listen((Position pos) {
        userLocation.value = LatLng(pos.latitude, pos.longitude);
        _updateMarkers();
        mapController.move(userLocation.value!, 16);
      });
    } catch (e) {
      Get.snackbar(
        'Location Error',
        'Cannot start live tracking: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Stop user live tracking
  Future<void> stopUserLiveTracking() async {
    await _positionSub?.cancel();
    isTrackingEnabled.value = false;
  }

  /// Simulate courier movement (in real app, get from backend)
  void _simulateCourierLocation(LatLng deliveryAddress) {
    // Start courier at a random location near delivery address
    final random = DateTime.now().millisecond / 1000;
    courierLocation.value = LatLng(
      deliveryAddress.latitude + (random * 0.01),
      deliveryAddress.longitude + (random * 0.01),
    );
  }

  /// Update courier location periodically
  void _startPeriodicUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (userLocation.value != null && courierLocation.value != null) {
        // Simulate courier moving towards user
        _moveCourierTowardsUser();
        _updateMarkers();
        _calculateDistanceAndETA();
        _updatePolyline();
      }
    });
  }

  /// Simulate courier movement towards user
  void _moveCourierTowardsUser() {
    if (courierLocation.value == null || userLocation.value == null) return;

    final courier = courierLocation.value!;
    final user = userLocation.value!;

    // Calculate direction
    final latDiff = user.latitude - courier.latitude;
    final lngDiff = user.longitude - courier.longitude;

    // Move courier slightly towards user (simulate movement)
    // Move 0.0001 degrees per update (approximately 11 meters)
    const moveStep = 0.0001;

    courierLocation.value = LatLng(
      courier.latitude + (latDiff > 0 ? moveStep : -moveStep),
      courier.longitude + (lngDiff > 0 ? moveStep : -moveStep),
    );
  }

  /// ═════════════════════════════════════════════════════════════════════════
  /// MAP MARKERS & POLYLINES
  /// ═════════════════════════════════════════════════════════════════════════

  /// Update map markers
  void _updateMarkers() {
    markers.clear();

    // User marker (delivery destination)
    if (userLocation.value != null) {
      markers.add(
        Marker(
          point: userLocation.value!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.home,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
    }

    // Courier marker
    if (courierLocation.value != null) {
      markers.add(
        Marker(
          point: courierLocation.value!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.delivery_dining,
            color: Color(0xFF1F70B2),
            size: 40,
          ),
        ),
      );
    }
  }

  /// Update polyline (route between courier and user)
  void _updatePolyline() {
    polylinePoints.clear();

    if (courierLocation.value != null && userLocation.value != null) {
      polylinePoints.addAll([courierLocation.value!, userLocation.value!]);
    }
  }

  /// ═════════════════════════════════════════════════════════════════════════
  /// CALCULATIONS
  /// ═════════════════════════════════════════════════════════════════════════

  /// Calculate distance and ETA
  void _calculateDistanceAndETA() {
    if (courierLocation.value == null || userLocation.value == null) return;

    // Calculate distance using Haversine formula
    distance.value = _calculateDistance(
      courierLocation.value!.latitude,
      courierLocation.value!.longitude,
      userLocation.value!.latitude,
      userLocation.value!.longitude,
    );

    // Calculate ETA (Estimated Time of Arrival)
    // ETA = distance / speed * 60 (convert to minutes)
    eta.value = ((distance.value / averageCourierSpeed) * 60).round();
  }

  /// Calculate distance between two coordinates (Haversine formula)
  /// Returns distance in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth radius in kilometers

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * 3.141592653589793 / 180;
  }

  double sin(double x) => x - (x * x * x) / 6;
  double cos(double x) => 1 - (x * x) / 2;

  /// ═════════════════════════════════════════════════════════════════════════
  /// MAP CAMERA
  /// ═════════════════════════════════════════════════════════════════════════

  /// Fit map bounds to show both markers
  void fitMapBounds() {
    if (courierLocation.value == null || userLocation.value == null) return;

    final bounds = LatLngBounds(
      courierLocation.value!,
      userLocation.value!,
    );

    mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  /// Center map on courier
  void centerOnCourier() {
    if (courierLocation.value == null) return;

    mapController.move(courierLocation.value!, 15);
  }

  /// Center map on user
  void centerOnUser() {
    if (userLocation.value == null) return;

    mapController.move(userLocation.value!, 15);
  }
}
