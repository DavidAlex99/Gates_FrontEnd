import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ContactoTab extends StatefulWidget {
  final Map medico;

  ContactoTab({Key? key, required this.medico}) : super(key: key);

  @override
  _ContactoTabState createState() => _ContactoTabState();
}

class _ContactoTabState extends State<ContactoTab> {
  late Map contacto;
  late GoogleMapController mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    contacto = widget.medico['contacto'] ?? {};
    final latitud =
        double.tryParse('${widget.medico['contactoMedico']?['latitud']}');
    final longitud =
        double.tryParse('${widget.medico['contactoMedico']?['longitud']}');
    if (latitud != null && longitud != null) {
      markers.add(Marker(
        markerId: MarkerId("medicoLocation"),
        position: LatLng(latitud, longitud),
      ));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getUserLocation() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
      if (status.isDenied) {
        print('Permiso de ubicación denegado');
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      markers.add(Marker(
        markerId: MarkerId('userLocation'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });

    final LatLng medicoLocation = LatLng(
        double.tryParse('${widget.medico['contactoMedico']['latitud']}') ?? 0,
        double.tryParse('${widget.medico['contactoMedico']['longitud']}') ?? 0);

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(medicoLocation.latitude, position.latitude),
        min(medicoLocation.longitude, position.longitude),
      ),
      northeast: LatLng(
        max(medicoLocation.latitude, position.latitude),
        max(medicoLocation.longitude, position.longitude),
      ),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  Future<void> _refreshContactInfo() async {
    try {
      final updatedMedico = await fetchMedicoDetails(widget.medico['id']);
      setState(() {
        contacto = updatedMedico['contactoMedico'] ?? {};
        markers.clear();
        final latitud = double.tryParse('${contacto['latitud']}');
        final longitud = double.tryParse('${contacto['longitud']}');
        if (latitud != null && longitud != null) {
          markers.add(Marker(
            markerId: MarkerId("medicoLocation"),
            position: LatLng(latitud, longitud),
          ));
        }
      });
    } catch (e) {
      print('Error refreshing contact info: $e');
    }
  }

  Future<Map> fetchMedicoDetails(int medicoId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url = 'http://192.168.100.6:8001/medicos/$medicoId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load medico details');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = contacto['latitud'];
    final lng = contacto['longitud'];

    return RefreshIndicator(
      onRefresh: _refreshContactInfo,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lat != null && lng != null)
              Container(
                height: 250,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 16.0,
                  ),
                  markers: markers,
                ),
              ),
            ElevatedButton(
              onPressed: _getUserLocation,
              child: Text('Mostrar mi ubicación'),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Dirección'),
              subtitle: Text(contacto['direccion'] ?? 'No disponible'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Teléfono'),
              subtitle: Text(contacto['telefono'] ?? 'No disponible'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Correo Electrónico'),
              subtitle: Text(contacto['correo'] ?? 'No disponible'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Imágenes de contacto',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            if (contacto['imagenesContactoMedico'] != null &&
                (contacto['imagenesContactoMedico'] as List).isNotEmpty)
              ...contacto['imagenesContactoMedico']
                  .map((img) => Image.network(
                        'http://192.168.100.6:8000${img['imagen']}',
                        fit: BoxFit.cover,
                      ))
                  .toList()
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'No hay imágenes de contacto disponibles.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
