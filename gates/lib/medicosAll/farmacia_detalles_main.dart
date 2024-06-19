import 'package:flutter/material.dart';
import '../medicamentos/medicamentos_tab.dart';
import '../contacto/contactoFarmacia_tab.dart';
import '../buzonQueja/quejasFarmacia_tab.dart';

class FarmaciaDetallesPage extends StatefulWidget {
  final Map farmacia;

  FarmaciaDetallesPage({Key? key, required this.farmacia}) : super(key: key);

  @override
  _FarmaciaDetallesPageState createState() => _FarmaciaDetallesPageState();
}

class _FarmaciaDetallesPageState extends State<FarmaciaDetallesPage> {
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
            MedicamentosTab(farmacia: widget.farmacia),
            ContactoFarmaciaTab(farmacia: widget.farmacia),
          ],
        ),
      ),
    );
  }
}
