import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  List<dynamic> _tweets = [];
  bool _isLoading = true;

  Future<void> _fetchTweets() async {
    final token = await TokenService.getToken();
    if (token != null) {
      try {
  final tweets = await ApiService.fetchData(token);
  if (tweets.isEmpty) {
    throw Exception('Aucun tweet disponible.');
  }
  setState(() {
    _tweets = tweets;
    _isLoading = false;
  });
} catch (e) {
  setState(() => _isLoading = false);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur: ${e.toString()}')),
  );
}

    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token introuvable. Veuillez vous reconnecter.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTweets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Tweets')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tweets.isNotEmpty
              ? ListView.builder(
                  itemCount: _tweets.length,
                  itemBuilder: (context, index) {
                    final tweet = _tweets[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tweet['content'] ?? 'Contenu indisponible',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('ID: ${tweet['id']}'),
                            Text('Utilisateur: ${tweet['user_id']}'),
                            Text('Créé le: ${tweet['created_at']}'),
                            Text('Likes: ${tweet['likes']}'),
                            Text('Retweets: ${tweet['retweets']}'),
                            Text(
                              tweet['state'] == 1 ? 'Statut: Actif' : 'Statut: Inactif',
                              style: TextStyle(
                                color: tweet['state'] == 1 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: Text('Aucun tweet disponible')),
    );
  }
}
