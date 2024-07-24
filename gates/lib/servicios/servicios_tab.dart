import 'package:flutter/material.dart';
import './detalle_servicio_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ServiciosTab extends StatefulWidget {
  final Map medico;

  ServiciosTab({Key? key, required this.medico}) : super(key: key);

  @override
  _ServiciosTabState createState() => _ServiciosTabState();
}

class _ServiciosTabState extends State<ServiciosTab> {
  late List<dynamic> servicios;

  @override
  void initState() {
    super.initState();
    servicios = widget.medico['servicios'] ?? [];
  }

  Future<void> _refreshServicesInfo() async {
    try {
      final updatedMedico = await fetchMedicoDetails(widget.medico['id']);
      setState(() {
        servicios = updatedMedico['servicios'] ?? [];
      });
    } catch (e) {
      print('Error refreshing services info: $e');
    }
  }

  Future<Map> fetchMedicoDetails(int medicoId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url = 'http://192.168.100.6:8001/medicos/$medicoId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load medico details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshServicesInfo,
      child: ListView.builder(
        itemCount: servicios.length,
        itemBuilder: (context, index) {
          var servicio = servicios[index];
          return Card(
            child: ListTile(
              title: Text(servicio['nombre']),
              subtitle: Text(servicio['descripcion']),
              leading: servicio['imagen'] != null
                  ? Image.network(
                      'http://192.168.100.6:8001${servicio['imagen']}',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : SizedBox(width: 100, height: 100),
              trailing: IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        DetalleServicioPage(servicio: servicio),
                  ));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
