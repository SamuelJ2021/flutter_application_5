import 'dart:convert';
import 'dart:ffi';
/*import 'dart:ffi';*/
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OMDb API Demo',
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}


class _MovieListScreenState extends State<MovieListScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OMDb Movie Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search Movies'),
              onSubmitted: (value) {
                _searchMovies(value);
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_movies[index].titre),
                    subtitle: Text(_movies[index].annee),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (BuildContext context) => MovieDetailScreen(movie:_movies[index]))
                    )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchMovies(String query) async {
    const apiKey = 'a19b08f8';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&s=$query';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> movies = data['Search'];

      setState(() {
        _movies = movies.map((movie) => Movie.fromJson(movie)).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }
}


class Movie {
  String titre = '';
  String annee = '';
  String i = '';

  Movie({required this.titre, required this.annee, required this.i});

  factory Movie.fromJson(Map<String, dynamic> json) {
    /*floatingActionButton: FloatingActionButton(onPressed: f, tooltip: 'Follow the link', children: <Widget>[*/
    //ListTile
    //Int i = json['imdbID'];
    return Movie(
      titre: json['Title'],/*FloatingActionButton(onPressed: f, tooltip: 'Follow the link', child: json['Title']),*/
      annee: json['Year'],
      i: json['imdbID'],
    );
  }
}



class MovieDetailScreen extends StatefulWidget{
  final Movie movie;
  MovieDetailScreen({required this.movie});
  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}
class _MovieDetailScreenState extends State<MovieDetailScreen>{
  Map<String, dynamic>? _movieDetails;
  bool _isLoading = true;

  @override
  void initState(){
    super.initState();
    _getMovie();
  }

  Future<void> _getMovie() async {
    const apiKey = 'a19b08f8';
    print(widget.movie.i);
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&i=${widget.movie.i}';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      //final Map<String, dynamic> _movieDetails = json.decode(response.body);
      // final List<dynamic> movies = data['Search'];

      setState(() {
        //_movie = movies.map((movie) => Movie.fromJson(movie)).toList();
        _movieDetails = json.decode(response.body);
        print(_movieDetails);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load movies');
    }
  } 

Widget loadImageWithFallback(String primaryUrl) {
  return Image.network(
    primaryUrl, // URL principale
    fit: BoxFit.cover, // Ajuste l'image (optionnel)
    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
      // Affiche l'image de remplacement si une erreur survient
      return Image.network(
        "https://media.discordapp.net/attachments/655557115557183518/1318576580825583648/image.png?ex=6762d3a2&is=67618222&hm=554005e9944027dcc30b8e2526d9915419763caaeff0e3205902d5656f04f903&=&format=webp&quality=lossless"
        ,
        fit: BoxFit.cover,
      );
    },
  );
}

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.titre ?? 'Details du film'),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : _movieDetails == null
          ? Center(child: Text('Erreur de chargement'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  loadImageWithFallback('${_movieDetails?['Poster']}'),
                  Text(
                    '${_movieDetails!['Title']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      )
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Année: ${_movieDetails!['Year']}'
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Genre: ${_movieDetails!['Genre']}'
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Réalisateur: ${_movieDetails!['Director']}'
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Résumé: ${_movieDetails!['Plot']}'
                  ),
                ],
              ),
            ),
    );
  }

}