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
  print("Token is: $token"); // Esto mostrará el token en la consola.

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
  List<dynamic> servicios = [];
  bool loading = false;
  List<dynamic> filteredServicios = [];
  String filtroPrecio = 'Todos';
  String filtroAlfabetico = 'Todos';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchServiciosInicial();
  }

  Future<void> fetchServiciosInicial() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final url = 'http://192.168.100.6:8001/gatesApp/servicios';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token', // Añadir el token al encabezado
        },
      );

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
    aplicarFiltros();
  }

  Future<void> fetchServiciosCercanos() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    }

    if (await Permission.locationWhenInUse.isGranted) {
      try {
        setState(() {
          loading = true;
        });
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('auth_token');

        var queryParams = {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
        };
        var uri = Uri.http(
            '192.168.100.6:8001', '/gatesApp/servicios/cercanos', queryParams);

        final response = await http.get(uri, headers: {
          'Authorization': 'Token $token',
        });

        if (response.statusCode == 200) {
          setState(() {
            servicios = json.decode(response.body);
          });
        } else {
          // Manejar el error de carga
        }
      } catch (e) {
        // Manejar el error
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

  void aplicarFiltros() {
    filteredServicios =
        List.from(servicios); // Crear una copia de los servicios

    // Filtrado por precio
    if (filtroPrecio == 'Ascendente') {
      filteredServicios.sort((a, b) => (a['precio']).compareTo(b['precio']));
    } else if (filtroPrecio == 'Descendente') {
      filteredServicios.sort((a, b) => (b['precio']).compareTo(a['precio']));
    }

    // Orden alfabético
    if (filtroAlfabetico == 'Ascendente') {
      filteredServicios.sort((a, b) => a['nombre'].compareTo(b['nombre']));
    } else if (filtroAlfabetico == 'Descendente') {
      filteredServicios.sort((a, b) => b['nombre'].compareTo(a['nombre']));
    }

    // Filtrado por búsqueda de texto
    if (searchController.text.isNotEmpty) {
      filteredServicios = filteredServicios.where((servicio) {
        return servicio['nombre']
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios'),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed:
                fetchServiciosCercanos, // Este método aún necesita ser implementado
          ),
          DropdownButton<String>(
            value: filtroPrecio,
            onChanged: (String? newValue) {
              setState(() {
                filtroPrecio = newValue!;
                aplicarFiltros();
              });
            },
            items: <String>['Todos', 'Ascendente', 'Descendente']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('Precio $value'),
              );
            }).toList(),
          ),
          DropdownButton<String>(
            value: filtroAlfabetico,
            onChanged: (String? newValue) {
              setState(() {
                filtroAlfabetico = newValue!;
                aplicarFiltros();
              });
            },
            items: <String>['Todos', 'Ascendente', 'Descendente']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('Alfabético $value'),
              );
            }).toList(),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredServicios.length,
              itemBuilder: (context, index) {
                final servicio = filteredServicios[index];
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
