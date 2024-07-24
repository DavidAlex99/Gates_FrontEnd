import 'package:flutter/material.dart';

class DetalleMedicamentoPage extends StatelessWidget {
  final Map medicamento;

  DetalleMedicamentoPage({Key? key, required this.medicamento})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicamento['nombre']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            medicamento['imagen'] != null
                ? Image.network(
                    'http://192.168.100.6:8001${medicamento['imagen']}',
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : SizedBox(height: 300),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                medicamento['descripcion'],
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
