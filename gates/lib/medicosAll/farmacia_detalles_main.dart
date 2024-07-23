import 'package:flutter/material.dart';
import '../medicamentos/medicamentos_tab.dart';
import '../contacto/contactoFarmacia_tab.dart';
import '../buzonQueja/quejasFarmacia_tab.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/auth_service.dart';
import '../login/login_page.dart';

class FarmaciaDetallesPage extends StatefulWidget {
  final Map farmacia;

  FarmaciaDetallesPage({Key? key, required this.farmacia}) : super(key: key);

  @override
  _FarmaciaDetallesPageState createState() => _FarmaciaDetallesPageState();
}

class _FarmaciaDetallesPageState extends State<FarmaciaDetallesPage> {
  late Map farmacia;

  @override
  void initState() {
    super.initState();
    farmacia = widget.farmacia;
  }

  Future<void> _refreshFarmaciaDetails() async {
    try {
      final updatedFarmacia = await fetchFarmaciaDetails(farmacia['id']);
      setState(() {
        farmacia = updatedFarmacia;
      });
    } catch (e) {
      print('Error refreshing farmacia details: $e');
    }
  }

  Future<Map> fetchFarmaciaDetails(int farmaciaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    //final String url = 'http://127.0.0.1:8000/farmacias/$farmaciaId';
    final String url = 'http://192.168.100.6:8001/farmacias/$farmaciaId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load farmacia details');
    }
  }

  void _logout() async {
    await AuthService().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _openQuejasFarmaciaTab() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => QuejasFarmaciaTab(farmacia: widget.farmacia)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.farmacia['nombre'] ?? 'Detalle de farmacia'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.report_problem),
              onPressed: _openQuejasFarmaciaTab,
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.healing), text: 'Medicamentos'),
              Tab(icon: Icon(Icons.contacts), text: 'Contacto'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _refreshFarmaciaDetails,
              child: MedicamentosTab(farmacia: farmacia),
            ),
            RefreshIndicator(
              onRefresh: _refreshFarmaciaDetails,
              child: ContactoFarmaciaTab(farmacia: farmacia),
            ),
          ],
        ),
      ),
    );
  }
}
