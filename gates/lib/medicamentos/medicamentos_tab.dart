import 'package:flutter/material.dart';
import 'detalle_medicamento_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MedicamentosTab extends StatefulWidget {
  final Map farmacia;

  MedicamentosTab({Key? key, required this.farmacia}) : super(key: key);

  @override
  _MedicamentosTabState createState() => _MedicamentosTabState();
}

class _MedicamentosTabState extends State<MedicamentosTab> {
  late List<dynamic> medicamentos;

  @override
  void initState() {
    super.initState();
    medicamentos = widget.farmacia['medicamentos'] ?? [];
  }

  Future<void> _refreshMedicamentos() async {
    try {
      final updatedFarmacia = await fetchFarmaciaDetails(widget.farmacia['id']);
      setState(() {
        medicamentos = updatedFarmacia['medicamentos'] ?? [];
      });
    } catch (e) {
      print('Error refreshing medicamentos: $e');
    }
  }

  Future<Map> fetchFarmaciaDetails(int farmaciaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url = 'http://127.0.0.1:8000/farmacias/$farmaciaId';
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshMedicamentos,
      child: ListView.builder(
        itemCount: medicamentos.length,
        itemBuilder: (context, index) {
          var medicamento = medicamentos[index];
          return Card(
            child: ListTile(
              title: Text(medicamento['nombre']),
              subtitle: Text(medicamento['descripcion']),
              leading: medicamento['imagen'] != null
                  ? Image.network(
                      'http://127.0.0.1:8000${medicamento['imagen']}',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : SizedBox(
                      width: 100,
                      height: 100), // Un placeholder o espacio vacío
              trailing: IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  // Navegar a la nueva página de detalles
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        DetalleMedicamentoPage(medicamento: medicamento),
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
