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
        useMaterial3: true,
      ),
      home: const MyHomePagePokemon(),
    );
  }
}

class MyHomePagePokemon extends StatefulWidget {
  const MyHomePagePokemon({super.key});

  @override
  State<MyHomePagePokemon> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePagePokemon> {
  List<dynamic> pokemonList = [];
  List<dynamic> typeList = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 20;
  String? selectedType;

  @override
  void initState() {
    super.initState();
    fetchPokemon();
    fetchTypes();
  }

  Future<void> fetchTypes() async {
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/type'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        typeList = data['results'];
      });
    }
  }

  Future<void> fetchPokemon([String? type]) async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final int offset = currentPage * limit;
    String url = type != null
        ? 'https://pokeapi.co/api/v2/type/$type'
        : 'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        if (type != null) {
          // Filtrado por tipo y paginado manual
          final allPokemonByType =
              data['pokemon'].map((p) => p['pokemon']).toList();
          final paginatedPokemon =
              allPokemonByType.skip(offset).take(limit).toList();
          pokemonList = paginatedPokemon;
          hasMore = paginatedPokemon.length == limit &&
              offset + limit < allPokemonByType.length;
        } else {
          // Lista completa sin filtro
          pokemonList = data['results'];
          hasMore = data['results'].length == limit;
        }
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // filtrar por tipo
  void filterByType(String? type) {
    setState(() {
      selectedType = type;
      currentPage = 0;
      pokemonList.clear();
      hasMore = true;
    });
    fetchPokemon(type);
  }

  Color getTypeColor(String type) {
    switch (type) {
      case 'normal':
        return Colors.brown[400]!;
      case 'fire':
        return Colors.redAccent;
      case 'water':
        return Colors.blueAccent;
      case 'electric':
        return Colors.amber;
      case 'grass':
        return Colors.green;
      case 'ice':
        return Colors.cyanAccent[100]!;
      case 'fighting':
        return Colors.orange;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.indigoAccent;
      case 'psychic':
        return Colors.pinkAccent;
      case 'bug':
        return Colors.lightGreen[700]!;
      case 'rock':
        return Colors.grey;
      case 'ghost':
        return Colors.indigo;
      case 'dragon':
        return Colors.deepPurpleAccent;
      case 'dark':
        return Colors.brown[800]!;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pink[200]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/logo.png',
                height: 40,
              ),
              const SizedBox(
                  width:
                      10), //espacio que se tiene encuenta entre los elementos
              const Text(
                'Pokedex',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
      body: pokemonList.isEmpty && isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: typeList.length,
                    itemBuilder: (context, index) {
                      final type = typeList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: getTypeColor(type['name']),
                          ),
                          onPressed: () => filterByType(type['name']),
                          child: Text(
                            type['name'],
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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

  void nextPage() {
    if (hasMore) {
      setState(() {
        currentPage++;
      });
      fetchPokemon(selectedType);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        hasMore = true;
      });
      fetchPokemon(selectedType);
    }
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
            leading: Image.network(snapshot.data ?? '',
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.error)),
            title: Text(pokemon['name']),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PokemonDetailScreen(pokemonUrl: pokemon['url']),
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

  const PokemonDetailScreen({Key? key, required this.pokemonUrl})
      : super(key: key);

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
                Positioned.fill(
                  child: Image.asset(
                    'lib/assets/images/fondop.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                // agregamos la opacidad
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
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
                        Image.network(
                          pokemonData['sprites']['front_default'] ?? '',
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
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
