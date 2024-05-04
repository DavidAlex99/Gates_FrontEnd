import 'package:flutter/material.dart';
import './quejas_form.dart'; // Asegúrate de que este import refleja la ubicación correcta de tu archivo del formulario de quejas.

class QuejasTab extends StatefulWidget {
  final Map medico;

  QuejasTab({Key? key, required this.medico}) : super(key: key);

  @override
  _QuejasTabState createState() => _QuejasTabState();
}

class _QuejasTabState extends State<QuejasTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportar problemas de ${widget.medico['nombre']}'),
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
        builder: (context) => QuejaFormPage(medicoId: widget.medico['id']),
      ),
    );
  }
}
