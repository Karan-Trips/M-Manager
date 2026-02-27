import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as lat;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:m_manager/utils/screen_utils.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  final ValueNotifier<Position?> currentPosition = ValueNotifier(null);
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<String> currentAddress =
      ValueNotifier<String>('Fetching address...');

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    currentPosition.value = position;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15,
        );
        getPlaceName(position.latitude, position.longitude);
      }
    });
  }

  Future<void> getPlaceName(double latitude, double longitude) async {
    try {
      List<lat.Placemark> placemarks =
          await lat.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = '${placemark.name}, ${placemark.street}, '
            '${placemark.subLocality}, ${placemark.locality}, '
            '${placemark.administrativeArea}, ${placemark.postalCode}, '
            '${placemark.country}';

        currentAddress.value = address;
      } else {
        currentAddress.value = 'Address not found';
      }
    } catch (e) {
      currentAddress.value = 'Error fetching address: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Map Search'),
      ),
      body: ValueListenableBuilder<Position?>(
        valueListenable: currentPosition,
        builder: (context, value, _) {
          if (value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  onLongPress: (tapPosition, point) {
                    _mapController.move(
                      LatLng(point.latitude, point.longitude),
                      15,
                    );
                    getPlaceName(point.latitude, point.longitude);
                  },
                  initialCenter: LatLng(value.latitude, value.longitude),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.m_manager',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(value.latitude, value.longitude),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 20.h,
                right: 0.w,
                left: 0.w,
                child: Container(
                  width: double.infinity,
                  height: 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      bottomRight: Radius.circular(20.r),
                    ),
                    color: Colors.red[50],
                  ),
                  child: ValueListenableBuilder<String>(
                      valueListenable: currentAddress,
                      builder: (context, address, _) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Your Cuurent Location is : ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                )),
                            15.verticalSpace,
                            Text(
                              address,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ).pAll(15.r);
                      }),
                ).pH(25.w),
              ),
            ],
          );
        },
      ),
    );
  }
}
