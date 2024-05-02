import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'medico_detalles_main.dart'; // Asegúrate de que esta ruta es correcta
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import './servicios_page.dart';

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
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final url = 'http://192.168.100.6:8001/gatesApp/medicos' +
          (selectedEspecialidad != 'Todos'
              ? '?categoria=$selectedEspecialidad'
              : '');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token', // Añadir el token al encabezado
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          medicos = json.decode(response.body);
          print(medicos);
        });
      } else {
        throw Exception('Failed to load medicos');
      }
    } catch (e) {
      print('Error fetching medicos: $e');
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

        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('auth_token');

        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final uri =
            Uri.http('192.168.100.6:8001', '/gatesApp/medicos/cercanos', {
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
      body: loading
          ? Center(child: CircularProgressIndicator())
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
                  subtitle: Text(
                      'Dirección: ${medico['direccion']}\nDistancia: $distanciaStr'),
                  onTap: () async {
                    print('Tap on ${medico['nombre']}');
                    try {
                      final medicoDetails =
                          await fetchMedicoDetails(medico['id']);
                      print('Nombre: ${medicoDetails['nombre']}');
                      print('Especialidad: ${medicoDetails['especialidad']}');
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
