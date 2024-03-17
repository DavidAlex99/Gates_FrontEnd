import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'session_manager.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController =
      TextEditingController(); // Campo adicional para el teléfono

  void _register() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String nombre = _nombreController.text; // Recolectar el valor del teléfono
    String? userId =
        await AuthService().register(username, email, password, nombre);
    if (userId != null) {
      // pasar el userId del usuario actual
      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EmprendimientosPage(userId: userId)
        ),
      );*/
    } else {
      // Mostrar error si el registro falla
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error de Registro"),
            content: Text(
                "No se pudo completar el registro. Por favor, inténtalo de nuevo."),
            actions: <Widget>[
              TextButton(
                child: Text("Cerrar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
