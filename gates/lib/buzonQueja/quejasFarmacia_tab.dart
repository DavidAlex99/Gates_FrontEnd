import 'package:flutter/material.dart';
import './quejasFarmacia_form.dart'; // Asegúrate de que este import refleja la ubicación correcta de tu archivo del formulario de quejas.

class QuejasFarmaciaTab extends StatefulWidget {
  final Map farmacia;

  QuejasFarmaciaTab({Key? key, required this.farmacia}) : super(key: key);

  @override
  _QuejasFarmaciaTabState createState() => _QuejasFarmaciaTabState();
}

class _QuejasFarmaciaTabState extends State<QuejasFarmaciaTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Reportar problemas de ${widget.farmacia['nombreFarmacia']}'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Reportar un problema'),
          onPressed: _navigateToQuejaForm,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToQuejaForm,
        child: Icon(Icons.add),
        tooltip: 'Reportar Nuevo Problema',
      ),
    );
  }

  void _navigateToQuejaForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuejaFarmaciaFormPage(farmaciaId: widget.farmacia['id']),
      ),
    );
  }
}
