import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilTab extends StatefulWidget {
  final Map medico;

  PerfilTab({Key? key, required this.medico}) : super(key: key);

  @override
  _PerfilTabState createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  late Map perfil;
  late List<dynamic> imagenesPerfil;

  @override
  void initState() {
    super.initState();
    perfil = widget.medico['perfil'] ?? {};
    imagenesPerfil = perfil['imagenesPerfil'] ?? [];
  }

  Future<void> _refreshProfileInfo() async {
    try {
      final updatedMedico = await fetchMedicoDetails(widget.medico['id']);
      setState(() {
        perfil = updatedMedico['perfil'] ?? {};
        imagenesPerfil = perfil['imagenesPerfil'] ?? [];
      });
    } catch (e) {
      print('Error refreshing profile info: $e');
    }
  }

  Future<Map> fetchMedicoDetails(int medicoId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url = 'http://127.0.0.1:8000/medicos/$medicoId';
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
      onRefresh: _refreshProfileInfo,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Título: ${perfil['titulo'] ?? 'No disponible'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Descripción: ${perfil['descripcion'] ?? 'No disponible'}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Imágenes del Perfil:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10.0),
              if (imagenesPerfil.isEmpty)
                Text(
                  'No hay imágenes disponibles en la galería.',
                  style: Theme.of(context).textTheme.headlineLarge,
                )
              else
                ...imagenesPerfil.map((imagen) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.network(
                      'http://127.0.0.1:8000${imagen['imagen']}',
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
