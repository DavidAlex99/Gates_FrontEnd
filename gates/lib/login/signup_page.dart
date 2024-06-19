import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'session_manager.dart';
import '../MedicosAll/medicos_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController =
      TextEditingController(); // Campo adicional para el teléfono

  void _register() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String password = _passwordController.text;
    String telefono =
        _telefonoController.text; // Recolectar el valor del teléfono
    String? userId = await AuthService()
        .register(username, email, firstName, lastName, password, telefono);
    if (userId != null) {
      // pasar el userId del usuario actual
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MedicosPage(userId: userId)),
      );
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
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contrasena'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: 'Telefono'),
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
