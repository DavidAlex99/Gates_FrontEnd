import 'package:flutter/material.dart';

class PerfilTab extends StatelessWidget {
  final Map medico;

  PerfilTab({Key? key, required this.medico}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map perfil = medico['perfil'] ?? {};
    List<dynamic> imagenesPerfil = perfil['imagenesPerfil'] ?? [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título: ${perfil['titulo'] ?? 'No disponible'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Descripción: ${perfil['descripcion'] ?? 'No disponible'}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Imágenes del Perfil:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10.0),
            if (imagenesPerfil.isEmpty)
              Text(
                'No hay imágenes disponibles en la galería.',
                style: Theme.of(context).textTheme.bodyText2,
              )
            else
              ...imagenesPerfil.map((imagen) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.network(
                    'http://192.168.100.6:8001${imagen['imagen']}',
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
