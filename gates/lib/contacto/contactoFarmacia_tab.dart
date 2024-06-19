import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class ContactoFarmaciaTab extends StatefulWidget {
  final Map farmacia;

  ContactoFarmaciaTab({Key? key, required this.farmacia}) : super(key: key);

  @override
  _ContactoFarmaciaTabState createState() => _ContactoFarmaciaTabState();
}

class _ContactoFarmaciaTabState extends State<ContactoFarmaciaTab> {
  late GoogleMapController mapController;
  // para arcar la ubicacion del cliente
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar el marcador del emprendimiento desde el inicio.
    final latitud =
        double.tryParse('${widget.farmacia['contactoFarmacia']?['latitud']}');
    final longitud =
        double.tryParse('${widget.farmacia['contactoFarmacia']?['longitud']}');
    if (latitud != null && longitud != null) {
      markers.add(Marker(
        markerId: MarkerId("farmaciaLocation"),
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
    final LatLng farmaciaLocation = LatLng(
        double.tryParse('${widget.farmacia['contacto']['latitud']}') ?? 0,
        double.tryParse('${widget.farmacia['contacto']['longitud']}') ?? 0);

    // Crear LatLngBounds
    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(farmaciaLocation.latitude, position.latitude),
        min(farmaciaLocation.longitude, position.longitude),
      ),
      northeast: LatLng(
        max(farmaciaLocation.latitude, position.latitude),
        max(farmaciaLocation.longitude, position.longitude),
      ),
    );

    // Ajustar la cámara para mostrar ambos marcadores
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
  // fin obtener permiso ubicacion del cliente

  @override
  Widget build(BuildContext context) {
    final contactoFarmacia = widget.farmacia['contactoFarmacia'] ?? {};
    final lat = contactoFarmacia['latitud'];
    final lng = contactoFarmacia['longitud'];

    return SingleChildScrollView(
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
            subtitle: Text(contactoFarmacia['direccion'] ?? 'No disponible'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Teléfono'),
            subtitle: Text(contactoFarmacia['telefono'] ?? 'No disponible'),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Correo Electrónico'),
            subtitle: Text(contactoFarmacia['correo'] ?? 'No disponible'),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Imágenes de contacto',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          if (contactoFarmacia['imagenesContacto'] != null &&
              (contactoFarmacia['imagenesContacto'] as List).isNotEmpty)
            ...contactoFarmacia['imagenesContacto']
                .map((img) => Image.network(
                      'http://192.168.100.6:8001${img['imagen']}',
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
    );
  }
}
