import 'package:api_test/screens/data_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _token;  // Variable pour afficher le token

  Future<void> _login() async {
    print('Tentative de connexion...');
    print('Username: ${_usernameController.text}');
    print('Password: ${_passwordController.text}');
    try {
      final token = await ApiService.fetchToken(
        _usernameController.text,
        _passwordController.text,
      ).timeout(const Duration(seconds: 10));

      if (token != null) {
        print('Token reçu: $token');
        await TokenService.saveToken(token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DataScreen()),
        );

        setState(() {
          _token = token;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion réussie !')),
        );
      } else {
        print('Erreur: Token est null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion.')),
        );
      }
    } catch (e) {
      print('Erreur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nom d’utilisateur'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 20),
            if (_token != null)
              Text(
                'Token: $_token',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}