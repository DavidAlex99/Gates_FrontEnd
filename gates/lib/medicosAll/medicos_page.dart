import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'medico_detalles_main.dart'; // Asegúrate de que esta ruta es correcta
import 'package:shared_preferences/shared_preferences.dart';

class MedicosPage extends StatefulWidget {
  final String userId;

  MedicosPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MedicosPageState createState() => _MedicosPageState();
}

class _MedicosPageState extends State<MedicosPage> {
  final String apiUrl = "http://192.168.100.6:8001/gatesApp/medicos";
  List<dynamic> medicos = [];
  String? selectedEspecialidad = 'Todos';

  @override
  void initState() {
    super.initState();
    fetchMedicos();
  }

  fetchMedicos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
        'auth_token'); // Usa aquí la misma clave que usaste para guardar el token

    String filterUrl = apiUrl;
    if (selectedEspecialidad != null && selectedEspecialidad != 'Todos') {
      filterUrl += '?especialidad=$selectedEspecialidad';
    }

    var response = await http.get(
      Uri.parse(filterUrl),
      headers: token != null
          ? {
              'Content-Type': 'application/json',
              'Authorization': 'Token $token',
            }
          : {
              'Content-Type': 'application/json',
            },
    );

    if (response.statusCode == 200) {
      setState(() {
        medicos = json.decode(response.body);
      });
    } else {
      print('Failed to load medicos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicos'),
        actions: <Widget>[
          DropdownButton<String>(
            value: selectedEspecialidad,
            underline: Container(),
            onChanged: (String? newValue) {
              setState(() {
                selectedEspecialidad = newValue!;
                fetchMedicos();
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

          // re direccion a otro filtro
          /*
          IconButton(
            icon: Icon(Icons.medical_information),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ComidasPage()),
              );
            },
          ),*/
          /*
          IconButton(
            icon: Icon(Icons.party_mode),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventosPage()),
              );
            },
          ),*/
        ],
      ),
      body: ListView.builder(
        itemCount: medicos.length,
        itemBuilder: (context, index) {
          var medico = medicos[index];
          return ListTile(
            leading: Image.network(
              medico['imagen'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            title: Text(medico['nombre']),
            subtitle: Text('Especialidad: ${medico['especialidad']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicoDetallesPage(medico: medico),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
