import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ContactoTab extends StatelessWidget {
  final Map medico;

  ContactoTab({required this.medico});

  @override
  Widget build(BuildContext context) {
    Map contacto = medico['contacto'] ?? {};
    List imagenesContacto = contacto['imagenesContacto'] ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text('Dirección:'),
            subtitle: Text(contacto['direccion'] ?? 'No disponible'),
            leading: Icon(Icons.location_on),
          ),
          ListTile(
            title: Text('Teléfono:'),
            subtitle: Text(contacto['telefono'] ?? 'No disponible'),
            leading: Icon(Icons.phone),
          ),
          ListTile(
            title: Text('Correo Electrónico:'),
            subtitle: Text(contacto['correo'] ?? 'No disponible'),
            leading: Icon(Icons.email),
          ),
          if (imagenesContacto.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.0,
                enlargeCenterPage: true,
              ),
              items: imagenesContacto.map((img) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.network(
                        img['imagen'],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
