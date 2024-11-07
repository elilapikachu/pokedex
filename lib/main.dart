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
      title: 'Pokemon',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 158, 25, 25)),
        useMaterial3: true,
      ),
      home: MyHomePagePokemon(title: "Pokedex"),
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
  List<dynamic> filteredList = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 20;
  String selectedType = ''; // Para almacenar el tipo seleccionado

  @override
  void initState() {
    super.initState();
    fetchPokemon(); // Carga inicial
  }

  // Función para obtener los Pokémon
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
          pokemonList = data['pokemon']
              .map((p) => p['pokemon'])
              .toList(); // Filtrar según el tipo
        } else {
          pokemonList.addAll(
              data['results']); // Agregar todos los Pokémon si no hay tipo
        }
        filteredList = pokemonList;
        isLoading = false;
        if (data['results'] != null && data['results'].length < limit) {
          hasMore = false;
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
      fetchPokemon(selectedType); // Cargar la página siguiente
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        hasMore = true; // Habilitar la carga de más elementos si retrocedemos
      });
      fetchPokemon(selectedType); // Cargar la página anterior
    }
  }

  // Función para actualizar el filtro de tipo
  void filterByType(String type) {
    setState(() {
      selectedType = type;
      currentPage = 0;
      pokemonList.clear(); // Limpiar la lista actual
    });
    fetchPokemon(type); // Filtrar los Pokémon según el tipo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: () => filterByType('fire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Fondo transparente
                    elevation: 0, // Elimina la sombra del botón
                    padding: EdgeInsets.zero, // Elimina el padding del botón
                  ),
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(
                            'lib/assets/images/fuego.gif'), // Imagen de fondo para el botón
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment
                        .center, // Centrar el texto dentro del contenedor
                    child: const Text(
                      'Fire', // Texto sobre la imagen
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón de tipo Water
                ElevatedButton(
                  onPressed: () => filterByType('water'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(
                            'lib/assets/images/aguita.gif'), // Imagen de fondo para el botón
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Water',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón de tipo Grass
                ElevatedButton(
                  onPressed: () => filterByType('grass'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(
                            'lib/assets/images/hierva.jpg'), // Imagen de fondo para el botón
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Grass',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón de tipo Electric
                ElevatedButton(
                  onPressed: () => filterByType('electric'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(
                            'lib/assets/images/electrico.gif'), // Imagen de fondo para el botón
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Electric',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Carga de Pokémon
          Expanded(
            child: pokemonList.isEmpty && isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final pokemon = filteredList[index];
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
            leading: Image.network(snapshot.data ?? '',
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error)),
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
                // Fondo con GIF que ocupa toda la pantalla
                Positioned.fill(
                  child: Image.asset(
                    'lib/assets/images/gif.gif',
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
