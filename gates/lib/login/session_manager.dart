// clase para guardar la informacion del usuario que e registra o inicia sesion
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
}
