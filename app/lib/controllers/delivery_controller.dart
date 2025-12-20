// lib/controllers/delivery_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// DELIVERY CONTROLLER - Live Tracking Kurir
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Controller untuk manage:
/// - Live location tracking kurir
/// - Kalkulasi jarak & ETA
/// - Update posisi real-time
class DeliveryController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // OBSERVABLE VARIABLES
  // ─────────────────────────────────────────────────────────────────────────
  
  // Posisi kurir (live update)
  final Rx<LatLng?> courierLocation = Rx<LatLng?>(null);
  
  // Posisi tujuan customer (fixed)
  final Rx<LatLng?> destinationLocation = Rx<LatLng?>(null);
  
  // Status tracking
  final RxBool isTracking = false.obs;
  final RxBool isLoading = false.obs;
  
  // Location info
  final RxString locationSource = ''.obs; // GPS / Network
  final RxDouble accuracy = 0.0.obs;
  final RxDouble speed = 0.0.obs; // meter/second
  
  // Distance & ETA
  final RxDouble distanceInMeters = 0.0.obs;
  final RxString distanceText = ''.obs;
  final RxString etaText = ''.obs;
  
  // Delivery info
  final RxString orderId = ''.obs;
  final RxString deliveryStatus = 'Sedang Dikirim'.obs;
  
  StreamSubscription<Position>? _positionStreamSubscription;
  
  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────
  
  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
  }
  
  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }
  
  // ─────────────────────────────────────────────────────────────────────────
  // PERMISSION HANDLING
  // ─────────────────────────────────────────────────────────────────────────
  
  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Service Disabled',
        'Please enable location services',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required for tracking',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Denied Forever',
        'Please enable location in app settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
    
    return true;
  }
  
  // ─────────────────────────────────────────────────────────────────────────
  // SETUP DELIVERY
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Set destination customer location
  void setDestination(LatLng destination, String orderIdParam) {
    destinationLocation.value = destination;
    orderId.value = orderIdParam;
  }
  
  // ─────────────────────────────────────────────────────────────────────────
  // LIVE TRACKING (Kurir Mode)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Start live tracking untuk kurir
  Future<void> startTracking() async {
    if (isTracking.value) return;
    
    if (!await _checkPermissions()) return;
    
    if (destinationLocation.value == null) {
      Get.snackbar(
        'Error',
        'Destination location not set',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    isTracking.value = true;
    deliveryStatus.value = 'Sedang Dikirim';
    
    // Get initial position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateCourierPosition(position);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get initial position: $e');
    }
    
    // Start position stream
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update setiap 10 meter
      ),
    ).listen(
      (Position position) {
        _updateCourierPosition(position);
      },
      onError: (error) {
        Get.snackbar(
          'Tracking Error',
          'Failed to track location: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
        stopTracking();
      },
    );
    
    Get.snackbar(
      'Tracking Started',
      'Live delivery tracking is now active',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1F70B2),
      colorText: Get.theme.colorScheme.onPrimary,
      icon: const Icon(Icons.gps_fixed, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }
  
  /// Stop tracking
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    isTracking.value = false;
  }
  
  /// Update posisi kurir dan kalkulasi jarak/ETA
  void _updateCourierPosition(Position position) {
    courierLocation.value = LatLng(position.latitude, position.longitude);
    accuracy.value = position.accuracy;
    speed.value = position.speed;
    
    // Detect location source
    if (position.accuracy < 20) {
      locationSource.value = 'GPS Location';
    } else if (position.accuracy < 100) {
      locationSource.value = 'Network Location';
    } else {
      locationSource.value = 'Low Accuracy';
    }
    
    // Calculate distance & ETA
    if (destinationLocation.value != null) {
      _calculateDistanceAndETA();
    }
  }
  
  // ─────────────────────────────────────────────────────────────────────────
  // DISTANCE & ETA CALCULATION
  // ─────────────────────────────────────────────────────────────────────────
  
  void _calculateDistanceAndETA() {
    if (courierLocation.value == null || destinationLocation.value == null) {
      return;
    }
    
    // Calculate distance using Haversine formula
    final distance = Geolocator.distanceBetween(
      courierLocation.value!.latitude,
      courierLocation.value!.longitude,
      destinationLocation.value!.latitude,
      destinationLocation.value!.longitude,
    );
    
    distanceInMeters.value = distance;
    
    // Format distance text
    if (distance < 1000) {
      distanceText.value = '${distance.toStringAsFixed(0)} meter';
    } else {
      distanceText.value = '${(distance / 1000).toStringAsFixed(2)} km';
    }
    
    // Calculate ETA
    // Assume average speed of 40 km/h (11 m/s) if speed is 0
    double avgSpeed = speed.value > 0 ? speed.value : 11.0;
    double etaSeconds = distance / avgSpeed;
    
    if (etaSeconds < 60) {
      etaText.value = '< 1 menit';
    } else if (etaSeconds < 3600) {
      int minutes = (etaSeconds / 60).round();
      etaText.value = '$minutes menit';
    } else {
      int hours = (etaSeconds / 3600).floor();
      int minutes = ((etaSeconds % 3600) / 60).round();
      etaText.value = '$hours jam $minutes menit';
    }
    
    // Update delivery status based on distance
    if (distance < 100) {
      deliveryStatus.value = 'Hampir Sampai!';
    } else if (distance < 500) {
      deliveryStatus.value = 'Dalam Perjalanan (Dekat)';
    } else {
      deliveryStatus.value = 'Sedang Dikirim';
    }
  }
  
  // ─────────────────────────────────────────────────────────────────────────
  // SIMULATE COURIER (For Testing - Customer Mode)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Simulate courier movement untuk testing (jika tidak punya 2 device)
  void simulateCourierMovement(LatLng startLocation) {
    courierLocation.value = startLocation;
    locationSource.value = 'Simulated GPS';
    accuracy.value = 10.0;
    speed.value = 12.0; // 12 m/s ≈ 43 km/h
    
    if (destinationLocation.value != null) {
      _calculateDistanceAndETA();
    }
  }
  
  /// Complete delivery
  void completeDelivery() {
    deliveryStatus.value = 'Terkirim';
    stopTracking();
    
    Get.snackbar(
      'Delivery Complete',
      'Pesanan telah sampai di tujuan!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
}
