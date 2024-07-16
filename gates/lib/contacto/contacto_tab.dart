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
  // para arcar la ubicacion del cliente
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    contacto = widget.medico['contacto'] ?? {};
    // Inicializar el marcador del emprendimiento desde el inicio.
    final latitud = double.tryParse('${widget.medico['contacto']?['latitud']}');
    final longitud =
        double.tryParse('${widget.medico['contacto']?['longitud']}');
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

  // obtener permiso ubicacion del cliente
  Future<void> _getUserLocation() async {
    // Verifica y solicita los permisos de ubicación.
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      // Los permisos están denegados, solicítalos.
      status = await Permission.locationWhenInUse.request();
      if (status.isDenied) {
        // Los permisos fueron denegados definitivamente.
        print('Permiso de ubicación denegado');
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      // Los permisos están denegados permanentemente, dirige al usuario a la configuración.
      openAppSettings();
      return;
    }

    // Asumiendo que ya has añadido el marcador del emprendimiento y del usuario a 'markers'
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      markers.add(Marker(
        markerId: MarkerId('userLocation'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });

    // Ubicación del emprendimiento.
    final LatLng medicoLocation = LatLng(
        double.tryParse('${widget.medico['contacto']['latitud']}') ?? 0,
        double.tryParse('${widget.medico['contacto']['longitud']}') ?? 0);

    // Crear LatLngBounds
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

    // Ajustar la cámara para mostrar ambos marcadores
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
  // fin obtener permiso ubicacion del cliente

  Future<void> _refreshContactInfo() async {
    try {
      final updatedMedico = await fetchMedicoDetails(widget.medico['id']);
      setState(() {
        contacto = updatedMedico['contacto'] ?? {};
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

    final String url = 'http://127.0.0.1:8000/medicos/$medicoId';
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
            if (contacto['imagenesContacto'] != null &&
                (contacto['imagenesContacto'] as List).isNotEmpty)
              ...contacto['imagenesContacto']
                  .map((img) => Image.network(
                        'http://127.0.0.1:8000${img['imagen']}',
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
