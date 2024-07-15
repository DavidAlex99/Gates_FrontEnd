import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'medico_detalles_main.dart'; // Asegúrate de que esta ruta es correcta
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import './servicios_page.dart';
import './farmacias_page.dart';

Future<Map> fetchMedicoDetails(int medicoId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token =
      prefs.getString('token'); // Obtener el token de SharedPreferences
  print('token en fetchMedicoDetails:');
  print(token);

  final String url = 'http://192.168.100.6:8001/medicos/$medicoId';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Token $token', // Añadir el encabezado de autorización
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load medico details');
  }
}

class MedicosPage extends StatefulWidget {
  final String userId;

  MedicosPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MedicosPageState createState() => _MedicosPageState();
}

class _MedicosPageState extends State<MedicosPage> {
  String selectedEspecialidad = 'Todos';
  bool loading = false;
  List<dynamic> medicos = [];

  @override
  void initState() {
    super.initState();
    fetchMedicosInicial();
  }

  Future<void> fetchMedicosInicial() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('token'); // Obtener el token de SharedPreferences
      print('token en fetchMedicosInicial:');
      print(token);

      setState(() {
        loading = true;
      });

      final url = 'http://192.168.100.6:8001/medicos' +
          (selectedEspecialidad != 'Todos'
              ? '?categoria=$selectedEspecialidad'
              : '');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Token $token', // Añadir el encabezado de autorización
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse != null && jsonResponse.isNotEmpty) {
          setState(() {
            medicos = jsonResponse;
            print(medicos);
          });
        } else {
          print('No hay medicos disponibles.');
          setState(() {
            medicos = [];
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
        medicos = [];
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  fetchMedicosCercanos() async {
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

        print('token en fetchMedicosCercanos');
        print(token);

        final uri = Uri.http('192.168.100.6:8001', '/medicos/cercanos', {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'especialidad':
              selectedEspecialidad == 'Todos' ? '' : selectedEspecialidad,
        });

        final response = await http.get(uri, headers: {
          'Authorization': 'Token $token', // Añadir el token al encabezado
        });

        if (response.statusCode == 200) {
          setState(() {
            medicos = json.decode(response.body);
          });
        } else {
          throw Exception('Failed to load medicos with distances');
        }
      } catch (e) {
        print('Error fetching medicos with distances: $e');
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
        title: Text('Medicos'),
        actions: [
          DropdownButton<String>(
            value: selectedEspecialidad,
            onChanged: (newValue) {
              setState(() {
                selectedEspecialidad = newValue!;
                fetchMedicosInicial();
              });
            },
            items: <String>[
              'Todos',
              'CARDIOLOGO',
              'PEDIATRA',
              'NEUROLOGO',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: fetchMedicosCercanos,
          ),
          IconButton(
            icon: Icon(Icons.restaurant_menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ServiciosPage()),
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
          : medicos.isEmpty
              ? Center(child: Text("No hay farmacias disponibles"))
              : ListView.builder(
                  itemCount: medicos.length,
                  itemBuilder: (context, index) {
                    final medico = medicos[index];
                    final distanciaStr = medico['distancia'] != null
                        ? "${medico['distancia'].toStringAsFixed(2)} km"
                        : "Distance not available";
                    return ListTile(
                      leading: Image.network(
                        medico['imagen'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      title: Text(medico['nombre']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Dirección: ${(medico['contacto']?['direccion'] ?? 'No disponible')} y ${(medico['contacto']?['direccion_secundaria'] ?? 'No disponible')}'),
                          Text('Distancia: $distanciaStr'),
                        ],
                      ),
                      onTap: () async {
                        print('Tap on ${medico['nombre']}');
                        try {
                          final medicoDetails =
                              await fetchMedicoDetails(medico['id']);
                          print('Nombre: ${medicoDetails['nombre']}');
                          print(
                              'Especialidad: ${medicoDetails['especialidad']}');
                          print('Perfil: ${medicoDetails['perfil']}');
                          print('Contacto: ${medicoDetails['contacto']}');
                          print('Servicios: ${medicoDetails['servicios']}');
                          print('Citas: ${medicoDetails['citas']}');
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
