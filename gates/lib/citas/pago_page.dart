import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  final double precio;
  final int citaId;

  PaymentScreen({Key? key, required this.precio, required this.citaId})
      : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pago')),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // print the loading progress to the console
            // you can use this value to show a progress bar if you want
            debugPrint("Loading: $progress%");
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadCreatePaymentUrl();
  }

  void _loadCreatePaymentUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("prefs contenido");
    print(prefs.getInt('userId'));
    int? userId = prefs.getInt(
        'userId'); // Asegúrate de que este valor se guarda cuando el usuario se loguea

    if (userId == null) {
      print('userId ID is not available');
      return;
    }

    final response = await http.get(
      Uri.parse(
        'http://192.168.100.6:8001/gatesApp/create_payment/${widget.precio.toStringAsFixed(2)}/${widget.citaId}/$userId',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final approvalUrl = jsonData['approval_url'];

      // Load the approval URL in the WebView
      _controller.loadRequest(Uri.parse(approvalUrl));
    } else {
      // Handle error
    }
  }
}

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './pago_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitasTab extends StatefulWidget {
  final Map medico;

  CitasTab({Key? key, required this.medico}) : super(key: key);

  @override
  _CitasTabState createState() => _CitasTabState();
}

class _CitasTabState extends State<CitasTab> {
  List citas = [];

  @override
  void initState() {
    super.initState();
    fetchCitas();
  }

  Future<void> fetchCitas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('token'); // Obtener el token de SharedPreferences
      print('token en _fetchResenas:');
      print(token);

      if (token == null) {
        throw Exception('Authentication token is not available.');
      }

      final response = await http.get(
        Uri.parse(
            'http://192.168.100.6:8001/gatesApp/medicos/${widget.medico['id']}/citas/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          citas = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load citas');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las reseñas: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Citas Disponibles")),
      body: RefreshIndicator(
        onRefresh: fetchCitas,
        child: ListView.builder(
          itemCount: citas.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                  '${citas[index]['fecha_hora_inicio']} - ${citas[index]['fecha_hora_fin']}'),
              subtitle: Text('Precio: ${citas[index]['precio']} USD'),
              onTap: () {
                double precio = double.parse(citas[index]['precio'].toString());
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                                precio: precio, citaId: citas[index]['id'])))
                    .then((_) => fetchCitas()); // Recargar citas al regresar
              },
            );
          },
        ),
      ),
    );
  }
}

*/