import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

import 'package:peliculas/src/models/pelicula_model.dart';
import 'package:peliculas/src/models/actores_model.dart';

class PeliculasProvider {
  String _apiKey = 'b7c4bb9e5c1e5e609db56888110f7fcc';
  String _url = 'api.themoviedb.org';
  String _language = 'es_ES';

  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();

  final _popularesStreamController =
      StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink =>
      _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream =>
      _popularesStreamController.stream;

  void disposeStreams() {
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async {
    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);
    final peliculas = new Peliculas.fromJsonList(decodedData['results']);
    return peliculas.items;
  }

  Future<List<Pelicula>> getPeliculasEnCines() async {
    final url = Uri.https(
      _url,
      '3/movie/now_playing',
      {'api_key': _apiKey, 'language': _language},
    );
    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPeliculasPopulares() async {
    if (_cargando) return [];
    _cargando = true;
    _popularesPage++;
    final url = Uri.https(
      _url,
      '3/movie/popular',
      {
        'api_key': _apiKey,
        'language': _language,
        'page': _popularesPage.toString()
      },
    );
    final respuesta = await _procesarRespuesta(url);
    _populares.addAll(respuesta);
    popularesSink(_populares);
    _cargando = false;
    return respuesta;
  }

  // obtener actores de las peliculas
  Future<List<Actor>> getCast(String peliculaId) async {
    final url = Uri.https(_url, '3/movie/$peliculaId/credits', {
      'api_key': _apiKey,
      'language': _language,
    });
    final respuesta = await http.get(url);
    final decodedData = json.decode(respuesta.body);
    final casting = new Cast.fromJsonList(decodedData['cast']);
    return casting.actores;
  }
}
