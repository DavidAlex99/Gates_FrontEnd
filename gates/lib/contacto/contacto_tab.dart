import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

class ContactoTab extends StatefulWidget {
  final Map medico;

  ContactoTab({required this.medico});

  @override
  _ContactoTabState createState() => _ContactoTabState();
}

class _ContactoTabState extends State<ContactoTab> {
  GoogleMapController? mapController;
  // para arcar la ubicacion del cliente
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar el marcador del emprendimiento desde el inicio.
    final latitud = double.tryParse('${widget.medico['contacto']['latitud']}');
    final longitud =
        double.tryParse('${widget.medico['contacto']['longitud']}');
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
    final LatLng emprendimientoLocation = LatLng(
        double.tryParse('${widget.medico['contacto']['latitud']}') ?? 0,
        double.tryParse('${widget.medico['contacto']['longitud']}') ?? 0);

    // Crear LatLngBounds
    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(emprendimientoLocation.latitude, position.latitude),
        min(emprendimientoLocation.longitude, position.longitude),
      ),
      northeast: LatLng(
        max(emprendimientoLocation.latitude, position.latitude),
        max(emprendimientoLocation.longitude, position.longitude),
      ),
    );

    // Ajustar la cámara para mostrar ambos marcadores
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
  // fin obtener permiso ubicacion del cliente

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 300.0,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.medico['contacto']['latitud'],
                    widget.medico['contacto']['longitud']),
                zoom: 16.0,
              ),
              markers: markers,
            ),
          ),
          ElevatedButton(
            onPressed: _getUserLocation,
            child: Text('Mostrar mi ubicación'),
          ),
          // Las siguientes ListTiles son iguales que en tu código anterior.
          ListTile(
            title: Text('Dirección:'),
            subtitle:
                Text(widget.medico['contacto']['direccion'] ?? 'No disponible'),
            leading: Icon(Icons.location_on),
          ),
          ListTile(
            title: Text('Teléfono:'),
            subtitle:
                Text(widget.medico['contacto']['telefono'] ?? 'No disponible'),
            leading: Icon(Icons.phone),
          ),
          ListTile(
            title: Text('Correo Electrónico:'),
            subtitle:
                Text(widget.medico['contacto']['correo'] ?? 'No disponible'),
            leading: Icon(Icons.email),
          ),
          for (var img in widget.medico['contacto']['imagenesContacto'] ?? [])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.network(
                img['imagen'],
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}
