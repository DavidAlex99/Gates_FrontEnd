import 'package:flutter/material.dart';

class PerfilTab extends StatelessWidget {
  final Map medico;

  PerfilTab({required this.medico});

  @override
  Widget build(BuildContext context) {
    var perfil = medico['perfil']; // Asumimos que esta clave existe en el mapa.

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              perfil['descripcion'],
              style: TextStyle(fontSize: 16),
            ),
          ),
          ...perfil['imagenesPerfil']
              .map((img) => Image.network(img['imagen']))
              .toList(),
        ],
      ),
    );
  }
}
