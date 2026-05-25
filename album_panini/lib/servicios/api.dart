import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServicio {
  static const String baseUrl = 'https://api-album-panini-s4wp.vercel.app/api';

  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> borrarToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final datos = jsonDecode(respuesta.body);
    if (respuesta.statusCode == 200) {
      await guardarToken(datos['token']);
      return {'ok': true, 'usuario': datos['usuario']};
    } else {
      return {'ok': false, 'error': datos['error']};
    }
  }

  static Future<Map<String, dynamic>> registro(
      String nombre, String email, String password) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/registro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': nombre, 'email': email, 'password': password}),
    );
    final datos = jsonDecode(respuesta.body);
    if (respuesta.statusCode == 201) {
      return {'ok': true};
    } else {
      return {'ok': false, 'error': datos['error']};
    }
  }

  static Future<Map<String, dynamic>> obtenerPaises() async {
    final respuesta = await http.get(Uri.parse('$baseUrl/paises'));
    final datos = jsonDecode(respuesta.body);
    if (respuesta.statusCode == 200) {
      return {'ok': true, 'paises': datos['paises']};
    } else {
      return {'ok': false, 'error': 'No se pudieron cargar los paises'};
    }
  }

  static Future<Map<String, dynamic>> obtenerColeccion(String iso3) async {
    final token = await obtenerToken();
    final respuesta = await http.get(
      Uri.parse('$baseUrl/mi-coleccion?iso3=$iso3'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final datos = jsonDecode(respuesta.body);
    if (respuesta.statusCode == 200) {
      return {'ok': true, 'laminas': datos['laminas']};
    } else {
      return {'ok': false, 'error': datos['error']};
    }
  }

  static Future<Map<String, dynamic>> registrarLamina(String laminaId) async {
    final token = await obtenerToken();
    final respuesta = await http.post(
      Uri.parse('$baseUrl/registrar-lamina'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'lamina_id': laminaId}),
    );
    final datos = jsonDecode(respuesta.body);
    if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
      return {'ok': true, 'mensaje': datos['mensaje']};
    } else {
      return {'ok': false, 'error': datos['error']};
    }
  }

  static Future<Map<String, dynamic>> misIntercambios() async {
    final token = await obtenerToken();
    final respuesta = await http.get(
      Uri.parse('$baseUrl/mis-intercambios'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final datos = jsonDecode(respuesta.body);
    if (respuesta.statusCode == 200) {
      return {'ok': true, 'intercambios': datos['intercambios']};
    } else {
      return {'ok': false, 'error': datos['error']};
    }
  }
}