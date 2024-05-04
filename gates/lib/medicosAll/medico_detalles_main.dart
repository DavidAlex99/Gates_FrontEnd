import 'package:flutter/material.dart';
import '../perfil/perfil_tab.dart';
import '../servicios/servicios_tab.dart';
import '../contacto/contacto_tab.dart'; // Asegúrate de crear este archivo.
import '../citas/citas_tab.dart'; // Asegúrate de crear este archivo.
import '../buzonQueja/quejas_tab.dart';
import '../resenas/resenas_tab.dart';

class MedicoDetallesPage extends StatefulWidget {
  final Map medico;

  MedicoDetallesPage({Key? key, required this.medico}) : super(key: key);

  @override
  _MedicoDetallesPageState createState() => _MedicoDetallesPageState();
}

class _MedicoDetallesPageState extends State<MedicoDetallesPage> {
  void _openQuejasTab() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => QuejasTab(medico: widget.medico)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.medico['nombre'] ?? 'Detalle del Medico'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.report_problem),
              onPressed: _openQuejasTab,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Perfil'),
              Tab(icon: Icon(Icons.healing), text: 'Servicios'),
              Tab(icon: Icon(Icons.contacts), text: 'Contacto'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Citas'),
              Tab(text: 'Deja tu opinión'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PerfilTab(medico: widget.medico),
            ServiciosTab(medico: widget.medico),
            ContactoTab(medico: widget.medico),
            CitasTab(medico: widget.medico),
            ResenasTab(medico: widget.medico),
            //ServiciosTab(medico: widget.medico),
          ],
        ),
      ),
    );
  }
}
