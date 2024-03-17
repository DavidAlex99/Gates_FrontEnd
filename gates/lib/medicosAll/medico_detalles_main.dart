import 'package:flutter/material.dart';
/*
import '../perfil/perfil_tab.dart'; // Asegúrate de crear este archivo.
import '../servicios/servicios_tab.dart'; // Asegúrate de crear este archivo.
import '../contacto/contacto_tab.dart'; // Asegúrate de crear este archivo.
*/

class MedicoDetallesPage extends StatelessWidget {
  final Map medico;

  MedicoDetallesPage({required this.medico});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(medico['nombre']),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Perfil'),
              Tab(text: 'Servicios'),
              Tab(text: 'Contacto'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            /*
            PerfilTab(emprendimiento: emprendimiento),
            ServiciosTab(emprendimiento: emprendimiento),
            ContactoTab(emprendimiento: emprendimiento),
            */
          ],
        ),
      ),
    );
  }
}
