import 'package:flutter/material.dart';
import './detalle_servicio_page.dart';

class ServiciosTab extends StatelessWidget {
  final Map medico;

  ServiciosTab({Key? key, required this.medico}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> servicios = medico['servicios'] ?? [];
    print('medico servicios');
    print(servicios);

    return ListView.builder(
      itemCount: servicios.length,
      itemBuilder: (context, index) {
        var servicio = servicios[index];
        return Card(
          child: ListTile(
            title: Text(servicio['nombre']),
            subtitle: Text(servicio['descripcion']),
            leading: servicio['imagen'] != null
                ? Image.network(
                    'http://192.168.100.6:8001${servicio['imagen']}',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : SizedBox(
                    width: 100, height: 100), // Un placeholder o espacio vacío
            trailing: IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                // Navegar a la nueva página de detalles
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DetalleServicioPage(servicio: servicio),
                ));
              },
            ),
          ),
        );
      },
    );
  }
}
