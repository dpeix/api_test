import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String?> fetchToken(String username, String password) async {
    final url = Uri.parse('https://std30.beaupeyrat.com/auth');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      return null;
    }
  }

  static Future<void> fetchData(String? token) async {
    final url = Uri.parse('https://std30.beaupeyrat.com/api/docs');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
    } else {
      print('Erreur: ${response.statusCode}');
    }
  }
}
