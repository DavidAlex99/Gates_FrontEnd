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
    int? userId = prefs.getInt('userId');

    if (userId == null) {
      print('userId ID is not available');
      return;
    }

    final response = await http.get(
      Uri.parse(
        'http://192.168.100.6:8001/create_payment/${widget.precio.toStringAsFixed(2)}/${widget.citaId}/$userId',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final approvalUrl = jsonData['approval_url'];

      _controller.loadRequest(Uri.parse(approvalUrl));
    } else {}
  }
}
