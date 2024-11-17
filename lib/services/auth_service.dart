import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  static const String baseUrl = 'https://matchapi.uim.gt/api/auth';
  static const String loginUrl = '$baseUrl/login/';
  static const String refreshUrl = '$baseUrl/token/refresh/';
  static const String userUrl = 'https://matchapi.uim.gt/api/users/me/';

  // Guarda tokens en SharedPreferences
  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access', access);
    await prefs.setString('refresh', refresh);
  }

  // Guarda datos del usuario en SharedPreferences
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(userData));
  }

  // Obtiene tokens desde SharedPreferences
  static Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'access': prefs.getString('access'),
      'refresh': prefs.getString('refresh'),
    };
  }

  // Elimina tokens y datos de usuario (Logout)
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/auth'); // Navega a AuthScreen
  }

  // Intenta renovar el token de acceso
  static Future<bool> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh');

    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse(refreshUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await prefs.setString('access', data['access']);
      return true;
    } else {
      return false;
    }
  }

  // Método genérico para enviar solicitudes HTTP con manejo de token
  static Future<http.Response> sendRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    dynamic body,
    BuildContext? context,
  }) async {
    final tokens = await getTokens();
    String? accessToken = tokens['access'];

    headers ??= {};
    headers['Authorization'] = 'Bearer $accessToken';

    http.Response response;

    try {
      if (method == 'GET') {
        response = await http.get(Uri.parse(url), headers: headers);
      } else if (method == 'POST') {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        );
      } else if (method == 'PATCH') {
        response = await http.patch(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        );
      } else if (method == 'DELETE') {
        response = await http.delete(Uri.parse(url), headers: headers);
      } else {
        throw Exception('Método no soportado');
      }

      // Si el token expira, intenta renovarlo
      if (response.statusCode == 401) {
        final success = await refreshAccessToken();
        if (success) {
          final newTokens = await getTokens();
          headers['Authorization'] = 'Bearer ${newTokens['access']}';
          if (method == 'GET') {
            response = await http.get(Uri.parse(url), headers: headers);
          }
          if (method == 'POST') {
            response = await http.post(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(body),
            );
          } else if (method == 'PATCH') {
            response = await http.patch(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(body),
            );
          }
        } else {
          if (context != null) logout(context);
        }
      }

      return response;
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Obtiene datos del usuario desde el servidor
  static Future<Map<String, dynamic>?> fetchUserData(
      BuildContext context) async {
    try {
      final response = await sendRequest(
        url: userUrl,
        method: 'GET',
        context: context,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveUserData(data);
        return data;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener datos del usuario')),
        );
        return null;
      }
    } catch (e) {
      throw Exception('Error al obtener datos del usuario: $e');
    }
  }

// Devuelve el ID del usuario actual desde SharedPreferences
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(
        'userData'); // Asume que el userData se almacena como un string JSON
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      return userData['id']; // Devuelve el ID del usuario si está disponible
    }
    return null; // Si no hay datos, devuelve null
  }
}
