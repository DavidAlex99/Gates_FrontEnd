import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      'http://192.168.100.6:8001/gatesApp'; // Reemplaza esto por la URL real de tu backen

  // Método para guardar el token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api-token-auth/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String token = responseData['token'];
      await _saveToken(token); // Guardar el token
      return token;
    } else {
      return null;
    }
  }

  Future<String?> register(
      String username, String email, String password, String nombre) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
        'nombre': nombre,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      String token = responseData['token'];
      await _saveToken(token); // Guardar el token
      return token;
    } else {
      return null;
    }
  }
}
