import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ResenaFormPage extends StatefulWidget {
  final int medicoId;

  ResenaFormPage({required this.medicoId});

  @override
  _ResenaFormPageState createState() => _ResenaFormPageState();
}

class _ResenaFormPageState extends State<ResenaFormPage> {
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _calificacionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    _calificacionController.dispose();
    super.dispose();
  }

  Future<void> _enviarResena() async {
    if (_comentarioController.text.isEmpty ||
        _calificacionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, completa todos los campos.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('Authentication token is not available.');
      }

      final response = await http.post(
        Uri.parse(
            "http://192.168.100.6:8001/gatesApp/medicos/${widget.medicoId}/reseña/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'comentario': _comentarioController.text,
          'calificacion': int.parse(_calificacionController.text),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reseña enviada con éxito')),
        );
        Navigator.pop(
            context); // Regresa a la página anterior tras enviar la reseña
      } else {
        throw Exception(
            'Failed to send review. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar la reseña: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deja tu Reseña'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _comentarioController,
              decoration: InputDecoration(
                labelText: 'Comentario',
                hintText: 'Escribe tu opinión sobre el emprendimiento',
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _calificacionController,
              decoration: InputDecoration(
                labelText: 'Calificación',
                hintText: 'Califica de 1 a 5',
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _enviarResena,
                    child: Text('Enviar Reseña'),
                  ),
          ],
        ),
      ),
    );
  }
}
