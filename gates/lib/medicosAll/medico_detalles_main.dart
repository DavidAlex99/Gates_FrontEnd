import 'package:flutter/material.dart';
import '../perfil/perfil_tab.dart';
import '../servicios/servicios_tab.dart';
import '../contacto/contacto_tab.dart';
import '../citas/citas_tab.dart';
import '../buzonQueja/quejas_tab.dart';
import '../resenas/resenas_tab.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../login/auth_service.dart';
import '../login/login_page.dart';

class MedicoDetallesPage extends StatefulWidget {
  final Map medico;

  MedicoDetallesPage({Key? key, required this.medico}) : super(key: key);

  @override
  _MedicoDetallesPageState createState() => _MedicoDetallesPageState();
}

class _MedicoDetallesPageState extends State<MedicoDetallesPage> {
  late Map medico;

  @override
  void initState() {
    super.initState();
    medico = widget.medico;
  }

  Future<void> _refreshMedicoDetails() async {
    try {
      final updatedMedico = await fetchMedicoDetails(medico['id']);
      setState(() {
        medico = updatedMedico;
      });
    } catch (e) {
      print('Error refreshing medico details: $e');
    }
  }

  Future<Map> fetchMedicoDetails(int medicoId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('token en fetchMedicoDetails:');
    print(token);

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

  void _logout() async {
    await AuthService().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _openQuejasTab() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => QuejasTab(medico: widget.medico)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.medico['nombre'] ?? 'Detalle del Medico'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.report_problem),
              onPressed: _openQuejasTab,
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Perfil'),
              Tab(icon: Icon(Icons.healing), text: 'Servicios'),
              Tab(icon: Icon(Icons.contacts), text: 'Contacto'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Citas'),
              Tab(text: 'Deja tu opinión'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _refreshMedicoDetails,
              child: PerfilTab(medico: medico),
            ),
            RefreshIndicator(
              onRefresh: _refreshMedicoDetails,
              child: ServiciosTab(medico: medico),
            ),
            RefreshIndicator(
              onRefresh: _refreshMedicoDetails,
              child: ContactoTab(medico: medico),
            ),
            RefreshIndicator(
              onRefresh: _refreshMedicoDetails,
              child: CitasTab(medico: medico),
            ),
            RefreshIndicator(
              onRefresh: _refreshMedicoDetails,
              child: ResenasTab(medico: medico),
            ),
          ],
        ),
      ),
    );
  }
}
