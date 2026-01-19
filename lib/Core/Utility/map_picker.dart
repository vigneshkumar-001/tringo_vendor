import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleLocationPickerScreen extends StatefulWidget {
  const GoogleLocationPickerScreen({super.key});

  @override
  State<GoogleLocationPickerScreen> createState() =>
      _GoogleLocationPickerScreenState();
}

class _GoogleLocationPickerScreenState extends State<GoogleLocationPickerScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;

  LatLng? currentLocation;
  LatLng? selectedLocation;
  bool _hideBottomSheet = false;

  String locality = 'Fetching location...';
  String city = '';
  String fullAddress = '';

  bool loading = true;

  // Search
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<dynamic> _placePredictions = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const double _zoom = 16;

  // IMPORTANT:
  // 1) ROTATE your leaked key in Google Cloud Console.
  // 2) Put the new key in a secure place (dotenv / build config), not hardcoded.
  static const String _apiKey = 'AIzaSyAoOiPmmtlMJ7dqbk3yW13itbM1B5grOdc';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          loading = false;
          locality = 'Location permission denied';
          fullAddress = 'Enable location permission in settings.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLocation = LatLng(pos.latitude, pos.longitude);
      selectedLocation = currentLocation;

      await _reverseGeocode(pos.latitude, pos.longitude);

      if (!mounted) return;
      setState(() => loading = false);
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        locality = 'Unable to get current location';
        fullAddress = 'Error: $e';
      });
    }
  }

  // Reverse geocode (lat/lng -> address)
  Future<void> _reverseGeocode(double lat, double lng) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=$lat,$lng&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          locality = 'Unable to fetch location';
          city = '';
          fullAddress = 'HTTP ${response.statusCode}';
        });
        return;
      }

      // Handle Google API errors clearly
      if (data['status'] != 'OK') {
        if (!mounted) return;
        setState(() {
          locality = 'Unable to fetch location';
          city = '';
          fullAddress =
              (data['error_message'] ?? data['status'] ?? 'Unknown error')
                  .toString();
        });
        return;
      }

      if ((data['results'] as List).isEmpty) {
        if (!mounted) return;
        setState(() {
          locality = 'Unknown location';
          city = '';
          fullAddress = 'No address found';
        });
        return;
      }

      final result = data['results'][0];
      final components = result['address_components'] as List;

      String? _locality;
      String? _city;

      for (final c in components) {
        final types = List<String>.from(c['types']);
        if (types.contains('sublocality') || types.contains('locality')) {
          _locality ??= c['long_name'];
        }
        if (types.contains('administrative_area_level_2') ||
            types.contains('administrative_area_level_1')) {
          _city ??= c['long_name'];
        }
      }

      if (!mounted) return;
      setState(() {
        locality = _locality ?? 'Selected Location';
        city = _city ?? '';
        fullAddress = (result['formatted_address'] ?? '').toString();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        locality = 'Error fetching location';
        city = '';
        fullAddress = 'Unable to fetch address: $e';
      });
    }
  }

  // Places Autocomplete (text -> predictions)
  Future<void> _searchPlaces(String input) async {
    final q = input.trim();
    if (q.isEmpty) {
      if (!mounted) return;
      setState(() => _placePredictions = []);
      return;
    }

    final locBias = currentLocation != null
        ? '&location=${currentLocation!.latitude},${currentLocation!.longitude}&radius=30000'
        : '';

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(q)}'
          '&key=$_apiKey'
          '&language=en'
          '$locBias',
    );

    try {
      final res = await http.get(uri);
      final data = json.decode(res.body);

      if (!mounted) return;

      if (res.statusCode != 200) {
        setState(() => _placePredictions = []);
        return;
      }

      if (data['status'] == 'OK') {
        setState(() => _placePredictions = data['predictions'] as List);
      } else {
        // Typical: REQUEST_DENIED (Places API not enabled / key restricted)
        setState(() => _placePredictions = []);
        // Optional: show error in address field for debugging
        // setState(() => fullAddress = '${data['status']}: ${data['error_message'] ?? ''}');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _placePredictions = []);
    }
  }

  // Place Details (prediction -> lat/lng)
  Future<void> _selectPrediction(dynamic prediction) async {
    final placeId = (prediction['place_id'] ?? '').toString();
    if (placeId.isEmpty) return;

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=geometry,name,formatted_address'
          '&key=$_apiKey',
    );

    try {
      final res = await http.get(uri);
      final data = json.decode(res.body);

      if (!mounted) return;

      if (res.statusCode != 200 || data['status'] != 'OK') {
        setState(() {
          _placePredictions = [];
          fullAddress = (data['error_message'] ?? data['status'] ?? 'Error')
              .toString();
        });
        return;
      }

      final loc = data['result']?['geometry']?['location'];
      if (loc == null) return;

      final lat = (loc['lat'] as num).toDouble();
      final lng = (loc['lng'] as num).toDouble();
      final newPoint = LatLng(lat, lng);
      setState(() {
        selectedLocation = newPoint;
        _placePredictions = [];
        _searchController.text = (prediction['description'] ?? '').toString();
        _hideBottomSheet = false; // ✅ show again
      });

      _searchFocus.unfocus();

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newPoint, _zoom),
      );

      await _reverseGeocode(lat, lng);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _placePredictions = [];
        fullAddress = 'Search failed: $e';
      });
    }
  }

  void _onMapTap(LatLng point) async {
    setState(() {
      selectedLocation = point;
      locality = 'Fetching location...';
      city = '';
      fullAddress = '';
      _placePredictions = [];
      _hideBottomSheet = false; // ✅ show again
    });

    _searchFocus.unfocus();
    await _reverseGeocode(point.latitude, point.longitude);
  }

  void _recenter() {
    if (currentLocation == null || _mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(currentLocation!, _zoom),
    );
    _onMapTap(currentLocation!);
  }

  Widget _buildSearchBox() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onTap: () {
                  setState(() => _hideBottomSheet = true);
                },
                onChanged: (v) {
                  _searchPlaces(v);
                  setState(() {});
                },
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for a location',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade700,
                          size: 18,
                        ),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _placePredictions = [];
                          _hideBottomSheet = false;
                        });
                        _searchFocus.unfocus();
                      },
                    ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Suggestions Dropdown
            if (_placePredictions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 320),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: _placePredictions.length > 10
                        ? 10
                        : _placePredictions.length,
                    itemBuilder: (context, i) {
                      final p = _placePredictions[i];
                      final description = (p['description'] ?? '').toString();

                      // Parse main text and secondary text
                      final parts = description.split(',');
                      final mainText = parts.isNotEmpty
                          ? parts[0].trim()
                          : description;
                      final secondaryText = parts.length > 1
                          ? parts.sublist(1).join(',').trim()
                          : '';

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectPrediction(p),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Location Icon
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.grey.shade700,
                                    size: 20,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                // Text Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mainText,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          height: 1.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (secondaryText.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          secondaryText,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                            height: 1.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Arrow Icon
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.grey.shade400,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade400, Colors.blue.shade700],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Finding your location...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If location failed, show a basic screen
    if (currentLocation == null || selectedLocation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Location')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              fullAddress.isNotEmpty ? fullAddress : 'Location not available.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Container(
      //       padding: const EdgeInsets.all(8),
      //       decoration: BoxDecoration(
      //         color: Colors.white,
      //         borderRadius: BorderRadius.circular(12),
      //         boxShadow: [
      //           BoxShadow(
      //             color: Colors.black.withOpacity(0.1),
      //             blurRadius: 8,
      //             offset: const Offset(0, 2),
      //           ),
      //         ],
      //       ),
      //       child: const Icon(
      //         Icons.arrow_back,
      //         color: Colors.black87,
      //         size: 20,
      //       ),
      //     ),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: const Text(
      //     'Select Location',
      //     style: TextStyle(
      //       color: Colors.black87,
      //       fontWeight: FontWeight.w600,
      //       fontSize: 18,
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation!,
              zoom: _zoom,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (c) => _mapController = c,
            onTap: _onMapTap,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: selectedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            },
          ),

          // Search bar
          _buildSearchBox(),

          // Recenter button
          Positioned(
            right: 16,
            bottom: 240,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: _recenter,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              offset: _hideBottomSheet ? const Offset(0, 1) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _hideBottomSheet ? 0 : 1,
                child: IgnorePointer(
                  ignoring: _hideBottomSheet,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      // ✅ keep your existing bottom sheet Container exactly as it is here
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Location icon and title
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Colors.blue.shade700,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            locality,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (city.isNotEmpty)
                                            Text(
                                              city,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Full address
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.place_outlined,
                                        color: Colors.grey.shade600,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          fullAddress,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Coordinates
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.navigation,
                                        color: Colors.blue.shade700,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${selectedLocation!.latitude.toStringAsFixed(6)}, ${selectedLocation!.longitude.toStringAsFixed(6)}',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Confirm button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, {
                                        'lat': selectedLocation!.latitude,
                                        'lng': selectedLocation!.longitude,
                                        'area': fullAddress,
                                        'locality': locality,
                                        'city': city,
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, size: 22),
                                        SizedBox(width: 8),
                                        Text(
                                          'Confirm Location',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom sheet
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: FadeTransition(
          //     opacity: _fadeAnimation,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: const BorderRadius.only(
          //           topLeft: Radius.circular(28),
          //           topRight: Radius.circular(28),
          //         ),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.15),
          //             blurRadius: 20,
          //             offset: const Offset(0, -4),
          //           ),
          //         ],
          //       ),
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           // Drag handle
          //           Container(
          //             margin: const EdgeInsets.only(top: 12),
          //             width: 40,
          //             height: 4,
          //             decoration: BoxDecoration(
          //               color: Colors.grey.shade300,
          //               borderRadius: BorderRadius.circular(2),
          //             ),
          //           ),
          //
          //           Padding(
          //             padding: const EdgeInsets.all(20),
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 // Location icon and title
          //                 Row(
          //                   children: [
          //                     Container(
          //                       padding: const EdgeInsets.all(10),
          //                       decoration: BoxDecoration(
          //                         color: Colors.blue.shade50,
          //                         borderRadius: BorderRadius.circular(12),
          //                       ),
          //                       child: Icon(
          //                         Icons.location_on,
          //                         color: Colors.blue.shade700,
          //                         size: 24,
          //                       ),
          //                     ),
          //                     const SizedBox(width: 12),
          //                     Expanded(
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           Text(
          //                             locality,
          //                             style: const TextStyle(
          //                               fontSize: 18,
          //                               fontWeight: FontWeight.w700,
          //                               color: Colors.black87,
          //                             ),
          //                             maxLines: 1,
          //                             overflow: TextOverflow.ellipsis,
          //                           ),
          //                           if (city.isNotEmpty)
          //                             Text(
          //                               city,
          //                               style: TextStyle(
          //                                 fontSize: 14,
          //                                 color: Colors.grey.shade600,
          //                                 fontWeight: FontWeight.w500,
          //                               ),
          //                               maxLines: 1,
          //                               overflow: TextOverflow.ellipsis,
          //                             ),
          //                         ],
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //
          //                 const SizedBox(height: 16),
          //
          //                 // Full address
          //                 Container(
          //                   padding: const EdgeInsets.all(14),
          //                   decoration: BoxDecoration(
          //                     color: Colors.grey.shade50,
          //                     borderRadius: BorderRadius.circular(14),
          //                     border: Border.all(
          //                       color: Colors.grey.shade200,
          //                       width: 1,
          //                     ),
          //                   ),
          //                   child: Row(
          //                     children: [
          //                       Icon(
          //                         Icons.place_outlined,
          //                         color: Colors.grey.shade600,
          //                         size: 18,
          //                       ),
          //                       const SizedBox(width: 10),
          //                       Expanded(
          //                         child: Text(
          //                           fullAddress,
          //                           style: TextStyle(
          //                             color: Colors.grey.shade700,
          //                             fontSize: 13,
          //                             height: 1.4,
          //                           ),
          //                           maxLines: 2,
          //                           overflow: TextOverflow.ellipsis,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //
          //                 const SizedBox(height: 12),
          //
          //                 // Coordinates
          //                 Container(
          //                   padding: const EdgeInsets.symmetric(
          //                     horizontal: 14,
          //                     vertical: 10,
          //                   ),
          //                   decoration: BoxDecoration(
          //                     color: Colors.blue.shade50.withOpacity(0.5),
          //                     borderRadius: BorderRadius.circular(12),
          //                   ),
          //                   child: Row(
          //                     mainAxisSize: MainAxisSize.min,
          //                     children: [
          //                       Icon(
          //                         Icons.navigation,
          //                         color: Colors.blue.shade700,
          //                         size: 16,
          //                       ),
          //                       const SizedBox(width: 8),
          //                       Text(
          //                         '${selectedLocation!.latitude.toStringAsFixed(6)}, ${selectedLocation!.longitude.toStringAsFixed(6)}',
          //                         style: TextStyle(
          //                           color: Colors.blue.shade700,
          //                           fontSize: 12,
          //                           fontWeight: FontWeight.w600,
          //                           fontFamily: 'monospace',
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //
          //                 const SizedBox(height: 20),
          //
          //                 // Confirm button
          //                 SizedBox(
          //                   width: double.infinity,
          //                   height: 56,
          //                   child: ElevatedButton(
          //                     onPressed: () {
          //                       Navigator.pop(context, {
          //                         'lat': selectedLocation!.latitude,
          //                         'lng': selectedLocation!.longitude,
          //                         'area': fullAddress,
          //                         'locality': locality,
          //                         'city': city,
          //                       });
          //                     },
          //                     style: ElevatedButton.styleFrom(
          //                       backgroundColor: Colors.blue.shade600,
          //                       foregroundColor: Colors.white,
          //                       elevation: 0,
          //                       shape: RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.circular(16),
          //                       ),
          //                       padding: const EdgeInsets.symmetric(
          //                         vertical: 16,
          //                       ),
          //                     ),
          //                     child: const Row(
          //                       mainAxisAlignment: MainAxisAlignment.center,
          //                       children: [
          //                         Icon(Icons.check_circle, size: 22),
          //                         SizedBox(width: 8),
          //                         Text(
          //                           'Confirm Location',
          //                           style: TextStyle(
          //                             fontSize: 16,
          //                             fontWeight: FontWeight.w600,
          //                             letterSpacing: 0.5,
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
