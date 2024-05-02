import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  List<dynamic> citasDisponibles = [];
  List<dynamic> citasReservadas = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    fetchCitas();
  }

  fetchCitas() async {
    await fetchCitasDisponibles();
    await fetchCitasReservadas();
  }

  Future<void> fetchCitasDisponibles() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    print('tokenj en fectchcitas');
    print(token);
    var url =
        'http://192.168.100.6:8001/gatesApp/medicos/${widget.medico['id']}/citas/';
    var response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Token $token'});
    if (response.statusCode == 200) {
      setState(() {
        citasDisponibles = json.decode(response.body);
      });
    } else {
      print('Failed to load citas disponibles');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCitasReservadas() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    var url =
        'http://192.168.100.6:8001/gatesApp/medicos/${widget.medico['id']}/citas/reservadas';
    var response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Token $token'});
    if (response.statusCode == 200) {
      setState(() {
        citasReservadas = json.decode(response.body);
      });
    } else {
      print('Failed to load citas reservadas');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Citas de ${widget.medico['nombre']}'),
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
          buildCitasList(citasDisponibles, false),
          buildCitasList(citasReservadas, true),
        ],
      ),
    );
  }

  Widget buildCitasList(List<dynamic> citas, bool isReservadas) {
    return ListView.builder(
      itemCount: citas.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Fecha: ${citas[index]['fecha_hora_inicio']}'),
          subtitle: Text('Estado: ${citas[index]['estado']}'),
          trailing: isReservadas
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () => cancelarCita(citas[index]['id']),
                )
              : IconButton(
                  icon: Icon(Icons.book_online),
                  onPressed: () => reservarCita(citas[index]['id']),
                ),
        );
      },
    );
  }

  void reservarCita(int citaId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    var url =
        'http://192.168.100.6:8001/gatesApp/medicos/${widget.medico['id']}/citas/reservar/$citaId/';
    var response = await http
        .post(Uri.parse(url), headers: {'Authorization': 'Token $token'});
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cita reservada con éxito')));
      fetchCitas();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al reservar cita')));
    }
  }

  void cancelarCita(int citaId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    var url =
        'http://192.168.100.6:8001/gatesApp/medicos/${widget.medico['id']}/citas/cancelar/$citaId/';
    var response = await http
        .post(Uri.parse(url), headers: {'Authorization': 'Token $token'});
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cita cancelada con éxito')));
      fetchCitas();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cancelar cita')));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
