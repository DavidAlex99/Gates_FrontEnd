import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './medico_detalles_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Map> fetchMedicoDetails(int medicoId) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  final String url = 'http://192.168.100.6:8001/gatesApp/medicos/$medicoId';
  final response = await http.get(
    Uri.parse(url),
    headers: token != null ? {'Authorization': 'Token $token'} : {},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load medico details');
  }
}

class ServiciosPage extends StatefulWidget {
  @override
  _ServiciosPageState createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  String? selectedEspecialidad = 'Todos';
  List<dynamic> servicios = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchServiciosInicial();
  }

  fetchServiciosInicial() async {
    try {
      setState(() {
        loading = true;
      });
      final url = 'http://192.168.100.6:8001/gatesApp/servicios' +
          (selectedEspecialidad != 'Todos'
              ? '?categoria=$selectedEspecialidad'
              : '');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          servicios = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load servicios');
      }
    } catch (e) {
      print('Error fetching servicios: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  fetchServiciosCercanos() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    }

    if (await Permission.locationWhenInUse.isGranted) {
      try {
        setState(() {
          loading = true;
        });
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final uri =
            Uri.http('192.168.100.6:8001', '/gatesApp/servicios/cercanos', {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'categoria':
              selectedEspecialidad == 'Todos' ? '' : selectedEspecialidad,
        });

        final response = await http.get(uri);

        if (response.statusCode == 200) {
          setState(() {
            servicios = json.decode(response.body);
          });
        } else {
          throw Exception('Failed to load servicios with distances');
        }
      } catch (e) {
        print('Error fetching servicios with distances: $e');
      } finally {
        setState(() {
          loading = false;
        });
      }
    } else {
      _showLocationPermissionDialog();
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content: Text("This feature requires location access to function."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios'),
        actions: [
          DropdownButton<String>(
            value: selectedEspecialidad,
            onChanged: (newValue) {
              setState(() {
                selectedEspecialidad = newValue!;
                fetchServiciosInicial();
              });
            },
            items: <String>[
              'Todos',
              'ENTRANTE',
              'PRINCIPAL',
              'POSTRE',
              'BEBIDA',
              'SNACKS',
              'OTRO'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: fetchServiciosCercanos,
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: servicios.length,
              itemBuilder: (context, index) {
                final servicio = servicios[index];
                final distanciaStr = servicio['distancia'] != null
                    ? "${servicio['distancia'].toStringAsFixed(2)} km"
                    : "Distance not available";
                return ListTile(
                  title: Text(servicio['nombre']),
                  subtitle: Text(
                      '${servicio['descripcion']} - \$${servicio['precio']} - Distancia: $distanciaStr'),
                  leading: servicio['imagen'] != null
                      ? Image.network(servicio['imagen'],
                          width: 100, height: 100, fit: BoxFit.cover)
                      : null,
                  onTap: () async {
                    try {
                      final medicoDetails = await fetchMedicoDetails(
                          servicio['emprendimiento_id']);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MedicoDetallesPage(medico: medicoDetails),
                          ));
                    } catch (e) {
                      print('Error navigating to medico details: $e');
                    }
                  },
                );
              },
            ),
    );
  }
}
