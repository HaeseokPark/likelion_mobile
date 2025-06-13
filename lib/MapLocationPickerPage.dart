import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapLocationPickerPage extends StatefulWidget {
  @override
  _MapLocationPickerPageState createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  LatLng? _selectedPosition;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedPosition = LatLng(pos.latitude, pos.longitude);
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('위치 선택')),
      body: _selectedPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _selectedPosition!,
                zoom: 15,
              ),
              markers: {
                if (_selectedPosition != null)
                  Marker(markerId: MarkerId('picked'), position: _selectedPosition!)
              },
              onTap: _onMapTap,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, _selectedPosition),
        label: Text('위치 선택 완료'),
        icon: Icon(Icons.check),
      ),
    );
  }
}
