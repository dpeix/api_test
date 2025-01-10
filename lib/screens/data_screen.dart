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
  bool _hasFetchedTweets = false;

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
    if (!_hasFetchedTweets) {
      _fetchTweets();
      _hasFetchedTweets = true;
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Fil d’actualité'),
      centerTitle: true,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _tweets.isNotEmpty
            ? ListView.separated(
                itemCount: _tweets.length,
                separatorBuilder: (context, index) => const Divider(
                  thickness: 1,
                  color: Colors.grey,
                  height: 10,
                  indent: 10,
                  endIndent: 10,
                ),
                itemBuilder: (context, index) {
                  // Trier les tweets en affichant les plus récents en premier
                  final sortedTweets = List.from(_tweets)
                    ..sort((a, b) => DateTime.parse(b['createdAt'])
                        .compareTo(DateTime.parse(a['createdAt'])));
                  final tweet = sortedTweets[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            tweet['avatar_url'] ?? 'https://via.placeholder.com/50',
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Tweet content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username and timestamp
                              Row(
                                children: [
                                  Text(
                                    tweet['username'] ?? 'Utilisateur inconnu',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "@${tweet['username']} • ${_formatTimeAgo(tweet['createdAt'])}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Tweet text
                              Text(
                                tweet['content'] ?? 'Contenu indisponible',
                              ),
                              const SizedBox(height: 10),
                              // Actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline,
                                        color: Colors.grey, size: 20),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.repeat,
                                        color: Colors.grey, size: 20),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.favorite_border,
                                        color: Colors.grey, size: 20),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share,
                                        color: Colors.grey, size: 20),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : const Center(child: Text('Aucun tweet disponible')),
  );
}


/// Helper method to format time into "Xh ago" or similar.
String _formatTimeAgo(String dateTime) {
  final date = DateTime.parse(dateTime);
  final duration = DateTime.now().difference(date);
  if (duration.inMinutes < 60) {
    return "${duration.inMinutes}m";
  } else if (duration.inHours < 24) {
    return "${duration.inHours}h";
  } else {
    return "${duration.inDays}j";
  }
}

}
