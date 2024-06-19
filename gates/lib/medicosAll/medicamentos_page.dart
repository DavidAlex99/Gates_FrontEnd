import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './farmacia_detalles_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Map> fetchFarmaciaDetails(int farmaciaId) async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  print("Token is: $token"); // Esto mostrará el token en la consola.

  final String url = 'http://192.168.100.6:8001/gatesApp/farmacias/$farmaciaId';
  final response = await http.get(
    Uri.parse(url),
    headers: token != null ? {'Authorization': 'Token $token'} : {},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load farmacia details');
  }
}

class MedicamentosPage extends StatefulWidget {
  @override
  _MedicamentosPageState createState() => _MedicamentosPageState();
}

class _MedicamentosPageState extends State<MedicamentosPage> {
  List<dynamic> medicamentos = [];
  bool loading = false;
  List<dynamic> filteredMedicamentos = [];
  String filtroPrecio = 'Todos';
  String filtroAlfabetico = 'Todos';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMedicamentosInicial();
  }

  Future<void> fetchMedicamentosInicial() async {
    try {
      setState(() {
        loading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('token'); // Obtener el token de SharedPreferences
      print('token en fetchMedicamentosInicial:');
      print(token);

      final url = 'http://192.168.100.6:8001/gatesApp/medicamentos';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token', // Añadir el token al encabezado
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          medicamentos = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load medicamentos');
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

  Future<void> fetchMedicamentosCercanos() async {
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token =
            prefs.getString('token'); // Obtener el token de SharedPreferences
        print('token en fetchFarmaciasCercanos:');
        print(token);

        var queryParams = {
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
        };
        var uri = Uri.http('192.168.100.6:8001',
            '/gatesApp/medicamentos/cercanos', queryParams);

        final response = await http.get(uri, headers: {
          'Authorization': 'Token $token',
        });

        if (response.statusCode == 200) {
          setState(() {
            medicamentos = json.decode(response.body);
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
    filteredMedicamentos =
        List.from(medicamentos); // Crear una copia de los servicios

    // Filtrado por precio
    if (filtroPrecio == 'Ascendente') {
      filteredMedicamentos.sort((a, b) => (a['precio']).compareTo(b['precio']));
    } else if (filtroPrecio == 'Descendente') {
      filteredMedicamentos.sort((a, b) => (b['precio']).compareTo(a['precio']));
    }

    // Orden alfabético
    if (filtroAlfabetico == 'Ascendente') {
      filteredMedicamentos.sort((a, b) => a['nombre'].compareTo(b['nombre']));
    } else if (filtroAlfabetico == 'Descendente') {
      filteredMedicamentos.sort((a, b) => b['nombre'].compareTo(a['nombre']));
    }

    // Filtrado por búsqueda de texto
    if (searchController.text.isNotEmpty) {
      filteredMedicamentos = filteredMedicamentos.where((medicamento) {
        return medicamento['nombre']
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
        title: Text('Medicamentos'),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed:
                fetchMedicamentosCercanos, // Este método aún necesita ser implementado
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
              itemCount: filteredMedicamentos.length,
              itemBuilder: (context, index) {
                final medicamento = filteredMedicamentos[index];
                final distanciaStr = medicamento['distancia'] != null
                    ? "${medicamento['distancia'].toStringAsFixed(2)} km"
                    : "Distance not available";
                return ListTile(
                  title: Text(medicamento['nombre']),
                  subtitle: Text(
                      '${medicamento['descripcion']} - \$${medicamento['precio']} - Distancia: $distanciaStr'),
                  leading: medicamento['imagen'] != null
                      ? Image.network(medicamento['imagen'],
                          width: 100, height: 100, fit: BoxFit.cover)
                      : null,
                  onTap: () async {
                    try {
                      final farmaciaDetails = await fetchFarmaciaDetails(
                          medicamento['farmacia_id']);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FarmaciaDetallesPage(farmacia: farmaciaDetails),
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
