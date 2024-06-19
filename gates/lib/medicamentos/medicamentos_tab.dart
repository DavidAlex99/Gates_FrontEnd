import 'package:flutter/material.dart';
import 'detalle_medicamento_page.dart';

class MedicamentosTab extends StatelessWidget {
  final Map farmacia;

  MedicamentosTab({Key? key, required this.farmacia}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> medicamentos = farmacia['medicamentos'] ?? [];
    print('farmacia medicamentos');
    print(medicamentos);

    return ListView.builder(
      itemCount: medicamentos.length,
      itemBuilder: (context, index) {
        var medicamento = medicamentos[index];
        return Card(
          child: ListTile(
            title: Text(medicamento['nombre']),
            subtitle: Text(medicamento['descripcion']),
            leading: medicamento['imagen'] != null
                ? Image.network(
                    'http://192.168.100.6:8001${medicamento['imagen']}',
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
                  builder: (context) =>
                      DetalleMedicamentoPage(medicamento: medicamento),
                ));
              },
            ),
          ),
        );
      },
    );
  }
}
