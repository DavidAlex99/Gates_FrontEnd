import 'package:flutter/material.dart';
import '../perfil/perfil_tab.dart';
import '../servicios/servicios_tab.dart';
import '../contacto/contacto_tab.dart'; // Asegúrate de crear este archivo.
import '../citas/citas_tab.dart'; // Asegúrate de crear este archivo.

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
      length: 4, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.medico['nombre'] ?? 'Detalle del Medico'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Perfil'),
              Tab(icon: Icon(Icons.healing), text: 'Servicios'),
              Tab(icon: Icon(Icons.contacts), text: 'Contacto'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Citas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PerfilTab(medico: widget.medico),
            ServiciosTab(medico: widget.medico),
            ContactoTab(medico: widget.medico),
            CitasTab(medico: widget.medico),
            //ServiciosTab(medico: widget.medico),
          ],
        ),
      ),
    );
  }
}
