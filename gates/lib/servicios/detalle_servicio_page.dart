import 'package:flutter/material.dart';

class DetalleServicioPage extends StatelessWidget {
  final Map servicio;

  DetalleServicioPage({Key? key, required this.servicio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(servicio['imagen']);
    return Scaffold(
      appBar: AppBar(
        title: Text(servicio['nombre']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            servicio['imagen'] != null
                ? Image.network(
                    //'http://192.168.100.6:8001${servicio['imagen']}',
                    'http://127.0.0.1:8000${servicio['imagen']}',
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : SizedBox(height: 300), // Un placeholder o espacio vacío
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                servicio['descripcion'],
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            // Puedes añadir más Widgets aquí para mostrar toda la información que quieras
          ],
        ),
      ),
    );
  }
}
