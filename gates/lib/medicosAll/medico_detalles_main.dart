import 'package:flutter/material.dart';
import '../perfil/perfil_tab.dart'; // Asegúrate de crear este archivo.
import '../servicios/servicios_tab.dart'; // Asegúrate de crear este archivo.
import '../contacto/contacto_tab.dart'; // Asegúrate de crear este archivo.

class MedicoDetallesPage extends StatefulWidget {
  final Map medico;

  MedicoDetallesPage({Key? key, required this.medico}) : super(key: key);

  @override
  _MedicoDetallesPageState createState() => _MedicoDetallesPageState();
}

class _MedicoDetallesPageState extends State<MedicoDetallesPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Número de secciones
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.medico['nombre'] ?? 'Detalle del Medico'),
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
            PerfilTab(medico: widget.medico),
            ServiciosTab(medico: widget.medico),
            ContactoTab(medico: widget.medico),
          ],
        ),
      ),
    );
  }
}
