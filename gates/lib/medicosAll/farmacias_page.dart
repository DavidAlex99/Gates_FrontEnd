import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'farmacia_detalles_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import './medicamentos_page.dart';
import './medicos_page.dart';

Future<Map> fetchFarmaciaDetails(int farmaciaId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token =
      prefs.getString('token'); // Obtener el token de SharedPreferences
  print('token en fetchFarmaciaDetails:');
  print(token);

  final String url = 'http://192.168.100.6:8001/gatesApp/farmacias/$farmaciaId';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Token $token', // Añadir el encabezado de autorización
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load farmacia details');
  }
}

class FarmaciasPage extends StatefulWidget {
  final String userId;

  FarmaciasPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FarmaciasPageState createState() => _FarmaciasPageState();
}

class _FarmaciasPageState extends State<FarmaciasPage> {
  //String selectedEspecialidad = 'Todos';
  bool loading = false;
  List<dynamic> farmacias = [];

  @override
  void initState() {
    super.initState();
    fetchFarmaciasInicial();
  }

  Future<void> fetchFarmaciasInicial() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      print('token en fetchFarmaciasInicial:');
      print(token);

      setState(() {
        loading = true;
      });

      final url = 'http://192.168.100.6:8001/gatesApp/farmacias';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse != null && jsonResponse.isNotEmpty) {
          setState(() {
            farmacias = jsonResponse;
            print(farmacias);
          });
        } else {
          print('No hay farmacias disponibles.');
          // Manejo de no hay datos
          setState(() {
            farmacias = []; // Asegúrate de manejar una lista vacía en el UI
          });
        }
      } else {
        print('Error with status code: ${response.statusCode}');
        print('Error body: ${response.body}');
        throw Exception('Failed to load farmacias');
      }
    } catch (e) {
      print('Error fetching medicos: $e');
      setState(() {
        farmacias = [];
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  fetchFarmaciasCercanos() async {
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

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token'); // Obtener el token guardado

        if (token == null) {
          throw Exception('Authentication token not available');
        }

        print('token en fetchFarmaciasCercanos');
        print(token);

        final uri = Uri.http(
            '192.168.100.6:8001', '/gatesApp/farmacias/cercanos', {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString()
        });

        final response = await http.get(uri, headers: {
          'Authorization': 'Token $token', // Añadir el token al encabezado
        });

        if (response.statusCode == 200) {
          setState(() {
            farmacias = json.decode(response.body);
          });
        } else {
          throw Exception('Failed to load farmacias with distances');
        }
      } catch (e) {
        print('Error fetching farmacias with distances: $e');
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
          title: Text("Permiso de ubicación requerido"),
          content: Text(
              "Esta función necesita acceso a tu ubicación para calcular distancias."),
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
        title: Text('Farmacias'),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: fetchFarmaciasCercanos,
          ),
          IconButton(
            icon: Icon(Icons.restaurant_menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MedicamentosPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text('Médicos'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.pushReplacement(
                  // Navega sin duplicar la misma vista
                  context,
                  MaterialPageRoute(
                      builder: (context) => MedicosPage(userId: widget.userId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.store),
              title: Text('Farmacias'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.pushReplacement(
                  // Cambia a la página de farmacias
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FarmaciasPage(userId: widget.userId)),
                );
              },
            ),
          ],
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : farmacias.isEmpty
              ? Center(child: Text("No hay farmacias disponibles"))
              : ListView.builder(
                  itemCount: farmacias.length,
                  itemBuilder: (context, index) {
                    final farmacia = farmacias[index];
                    final distanciaStr = farmacia['distancia'] != null
                        ? "${farmacia['distancia'].toStringAsFixed(2)} km"
                        : "Distance not available";
                    return ListTile(
                      leading: farmacia['imagen'] != null
                          ? Image.network(
                              farmacia['imagen'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/defecto.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                      title: Text(
                          farmacia['nombreFarmacia'] ?? "Nombre no disponible"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Dirección: ${(farmacia['contactoFarmacia']?['direccion'] ?? 'No disponible')} y ${(farmacia['contactoFarmacia']?['direccion_secundaria'] ?? 'No disponible')}'),
                          Text('Distancia: $distanciaStr'),
                        ],
                      ),
                      onTap: () async {
                        print('Tap on ${farmacia['nombreFarmacia']}');
                        try {
                          final farmaciaDetails =
                              await fetchFarmaciaDetails(farmacia['id']);
                          print('Nombre: ${farmaciaDetails['nombreFarmacia']}');
                          print(
                              'Contacto: ${farmaciaDetails['contactoFarmacia']}');
                          print(
                              'Servicios: ${farmaciaDetails['medicamentos']}');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FarmaciaDetallesPage(
                                    farmacia: farmaciaDetails),
                              ));
                        } catch (e) {
                          print('Error navigating to farmacia details: $e');
                        }
                      },
                    );
                  },
                ),
    );
  }
}
