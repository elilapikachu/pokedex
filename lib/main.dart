import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyPokemonApp());
}

class MyPokemonApp extends StatelessWidget {
  const MyPokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePagePokemon(title: 'Pokemon'),
    );
  }
}

class MyHomePagePokemon extends StatefulWidget {
  const MyHomePagePokemon({super.key, required this.title});
  final String title;

  @override
  State<MyHomePagePokemon> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePagePokemon> {
  List<dynamic> pokemonList = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    fetchPokemon(); // Carga inicial
  }

  Future<void> fetchPokemon() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final int offset = currentPage * limit;
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        pokemonList = data['results'];
        isLoading = false;
        if (data['results'].length < limit) {
          hasMore = false; // No hay más datos si el número de resultados es menor al límite
        } else {
          hasMore = true;
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void nextPage() {
    if (hasMore) {
      setState(() {
        currentPage++;
      });
      fetchPokemon();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        hasMore = true; // Habilitar la carga de más elementos si retrocedemos
      });
      fetchPokemon();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: pokemonList.isEmpty && isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: pokemonList.length,
                    itemBuilder: (context, index) {
                      final pokemon = pokemonList[index];
                      return PokemonCard(pokemon: pokemon);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: currentPage > 0 ? previousPage : null,
                      child: const Text("Anterior"),
                    ),
                    Text("Página ${currentPage + 1}"),
                    TextButton(
                      onPressed: hasMore ? nextPage : null,
                      child: const Text("Siguiente"),
                    ),
                  ],
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final dynamic pokemon;

  const PokemonCard({Key? key, required this.pokemon}) : super(key: key);

  Future<String> fetchPokemonImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['sprites']['front_default'] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchPokemonImage(pokemon['url']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Card(
          child: ListTile(
            leading: Image.network(snapshot.data ?? '', width: 50, height: 50, errorBuilder: (context, error, stackTrace) => Icon(Icons.error)),
            title: Text(pokemon['name']),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PokemonDetailScreen(pokemonUrl: pokemon['url']),
                  ),
                );
              },
              child: const Text("Ver más"),
            ),
          ),
        );
      },
    );
  }
}

class PokemonDetailScreen extends StatelessWidget {
  final String pokemonUrl;

  const PokemonDetailScreen({Key? key, required this.pokemonUrl}) : super(key: key);

  Future<Map<String, dynamic>> fetchPokemonDetails() async {
    final response = await http.get(Uri.parse(pokemonUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {};
  }

  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Pokémon"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchPokemonDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final pokemonData = snapshot.data!;
            return Stack(
              children: [
                // Fondo con GIF que ocupa toda la pantalla
                Positioned.fill(
                  child: Image.asset(
                    'lib/assets/images/fondop.jpg',
                    fit: BoxFit
                        .cover, // Asegura que el GIF cubra toda la pantalla
                  ),
                ),
                // Contenedor con opacidad negra sobre el fondo
                Positioned.fill(
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.4), // Ajusta la opacidad aquí
                  ),
                ),
                // Contenido en primer plano
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Imagen del Pokémon más grande
                        Image.network(
                          pokemonData['sprites']['front_default'] ?? '',
                          height:
                              200, // Aumenta el tamaño de la imagen del Pokémon
                          width: 200, // Asegura que la imagen sea cuadrada
                          fit: BoxFit
                              .contain, // Mantiene la proporción de la imagen
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pokemonData['name'].toString().toUpperCase(),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Height: ${pokemonData['height']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Weight: ${pokemonData['weight']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Abilities:",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Column(
                          children: (pokemonData['abilities'] as List)
                              .map((ability) => Text(
                                    ability['ability']['name'],
                                    style: const TextStyle(color: Colors.white),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text("Failed to load details."));
          }
        },
      ),
    );
  }
}
