import 'package:flutter/material.dart';

class ServiciosTab extends StatelessWidget {
  final Map medico;

  ServiciosTab({required this.medico});

  @override
  Widget build(BuildContext context) {
    // Asumimos que "comidas" es una lista de elementos del menú que está en el emprendimiento Map
    List servicios = medico['servicios'] ?? [];

    return ListView.builder(
      itemCount: servicios.length,
      itemBuilder: (context, index) {
        var servicio = servicios[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            leading: servicio['imagen'] != null
                ? Image.network(
                    servicio['imagen'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : null,
            title: Text(servicio['nombre']),
            subtitle:
                Text('${servicio['descripcion']} - \$${servicio['precio']}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
