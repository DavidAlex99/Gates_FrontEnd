import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      'http://192.168.100.6:8001/gatesApp'; // Reemplaza esto por la URL real de tu backen

  // Método para guardar el token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print('Token saved: $token'); // Imprime el token para verificar
  }

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/loginPaciente/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        final userId = responseData['user_id'] as int; // Asegurarse que es int
        String token = responseData['token'];
        print('token en login:');
        print(token);
        print('userId en login:');
        print(userId);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);
        await prefs.setString('token', token);
        return token;
      } catch (e) {
        print('Error parsing data from the login response: $e');
        return null;
      }
    } else {
      print('Failed to log in: ${response.body}');
      return null;
    }
  }

  Future<String?> register(String username, String email, String first_name,
      String last_name, String password, String telefono) async {
    final response = await http.post(
      Uri.parse('$baseUrl/registerPaciente/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'first_name': first_name,
        'last_name': last_name,
        'password': password,
        'telefono': telefono,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final userId =
          responseData['user_id'] as int; // Asegúrate que es un entero
      String token = responseData['token'];
      print('Token en register:');
      print(token);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);
      await prefs.setString('token', token);
      return token;
    } else {
      print('Failed to register: ${response.body}');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      // Realizar la petición de cierre de sesión al servidor
      final response = await http.post(
        Uri.parse('$baseUrl/logoutPaciente/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );
      // Verificar la respuesta aquí si es necesario
    }
    // Eliminar el token del almacenamiento local independientemente de la respuesta del servidor
    await prefs.remove('token');
  }
}
