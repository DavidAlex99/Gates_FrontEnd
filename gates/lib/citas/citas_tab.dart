import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './pago_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitasTab extends StatefulWidget {
  final Map medico;

  CitasTab({Key? key, required this.medico}) : super(key: key);

  @override
  _CitasTabState createState() => _CitasTabState();
}

class _CitasTabState extends State<CitasTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List citasDisponibles = [];
  List citasReservadas = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    fetchCitas();
  }

  Future<void> fetchCitas() async {
    fetchCitasDisponibles();
    fetchCitasReservadas();
  }

  Future<void> fetchCitasDisponibles() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('token'); // Obtener el token de SharedPreferences
      print('token en _fetchResenas:');
      print(token);

      if (token == null) {
        throw Exception('Authentication token is not available.');
      }

      final response = await http.get(
        Uri.parse(
            'http://192.168.100.6:8001/gatesApp/medicos/${widget.medico['id']}/citas/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          citasDisponibles = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load citas');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las reseñas: ${e.toString()}')),
      );
    }
  }

  Future<void> fetchCitasReservadas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("prefs contenido");
    print(prefs.getInt('userId'));
    int? userId = prefs.getInt(
        'userId'); // Asegúrate de que este valor se guarda cuando el usuario se loguea

    if (userId == null) {
      print('userId ID is not available');
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('token'); // Obtener el token de SharedPreferences
      print("token en fetchCitasReservadas");
      print(token);
      int? userId = prefs.getInt(
          'userId'); // Asegúrate de que este valor se guarda cuando el usuario se loguea

      if (userId == null) {
        print('userId ID is not available');
        return;
      }
      if (token == null) {
        throw Exception('Authentication token is not available.');
      }

      // Asegúrate de que la URL esté correctamente configurada para obtener solo las citas reservadas
      final response = await http.get(
        Uri.parse(
            'http://192.168.100.6:8001/gatesApp/medicos/${widget.medico['id']}/citas/$userId/reservadas/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          citasReservadas = json.decode(
              response.body); // Asume que el backend devuelve un array JSON
        });
      } else {
        throw Exception('Failed to load reserved citas');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al cargar citas reservadas: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Citas"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Disponibles'),
            Tab(text: 'Reservadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildCitasList(
              citasDisponibles), // Usa un método para construir la lista
          buildCitasList(citasReservadas),
        ],
      ),
    );
  }

  Widget buildCitasList(List citas) {
    return RefreshIndicator(
      onRefresh: fetchCitas,
      child: ListView.builder(
        itemCount: citas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
                '${citas[index]['fecha_hora_inicio']} - ${citas[index]['fecha_hora_fin']}'),
            subtitle: Text('Precio: ${citas[index]['precio']} USD'),
            onTap: () {
              double precio = double.parse(citas[index]['precio'].toString());
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                              precio: precio, citaId: citas[index]['id'])))
                  .then((_) => fetchCitas()); // Recargar citas al regresar
            },
          );
        },
      ),
    );
  }
}
