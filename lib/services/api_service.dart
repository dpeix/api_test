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

  static Future<List<dynamic>> fetchData(String token) async {
  final url = Uri.parse('https://std30.beaupeyrat.com/api/tweets'); // Vérifiez l'URL complète
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  print('Réponse brute: ${response.body}'); // Affiche la réponse JSON brute pour vérifier

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    // Vérifiez si la clé "member" existe et contient les tweets
    if (jsonResponse is Map && jsonResponse.containsKey('member')) {
      return jsonResponse['member'] as List<dynamic>;
    } else {
      throw Exception('Format de réponse inattendu : clé "member" manquante');
    }
  } else {
    throw Exception('Erreur de récupération des tweets: ${response.statusCode}');
  }
}

}
