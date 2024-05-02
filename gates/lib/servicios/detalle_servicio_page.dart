import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/auth_service.dart';
import '../login/login_page.dart';

class DetalleServicioPage extends StatelessWidget {
  final Map servicio;

  DetalleServicioPage({Key? key, required this.servicio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aquí podrías agregar más campos si están disponibles en el mapa de comida
    return Scaffold(
      appBar: AppBar(
        title: Text(servicio['nombre']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            servicio['imagen'] != null
                ? Image.network(
                    'http://192.168.100.6:8001${servicio['imagen']}',
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : SizedBox(height: 300), // Un placeholder o espacio vacío
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                servicio['descripcion'],
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            // Puedes añadir más Widgets aquí para mostrar toda la información que quieras
          ],
        ),
      ),
    );
  }
}
